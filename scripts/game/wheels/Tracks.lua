--Tracks.lua
function InitializeTracks()
    data.trackGroups = {}
end
function RemoveFromTrackGroup(deviceId)
    data.trackGroups[deviceId] = nil
end
function UpdateTracks(frame)
    local localSide = GetLocalTeamId() % MAX_SIDES
    ClearEffects()
    FillTracks()
    SortTracks(localSide)
    GetTrackSetPositions()
end

--clears any wheel sprites on the screen
function ClearEffects()
    for k, v in pairs(data.trackGroups) do
        if not DeviceExists(k) then k = nil end
    end

    -- for k, effect in pairs(LocalEffects) do
    --     CancelEffect(effect)
    -- end
    LocalEffects = {}
end

function FillTracks()
    --clear tracks table
    TracksId = {}
    Tracks = {}
    SortedTracks = {}
    PushedTracks = {}



--insert new entries
    --get the count of devices on a side
    for _, device in pairs(data.devices) do
        PlaceSuspensionPosInTable(device)
    end
end

function PlaceSuspensionPosInTable(device)
    
    if DeviceExists(device.id) 
    and 
    (WHEEL_SAVE_NAMES_RAW[device.saveName]
    )
    and IsDeviceFullyBuilt(device.id) then
        
        if not data.trackGroups[device.id] then data.trackGroups[device.id] = 1 end
        local trackGroup = data.trackGroups[device.id]
        local actualPos = WheelPos[device.id]
        if actualPos.x < LocalScreen.MaxX + 500 and actualPos.x > LocalScreen.MinX - 500 then

            --get the structure that the track set belongs to
            local structureId = device.strucId
            --put it into a table unique to that structure...
            if not Tracks[structureId] then Tracks[structureId] = {} end
            if not Tracks[structureId][trackGroup] then Tracks[structureId][trackGroup] = {} end
            local suspensionPos = actualPos
            if Displacement[device.id] then
                suspensionPos = {
                    x = actualPos.x + Displacement[device.id].x,
                    y = actualPos.y + Displacement[device.id].y,
                }
            end
            local previousPos = data.previousDevicePositions[device.id]
            if not previousPos then previousPos = {x = 0, y = 0} end
            --bad coding practices, don't do this kids
            suspensionPos.radius = GetWheelStats(device).radius
            suspensionPos.saveName = device.saveName
            if not TracksId[structureId] then TracksId[structureId] = {} end
            TracksId[structureId][device.id] = suspensionPos
            suspensionPos.deviceId = device.id
            suspensionPos.teamId = device.team
            if Displacement[device.id] then
                suspensionPos.previousPos = {
                    x = previousPos.x + Displacement[device.id].x,
                    y = previousPos.y + Displacement[device.id].y,
                }
            end
            
            table.insert(Tracks[structureId][trackGroup], suspensionPos)
        end
    end
end

function SortTracks(localSide)
    if ReducedVisuals then PushedTracks = Tracks return end
    for structure, trackSets in pairs(Tracks) do
        local team = GetStructureTeam(structure)
        if not PushedTracks[structure] then PushedTracks[structure] = {} end
        for trackGroup, trackSet in pairs(trackSets) do
            if not SortedTracks[structure] then SortedTracks[structure] = {} end
            --Don't do unnecessary track calculations if the wheel is a wheel
            if trackGroup ~= 11 and not IsCommanderAndEnemyActive("phantom", team, localSide) then
                

                

                --have to reverse it since I was using a bad algorithm before that reversed the whole table, and based the rest of the code around that
                SortedTracks[structure][trackGroup] = ReverseTable(GiftWrapping(trackSet))
                PushedTracks[structure][trackGroup] = PushOutTracks(SortedTracks[structure][trackGroup])
            else
                PushedTracks[structure][trackGroup] = trackSet
            end
        end
    end
end

function GetTrackSetPositions()
    TrackOffsets = {}
    for k, trackSets in pairs(Tracks) do
        for _, trackSet in pairs(trackSets) do
            local pos = AverageCoordinates(trackSet)
            TrackOffsets[k] = pos
        end
    end
end

function DrawTracks(localSide, t)


    --loop through list of track sets
    for base, trackSets in pairs(PushedTracks) do
        local team = GetStructureTeam(base)
            --hide tracks on phantom
        if not IsCommanderAndEnemyActive("phantom", team, localSide) then
            for trackGroup, trackSet in pairs(trackSets) do
                local teamId = Tracks[base][trackGroup][1].teamId
                -- DrawTrackTreads(trackSet, base, trackGroup, teamId)
                DrawTrackSprockets(base, trackGroup, t)
            end
        end
    end
