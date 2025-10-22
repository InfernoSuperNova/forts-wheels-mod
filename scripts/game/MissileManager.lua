data.missileCruiseGuidance = {}
data.missileTerminalGuidance = {}
data.missilesNotTargetingStructureYet = {}


MissileManager = {
    blacklist = {rocket=true, rocketemp=true},
    SnapTargetDistance = 1000,
    ScanDistance = 10000,
    ScanInterval = 1, -- frames
    TopAttackFactor = 0.85,
    TopAttackFactorRockets = 0,
    TerminalGuidanceDistance = 20000,
    ReturnToCruiseGuidanceDistance = 30000,
    MaxMissileGuideAttempts = 100,
    GroundAvoidanceDistance = 2000,
    ProportionalNavigationConstant = 5, -- Values between 3 and 5 are common
    DoPropNav = false -- Set to false to disable proportional navigation
}

function MissileManagerUpdate()
    MissileManager:Update()
end

function MissileManager:Log(text)
    --BetterLog(text)
end

function MissileManager:RegisterFromExistingProjectile(oldId, newId, teamId)
    local saveName = GetNodeProjectileSaveName(newId)
    if GetProjectileParamBool(saveName, teamId, "LCIgnoreMissileGuidance", false) then return end
    if data.missileCruiseGuidance[oldId] then
        data.missileCruiseGuidance[newId] = DeepCopy(data.missileCruiseGuidance[oldId])
    end
    if data.missileTerminalGuidance[oldId] then
        data.missileTerminalGuidance[newId] = DeepCopy(data.missileTerminalGuidance[oldId])
    end
    if data.missilesNotTargetingStructureYet[oldId] then
        data.missilesNotTargetingStructureYet[newId] = DeepCopy(data.missilesNotTargetingStructureYet[oldId])
    end
end 

function MissileManager:Update()
     -- Searching for new targets
    for nodeId, obj in pairs(data.missilesNotTargetingStructureYet) do
        self:FindTarget(nodeId, obj)
    end

    for projectileNodeId, obj in pairs(data.missileCruiseGuidance) do
        self:CruiseGuidance(projectileNodeId, obj)
    end

    for projectileNodeId, obj in pairs(data.missileTerminalGuidance) do
        self:TerminalGuidance(projectileNodeId, obj)
    end
end

function MissileManager:FindTarget(nodeId, obj)
    obj.time = obj.time + 1
    if obj.time < self.ScanInterval then return end  
    obj.time = 0
    if not NodeExists(nodeId) then
        data.missilesNotTargetingStructureYet[nodeId] = nil
        self:Log("Search: Missile destroyed, stopping search")
        self:Log("Search: Switching guidance from search to none")
        return
    end

    local pos = NodePosition(nodeId)
    local velocity = NodeVelocity(nodeId)
    local direction = NormalizeVector(velocity)
    local target = {x = pos.x + direction.x * self.ScanDistance, y = pos.y + direction.y * self.ScanDistance, z = pos.z + direction.z * self.ScanDistance}

--    SpawnLine(pos, target, {r = 255, g = 0, b = 0, a = 255}, 2)
    local result = CastRay(NodePosition(nodeId), target, RAY_EXCLUDE_BG_MATERIALS, 0)
    if result == RAY_HIT_STRUCTURE then
        local structureNode = GetRayHitLinkNodeIdA()
        local structureId =  NodeStructureId(structureNode)

            local structureTeamId = NodeTeam(structureNode) % MAX_SIDES
            if structureTeamId ~= NodeTeam(nodeId) % MAX_SIDES then
                data.missilesNotTargetingStructureYet[nodeId] = nil
                
                data.missileCruiseGuidance[nodeId] = {targetStructureId = structureId, topAttackFactor = obj.topAttackFactor, targetTeamId = structureTeamId}
                self:Log("Search: Found new target, starting guidance")
                self:Log("Search: Switching guidance from search to cruise")
            end

        -- SpawnLine(pos, NodePosition(structureNode), {r = 0, g = 255, b = 0, a = 255}, 2)
    end
end

