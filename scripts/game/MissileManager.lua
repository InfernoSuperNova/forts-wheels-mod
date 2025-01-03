data.missileStructureTargets = {}
data.missilesNotTargetingStructureYet = {}


MissileManager = {
    SnapTargetDistance = 1000,
    ScanDistance = 10000,
    ScanInterval = 1, -- frames
    TopAttackFactor = 0.5,
}

function MissileManager:Update()
    for projectileNodeId, targetNodeId in pairs(data.missileStructureTargets) do
        if not NodeExists(projectileNodeId) or not NodeExists(targetNodeId) then
            data.missileStructureTargets[projectileNodeId] = nil
            return
        end

        local targetPosition = NodePosition(targetNodeId)
        local missilePosition = NodePosition(projectileNodeId)

        local distanceX = math.abs(targetPosition.x - missilePosition.x)

        local targetPos = {x = targetPosition.x, y = targetPosition.y - distanceX * self.TopAttackFactor}
        SetMissileTarget(projectileNodeId, targetPos)
    end

    for nodeId, scanFrame in pairs(data.missilesNotTargetingStructureYet) do
        BetterLog("HI SCANNNING")
        data.missilesNotTargetingStructureYet[nodeId] = scanFrame + 1
        if scanFrame < self.ScanInterval then return end  
        data.missilesNotTargetingStructureYet[nodeId] = 0
        if not NodeExists(nodeId) then
            data.missilesNotTargetingStructureYet[nodeId] = nil
            return
        end

        local pos = NodePosition(nodeId)
        local velocity = NodeVelocity(nodeId)
        local direction = NormalizeVector({x = velocity.x, y = velocity.y, z = velocity.z})
        local target = {x = pos.x + direction.x * self.ScanDistance, y = pos.y + direction.y * self.ScanDistance, z = pos.z + direction.z * self.ScanDistance}

       -- SpawnLine(pos, target, {r = 255, g = 0, b = 0, a = 255}, 2)
        local result = CastRay(NodePosition(nodeId), target, RAY_EXCLUDE_BG_MATERIALS, 0)
        if result == RAY_HIT_STRUCTURE then
            local structureNode = GetRayHitLinkNodeIdA()
            if NodeTeam(structureNode) ~= NodeTeam(nodeId) then
                data.missilesNotTargetingStructureYet[nodeId] = nil
                data.missileStructureTargets[nodeId] = structureNode
            end

            --SpawnLine(pos, NodePosition(structureNode), {r = 0, g = 255, b = 0, a = 255}, 2)
        end
        
    end
end

function MissileManager:RegisterNewMissile(projectileNodeId)
    if GetNodeProjectileType(projectileNodeId) ~= PROJECTILE_TYPE_MISSILE then
        return
    end
    local target = GetMissileTarget(projectileNodeId)
    if target.x == 0 and target.y == 0 and target.z == 0 then
        return
    end
    local result = SnapToWorld(target, self.SnapTargetDistance, SNAP_NODES, TEAM_ANY, -1, "")
    if NodeTeam(result.NodeIdA) == NodeTeam(projectileNodeId) then
        return
    end
    local nearestNode = result.NodeIdA

    if nearestNode == -1 then
        data.missilesNotTargetingStructureYet[projectileNodeId] = 0
        return
    end
    
    data.missileStructureTargets[projectileNodeId] = nearestNode
end