end

function DrawTrackSprockets(base, trackGroup, t)
    local wheelType
    local angle

    if not ReducedVisuals then
        --trackgroup of 11 represents wheel
        if trackGroup == 11 then
            angle = (TrackOffsets[base].x / WHEEL_RADIUS) * (WHEEL_RADIUS - TRACK_WIDTH)

            wheelType = "wheel"
        else
            angle = TrackOffsets[base].x
            wheelType = "sprocket"
        end

        for device, pos in pairs(Tracks[base][trackGroup]) do

            if not pos.previousPos then pos.previousPos = pos end
            local actualPos = Vec3Lerp(pos.previousPos, pos, t)

            local effectPath = path .. data.teamWheelTypes[pos.teamId][wheelType]["small"]
            local newAngle = angle
            if CheckSaveNameTable(pos.saveName, WHEEL_SAVE_NAMES.large) then
                effectPath = path .. data.teamWheelTypes[pos.teamId][wheelType]["large"]
                newAngle = newAngle / 2.5
            end
            if CheckSaveNameTable(pos.saveName, WHEEL_SAVE_NAMES.extraLarge) then
                effectPath = path .. data.teamWheelTypes[pos.teamId][wheelType]["extraLarge"]
                newAngle = newAngle / 5
            end
            local vecAngle = AngleToVector(newAngle)
            

            if not WheelSpriteIds[device] then 
                WheelSpriteIds[device] = SpawnEffectEx(effectPath, pos, vecAngle) 
            else
                SetEffectPosition(WheelSpriteIds[device], actualPos)
                SetEffectDirection(WheelSpriteIds[device], vecAngle)
            end
        end
    else
        
    end
end

WheelSpriteIds = {}