function MissileManager:CruiseGuidance(projectileNodeId, obj)
    local targetStructureId = obj.targetStructureId
    if not NodeExists(projectileNodeId) then
        data.missileCruiseGuidance[projectileNodeId] = nil
        self:Log("Cruise: Missile destroyed, stopping guidance")
        return
    end

    if not IsMissileAttacking(projectileNodeId) then return end
    local targetPosition = GetStructurePos(targetStructureId)


    -- if the target structure is destroyed, stop guiding the missile and search for a new target
    if targetPosition.x == 0 and targetPosition.y == 0 then
        data.missileCruiseGuidance[projectileNodeId] = nil
        data.missilesNotTargetingStructureYet[projectileNodeId] = {time = 0, topAttackFactor = obj.topAttackFactor}
        self:Log("Cruise: Target structure destroyed, searching for new target")
        self:Log("Cruise: Switching guidance from cruise to search")
        return
    end
    local missilePosition = NodePosition(projectileNodeId)
    local distanceX = math.abs(targetPosition.x - missilePosition.x)

    local topAttackFactor = math.sign(obj.topAttackFactor) * math.pow(distanceX, math.abs(obj.topAttackFactor))

    local targetPos = {x = targetPosition.x, y = targetPosition.y + topAttackFactor}
    SetMissileTarget(projectileNodeId, targetPos)

    --SpawnLine(missilePosition, targetPos, {r = 255, g = 0, b = 0, a = 255}, 0.04)

    local distanceY = math.abs(targetPos.y - missilePosition.y)

    -- if the missile is close enough to the target, switch to terminal guidance
    if (distanceX * distanceX + distanceY * distanceY) < self.TerminalGuidanceDistance * self.TerminalGuidanceDistance then

        self:Log("Cruise: Missile close to target, switching to terminal guidance")
        self:Log("Cruise: Switching guidance from cruise to terminal")
        local targetTeamId = obj.targetTeamId
        local targetSide = targetTeamId % MAX_SIDES
        data.missileCruiseGuidance[projectileNodeId] = nil

        local nodeCount = NodeCount(targetSide)

        local satisfied = false
        local newTargetNode = -1
        local attempts = 0
        while not satisfied do
            attempts = attempts + 1
            if attempts > self.MaxMissileGuideAttempts then
                data.missileTerminalGuidance[projectileNodeId] = nil
                data.missilesNotTargetingStructureYet[projectileNodeId] = {time = 0, topAttackFactor = obj.topAttackFactor}
                self:Log("Cruise: Failed to find a new target, searching for new target")
                self:Log("Cruise: Switching guidance from terminal to search")
                return
            end
            local index = GetRandomInteger(0, nodeCount - 1, "")
            newTargetNode = GetNodeId(targetSide, index)
            local newTargetStructureId = NodeStructureId(newTargetNode)
            if newTargetStructureId == targetStructureId then
                satisfied = true
            end
        end
        data.missileTerminalGuidance[projectileNodeId] = {targetNodeId = newTargetNode, topAttackFactor = obj.topAttackFactor, RTM_oldX = 0, RTM_oldY = 0, previousTargetStructurePos = {x = 0, y = 0}, targetStructureId = targetStructureId, targetTeamId = targetTeamId}
    end
end
function MissileManager:TerminalGuidance(projectileNodeId, obj)

    local targetNodeId = obj.targetNodeId

    if not NodeExists(projectileNodeId) then
        data.missileTerminalGuidance[projectileNodeId] = nil
        self:Log("Terminal: Missile destroyed, stopping guidance")
        self:Log("Terminal: Switching guidance from terminal to none")
        return
    elseif not NodeExists(targetNodeId) then
        data.missileTerminalGuidance[projectileNodeId] = nil
        data.missilesNotTargetingStructureYet[projectileNodeId] = {time = 0, topAttackFactor = obj.topAttackFactor}
        self:Log("Terminal: Target destroyed, searching for new target")
        self:Log("Terminal: Switching guidance from terminal to search")
        return
    end

    local targetPosition = NodePosition(targetNodeId)
    local missilePosition = NodePosition(projectileNodeId)

    local distanceX = math.abs(targetPosition.x - missilePosition.x)
    local distanceY = math.abs(targetPosition.y - missilePosition.y)
    if (distanceX * distanceX + distanceY * distanceY) > self.ReturnToCruiseGuidanceDistance * self.ReturnToCruiseGuidanceDistance then
        data.missileTerminalGuidance[projectileNodeId] = nil
        data.missileCruiseGuidance[projectileNodeId] = {targetStructureId = NodeStructureId(targetNodeId), topAttackFactor = obj.topAttackFactor, targetTeamId = NodeTeam(targetNodeId)}
        self:Log("Terminal: Target too far, switching to cruise guidance")
        self:Log("Terminal: Switching guidance from terminal to cruise")
        return
    end

    if (self.DoPropNav) then
        self:PropNav(projectileNodeId, obj, targetNodeId)
    else
        SetMissileTarget(projectileNodeId, NodePosition(targetNodeId))
    end
