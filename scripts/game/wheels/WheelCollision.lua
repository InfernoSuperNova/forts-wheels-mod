--WheelCollision.lua
--- forts script API ---




--Master wheel collision handling function. 
function WheelCollisionHandler()
    Displacement = {}
    data.wheelsTouchingGround = {}
    local structures = GetDeviceStructureGroups()

    --section off into structures
    for structureKey, devices in pairs(structures) do
        for deviceKey, device in pairs(devices) do
            if not data.wheelsTouchingGround[structureKey] then data.wheelsTouchingGround[structureKey] = {} end
            local wheelStats = GetWheelStats(device)
            local wheelRadius = wheelStats.radius + TRACK_WIDTH
            local snapResult = SnapToWorld(wheelStats.pos, wheelRadius, SNAP_GROUND, -1, -1, "") -- | SNAP_LINKS)
            if snapResult.Position.x == wheelStats.pos.x and snapResult.Position.y == wheelStats.pos.y then
                WheelPos[device.id] = wheelStats.pos
                continue
            end
            local normal = NormalizeVector(snapResult.Position - wheelStats.pos)
            normal.x = math.abs(normal.x) * math.sign(snapResult.Normal.x)
            normal.y = math.abs(normal.y) * math.sign(snapResult.Normal.y)


            if ModDebug.collision then
                SpawnCircle(snapResult.Position, 25, Blue(), 0.04)
                SpawnLine(snapResult.Position, snapResult.Position + 75 * normal, Blue(), 0.04)
                SpawnCircle(snapResult.Position + 75 * normal, 75, Red(), 0.04)
            end


            local displacedPos = snapResult.Position + wheelRadius * normal
            WheelPos[device.id] = displacedPos
            local displacement = displacedPos - wheelStats.pos

            local spring = WHEEL_SPRINGS[device.saveName]
            
            local force = DirectionalDampening(spring.springConst, displacement, spring.dampening, AverageCoordinates({device.nodeVelA, device.nodeVelB}), normal)
            ApplyForce(device.nodeA, force)
            ApplyForce(device.nodeB, force)
            data.wheelsTouchingGround[structureKey][deviceKey] = displacement
        end
    end
    Structures = structures
end
--Gets a table of structures, each structure being a "group" of wheel devices
function GetDeviceStructureGroups()
    local structures = {}
    for _, device in pairs(data.devices) do
        if IsWheelDevice(device.saveName) and IsDeviceFullyBuilt(device.id) then
            local structureId = device.strucId
            if not structures[structureId] then structures[structureId] = {} end
            table.insert(structures[structureId], device)
        end
    end
    return structures
end

function GetOffsetDevicePos(device, offset)

    local offsetPos = OffsetPerpendicular(device.nodePosA, device.nodePosB, offset)
    local newPos = offsetPos + device.pos
    return newPos
end

function DirectionalDampening(springConst, displacement, dampening, velocity, surfacePerpVector)
    local velocityPerpToSurface = Dot(velocity, surfacePerpVector)
    local force = springConst * displacement - dampening * velocityPerpToSurface * surfacePerpVector
    
    return force
end

--A cool helper function I sotle from landcroozers 2
function IsWithinDistance(vector1, vector2, distance)
    local dx = vector1.x - vector2.x
    local dy = vector1.y - vector2.y
    local distanceSquared = dx * dx + dy * dy
    local givenDistanceSquared = distance * distance

    return distanceSquared <= givenDistanceSquared
end