function DrawTrackTreads(trackSet, base, trackGroup, teamId)
    if ReducedVisuals then return end
    --exclude wheels
    if trackGroup == 11 then return end
    

    local points = {}
    local previousRemainder = TrackOffsets[base].x % TRACK_LINK_DISTANCE or 0

    for segmentIndex= 1, #trackSet do
        if #trackSet < 2 then continue end
        local segment = trackSet[segmentIndex]
        local prevSegment = trackSet[(segmentIndex - 2) % #trackSet + 1]

        local arc = PointsAroundArc(segment.wheelPosA, segment.radiusA, prevSegment.posB,segment.posA, TRACK_LINK_DISTANCE, previousRemainder, false)
        local remainder = TRACK_LINK_DISTANCE - arc.remainder
        local segmentNormal = PerpendicularVector(SubtractVectors(segment.posA, segment.posB))
        local gravity= Vec3(0, 1)
        local bowing = -0.1 * Dot(segmentNormal, gravity)
        local straightPoints = SubdivideLineSegmentWithBowing(segment.posA, segment.posB, TRACK_LINK_DISTANCE, remainder, bowing)
        previousRemainder = straightPoints.remainder
        for i = 1, #arc.points do
            table.insert(points, arc.points[i])
        end
        for i = 1, #straightPoints do
            table.insert(points, straightPoints[i])
        end
    end

    for i = 1, #points do
        local point = points[i]
        local nextPoint = points[i % #points + 1]
        local previousPoint = points[(i - 2) % #points + 1]

        local track = data.teamWheelTypes[teamId]["track"]
        local trackLink = data.teamWheelTypes[teamId]["trackLink"]
        local previousTrackDirection = SubtractVectors(previousPoint.pos, point.pos)
        previousTrackDirection = {x = -previousTrackDirection.x, y = -previousTrackDirection.y}
        previousTrackDirection = NormalizeVector(previousTrackDirection)
        local trackDirection = SubtractVectors(point.pos, nextPoint.pos)
        trackDirection = {x = -trackDirection.x, y = -trackDirection.y}
        trackDirection = NormalizeVector(trackDirection)
        -- I hate this so much
        -- I wish I chose oop
        local linkPos = Vec3Lerp(point.pos, nextPoint.pos, 0.5)
        SpawnEffectEx(path .. trackLink, linkPos, trackDirection)

        trackDirection = NormalizeVector(AverageCoordinates({trackDirection, previousTrackDirection}))
        SpawnEffectEx(path .. track, point.pos, trackDirection)


    end
end









function GetTrackTreadsRound(center, track1, track2, teamId, offset)

end

function GetTrackTreadsFlat(trackSet, wheel, teamId, offset)

end


-- Helper function to check if three points are clockwise, counterclockwise, or collinear
function Orientation(p, q, r)
    local val = (q.y - p.y) * (r.x - q.x) - (q.x - p.x) * (r.y - q.y)
    if val == 0 then
        return 0 -- Collinear
    elseif val > 0 then
        return 1 -- Clockwise
    else
        return 2 -- Counterclockwise
    end
end

function OrientationWithRadius(p, q, r)
    local val = ((q.y - q.radius) - (p.y - p.radius)) * ((r.x - r.radius) - (q.x - q.radius)) - ((q.x - q.radius) - (p.x - p.radius)) * ((r.y - r.radius) - (q.y - q.radius))
    if val == 0 then
        return 0 -- Collinear
    elseif val > 0 then
        return 1 -- Clockwise
    else
        return 2 -- Counterclockwise
    end
end


-- Gift wrapping function using Chan's algorithm
function GiftWrapping(points)
    local n = #points
    if n < 3 then
        return points -- Invalid input, need at least 3 points
    end

    -- Find the leftmost point
    local leftmost = 1
    for i = 2, n do
        if (points[i].x - points[i].radius) < (points[leftmost].x - points[leftmost].radius) then
            leftmost = i
        elseif (points[i].x - points[i].radius) == (points[leftmost].x - points[leftmost].radius) and (points[i].y - points[i].radius) < (points[leftmost].y - points[leftmost].radius) then
            leftmost = i
        end
    end

    -- Initialize the result list and current point
    local hull = {}
    local p = leftmost
    local q
    local counter = 0
    local maxIterations = n*n
    repeat
        -- Add the current point to the hull
        table.insert(hull, points[p])

        -- Find the next point on the hull
        q = (p % n) + 1
        for i = 1, n do
            -- Check if points[i] is more counterclockwise than the current q
            if OrientationWithRadius(points[p], points[i], points[q]) == 2 then
                q = i
            end
        end
        
        p = q
        counter = counter + 1
    if counter >= maxIterations then
        break -- Break out of the loop
    end
    until p == leftmost

    return hull
end

function ReverseTable(tbl)
    local reversed = {}
    local n = #tbl

    for i = n, 1, -1 do
        table.insert(reversed, tbl[i])
    end

    return reversed
end


function LogCoordsToFile(points)
    for point = 1, #points do
        LogToFile("Coord " .. point)
        LogToFile("{ x = " .. points[point].x .. ", y = " .. points[point].y .. "}")
    end
end

function PushOutTracks(polygon)
    local newPolygon = {}
    local count = #polygon
    for i = 1, count do

        local pointA = polygon[i]
        local pointB = polygon[i % count + 1]
        
        local dir = Vec3(pointB.x - pointA.x, pointB.y - pointA.y)
        local normal = PerpendicularVector(NormalizeVector(dir))
        
        local newPosA = Vec3(pointA.x + normal.x * pointA.radius, pointA.y + normal.y * pointA.radius)
        local newPosB = Vec3(pointB.x + normal.x * pointB.radius, pointB.y + normal.y * pointB.radius)
        
        local segment = {posA = newPosA, posB = newPosB, wheelPosA = pointA, wheelPosB = pointB, radiusA = pointA.radius, radiusB = pointB.radius}
        table.insert(newPolygon, segment)
    end
    return newPolygon
end

--TRACK GROUPING


function TrackContextMenu(saveName)
    for k, size in pairs(WHEEL_SAVE_NAMES) do
        if CheckSaveNameTable(saveName, size) then
            AddContextButton("hud-context-blank", CurrentLanguage.WheelGroupText, 3, true, false)
            for i = 1, 10 do
                AddContextButton("hud-context-blank", CurrentLanguage.TrackGroupText .. i, 3, true, false)
            end
        end
    end
end

function TrackContextButton(name, deviceId)
    for i = 1, 10 do
        if name == CurrentLanguage.TrackGroupText .. i then
            SendScriptEvent("UpdateTrackGroups", deviceId .. "," .. i, "", false)
        end
    end
    if name == CurrentLanguage.WheelGroupText then
        SendScriptEvent("UpdateTrackGroups", deviceId .. ",11", "", false)
    end

end


function UpdateTrackGroups(deviceId, group)
    data.trackGroups[deviceId] = group
end