end 

function MissileManager:PropNav(projectileNodeId, obj, targetNodeId)
    local missileVelocity = NodeVelocity(projectileNodeId)
    
    local missilePos = NodePosition(projectileNodeId) -- The missile knows where it is
    local targetPos = NodePosition(targetNodeId)      -- The missile knows where it isn't
    local targetStructurePos = GetStructurePos(obj.targetStructureId)
    local previousTargetStructurePos = obj.previousTargetStructurePos
    local targetVelocity = {x = (targetStructurePos.x - previousTargetStructurePos.x) * 25, y = (targetStructurePos.y - previousTargetStructurePos.y) * 25}

    local closingVelocity = {x = targetVelocity.x - missileVelocity.x, y = targetVelocity.y - missileVelocity.y}


    local missileVelocityLengthSquared = missileVelocity.x * missileVelocity.x + missileVelocity.y * missileVelocity.y
    local targetVelocityLengthSquared = targetVelocity.x * targetVelocity.x + targetVelocity.y * targetVelocity.y
    local missilePosToTargetPosX = targetPos.x - missilePos.x
    local missilePosToTargetPosY = targetPos.y - missilePos.y
    if (targetVelocityLengthSquared > missileVelocityLengthSquared) and (missilePosToTargetPosX * targetVelocity.x + missilePosToTargetPosY * targetVelocity.y) > 0 then
        local targetPos = {x = missilePos.x + targetVelocity.x, y = missilePos.y + targetVelocity.y}
        SetMissileTarget(projectileNodeId, targetPos)
        --SpawnLine(missilePos, targetPos, White(), 0.04)
        obj.previousTargetStructurePos = targetStructurePos
        return
    end




    local RTM_newX = targetPos.x - missilePos.x -- By subtracting where it isn't from where it is
    local RTM_newY = targetPos.y - missilePos.y -- It obtains a difference, or deviation
    

    local RTM_newLength = math.sqrt(RTM_newX * RTM_newX + RTM_newY * RTM_newY)
    RTM_newX = RTM_newX / RTM_newLength
    RTM_newY = RTM_newY / RTM_newLength

    local RTM_oldX = obj.RTM_oldX
    local RTM_oldY = obj.RTM_oldY

    local LOS_DeltaX = RTM_newX - RTM_oldX -- The guidance system uses deviations to generate corrective commands
    local LOS_DeltaY = RTM_newY - RTM_oldY -- To drive the missile from a position where it is to a position where it isn't

    local LOS_Rate = math.sqrt(LOS_DeltaX * LOS_DeltaX + LOS_DeltaY * LOS_DeltaY)

    local Vc = -LOS_Rate


    local Nt = 981 * 25


    -- Calculate lateral acceleration
    local latax = {
        x = RTM_newX * self.ProportionalNavigationConstant * Vc * LOS_Rate + LOS_DeltaX * Nt * (0.5 * self.ProportionalNavigationConstant),
        y = RTM_newY * self.ProportionalNavigationConstant * Vc * LOS_Rate + LOS_DeltaY * Nt * (0.5 * self.ProportionalNavigationConstant)
        
    }


    local missileForward = NormalizeVector(NodeVelocity(projectileNodeId))
    local missileRight = {x = -missileForward.y, y = missileForward.x}


    local terrainAvoidFactor = 0

    local rightRay = CastGroundRay(missilePos, {x = missilePos.x + missileRight.x * self.GroundAvoidanceDistance, y = missilePos.y + missileRight.y * self.GroundAvoidanceDistance}, 0)

    if rightRay == RAY_HIT_TERRAIN then
        local hitPos = GetRayHitPosition()
        local missilePosToHitPos = {x = hitPos.x - missilePos.x, y = hitPos.y - missilePos.y}
        local length = math.sqrt(missilePosToHitPos.x * missilePosToHitPos.x + missilePosToHitPos.y * missilePosToHitPos.y)
        terrainAvoidFactor = terrainAvoidFactor - (self.GroundAvoidanceDistance - length)
    end

    local leftRay = CastGroundRay(missilePos, {x = missilePos.x + -missileRight.x * self.GroundAvoidanceDistance, y = missilePos.y + -missileRight.y * self.GroundAvoidanceDistance}, 0)

    if leftRay == RAY_HIT_TERRAIN then
        local hitPos = GetRayHitPosition()
        local missilePosToHitPos = {x = hitPos.x - missilePos.x, y = hitPos.y - missilePos.y}
        local length = math.sqrt(missilePosToHitPos.x * missilePosToHitPos.x + missilePosToHitPos.y * missilePosToHitPos.y)
        terrainAvoidFactor = terrainAvoidFactor + (self.GroundAvoidanceDistance - length)
    end

    terrainAvoidFactor = terrainAvoidFactor / self.GroundAvoidanceDistance * 50

    local RTM_new = {x = RTM_newX, y = RTM_newY}
    local RTM_right = {x = -RTM_new.y, y = RTM_new.x}

    local turnValue = latax.x * RTM_right.x + latax.y * RTM_right.y + terrainAvoidFactor

    local lataxMissileRight = {x = turnValue * missileRight.x, y = turnValue * missileRight.y   }


    local target = {x = missilePos.x + lataxMissileRight.x + missileForward.x * 750, y = missilePos.y + lataxMissileRight.y + missileForward.y * 750}
    -- Set the missile's new target position
    SetMissileTarget(projectileNodeId, target)

    -- Update the old values for the next iteration
    obj.RTM_oldX = RTM_newX
    obj.RTM_oldY = RTM_newY
    obj.targetVelocity = newVelocity
    obj.previousTargetStructurePos = targetStructurePos
end


function MissileManager:RegisterNewMissile(projectileNodeId, weaponType, teamId)
    local saveName = GetNodeProjectileSaveName(projectileNodeId)

    if GetProjectileParamBool(saveName, teamId, "LCIgnoreMissileGuidance", false) then return end


    local saveName = GetNodeProjectileSaveName(projectileNodeId)
    if self.blacklist[saveName] then return end

    if GetNodeProjectileType(projectileNodeId) ~= PROJECTILE_TYPE_MISSILE then
        return
    end
    local target = GetMissileTarget(projectileNodeId)
    if target.x == 0 and target.y == 0 and target.z == 0 then
        return
    end
    local result = SnapToWorld(target, self.SnapTargetDistance, SNAP_NODES, TEAM_ANY, -1, "")

    local projectileTeam = NodeTeam(projectileNodeId)
    local targetTeam = NodeTeam(result.NodeIdA)
    local nearestNode = result.NodeIdA
    if targetTeam == projectileTeam then
        nearestNode = -1
    end
  

    local initialVelocity = NodeVelocity(projectileNodeId)

    local direction = NormalizeVector(initialVelocity)
    local sign = math.sign(direction.y - 0.1)



    if nearestNode == -1 then
        data.missilesNotTargetingStructureYet[projectileNodeId] = {time = 0, topAttackFactor = sign * (RequiresSpotter(weaponType, projectileTeam) and self.TopAttackFactor or self.TopAttackFactorRockets)}
        self:Log("Register: Missile registered in search mode")
        return
    end
    data.missileCruiseGuidance[projectileNodeId] = {targetStructureId = NodeStructureId(nearestNode), topAttackFactor = sign * (RequiresSpotter(weaponType, projectileTeam) and self.TopAttackFactor or self.TopAttackFactorRockets), targetTeamId = targetTeam}
    self:Log("Register: Missile registered in cruise mode")
end

