--Tracks.lua
function InitializeTracks()
    data.trackGroups = {}
end

function UpdateTracks(frame)
    -- DebugLog("---------Start of UpdateTracks---------")
    -- UpdateFunction("ClearEffects", frame)
    -- UpdateFunction("FillTracks", frame)
    -- UpdateFunction("SortTracks", frame)
    -- UpdateFunction("GetTrackSetPositions", frame)
    -- UpdateFunction("DrawTracks", frame)
    -- DebugLog("---------End of UpdateTracks---------\n")

    ClearEffects()
    FillTracks()
    SortTracks()
    GetTrackSetPositions()
    DrawTracks()
end

function TrueUpdateTracks()
    
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
    for _, device in pairs(Devices) do
        PlaceSuspensionPosInTable(device)
    end
end

function PlaceSuspensionPosInTable(device)
    
    if DeviceExists(device.id) 
    and 
    (CheckSaveNameTable(device.saveName, WHEEL_SAVE_NAMES.small) 
    or CheckSaveNameTable(device.saveName, WHEEL_SAVE_NAMES.medium) 
    or CheckSaveNameTable(device.saveName, WHEEL_SAVE_NAMES.large) 
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
            --bad coding practices, don't do this kids
            suspensionPos.radius = GetWheelStats(device).radius
            suspensionPos.saveName = device.saveName
            if not TracksId[structureId] then TracksId[structureId] = {} end
            TracksId[structureId][device.id] = suspensionPos

            table.insert(Tracks[structureId][trackGroup], suspensionPos)
        end
    end
end

function SortTracks()
    for structure, trackSets in pairs(Tracks) do
        local team = GetStructureTeam(structure)
        if not PushedTracks[structure] then PushedTracks[structure] = {} end
        for trackGroup, trackSet in pairs(trackSets) do
            if not SortedTracks[structure] then SortedTracks[structure] = {} end
            --Don't do unnecessary track calculations if the wheel is a wheel
            if trackGroup ~= 11 and not IsCommanderAndEnemyActive("phantom", team) then
                

                

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

function DrawTracks()


    --loop through list of track sets
    for base, trackSets in pairs(PushedTracks) do
        local team = GetStructureTeam(base)
            --hide tracks on phantom
        if not IsCommanderAndEnemyActive("phantom", team) then
            for trackGroup, trackSet in pairs(trackSets) do
                DrawTrackTreads(trackSet, base, trackGroup)
                DrawTrackSprockets(base, trackGroup)
            end
        end
    end
end

function DrawTrackSprockets(base, trackGroup)
    local wheelType
    local angle
    --trackgroup of 11 represents wheel
    if trackGroup == 11 then
        angle = (TrackOffsets[base].x / WHEEL_RADIUS) * (WHEEL_RADIUS - TRACK_WIDTH)

        wheelType = "wheel"
    else
        angle = TrackOffsets[base].x
        wheelType = "sprocket"
    end

    for device, pos in pairs(Tracks[base][trackGroup]) do
        local effectPath = path .. GetWheelEffectPath(wheelType, pos.saveName)
        local newAngle = angle
        if CheckSaveNameTable(pos.saveName, WHEEL_SAVE_NAMES.large) then
            newAngle = newAngle / 2.5
        end
        local vecAngle = AngleToVector(newAngle)
        local effect = SpawnEffectEx(effectPath, pos, vecAngle)
        table.insert(LocalEffects, effect)
    end
end

function DrawTrackTreads(trackSet, base, trackGroup)
    --exclude wheels
    if trackGroup == 11 then return end
    --loop through segments of the tracks
    for wheel = 2, #trackSet, 2 do
        --Only if there's more than 2 points (1 wheel) in set
        if #trackSet > 2 then
            DrawTrackTreadsFlat(trackSet, wheel, base)
        end
    end
    for wheel = 2, #trackSet, 2 do
        local index = (wheel / 2 - 1) % #SortedTracks[base][trackGroup] + 1
        local center = SortedTracks[base][trackGroup][index]
        DrawTrackTreadsRound(center, trackSet[(wheel - 2) % #trackSet + 1], trackSet[wheel], base)
    end
end

function DrawTrackTreadsRound(center, track1, track2, base)
    local offset = TrackOffsets[base].x % TRACK_LINK_DISTANCE
    local offset_length = offset / track1.radius * 1.2

    local arc = PointsAroundArc(center, track1.radius, track2, track1, TRACK_LINK_DISTANCE, offset_length)




    for point = 1, #arc do
        SpawnEffectEx(path .. "/effects/track.lua", arc[point], GetPerpendicularVectorAngle(arc[point], center))
        if arc[point + 1] then
            local newPos = AverageCoordinates({ arc[point], arc[point + 1] })
            SpawnEffectEx(path .. "/effects/track_link.lua", newPos, GetPerpendicularVectorAngle(newPos, center))
        end
    end
end

function DrawTrackTreadsFlat(trackSet, wheel, correspondingDevice)
    local angle = GetAngleVector(trackSet[wheel], trackSet[wheel % #trackSet + 1])

    local points = SubdivideLineSegment(trackSet[wheel], trackSet[wheel % #trackSet + 1], TRACK_LINK_DISTANCE,
        -TrackOffsets[correspondingDevice].x % TRACK_LINK_DISTANCE)
    --loop through points on the track
    for point = 1, #points do
        SpawnEffectEx(path .. "/effects/track.lua", points[point], angle)

        if points[point + 1] then
            local newPos = AverageCoordinates({ points[point], points[point + 1] })
            SpawnEffectEx(path .. "/effects/track_link.lua", newPos, angle)
        end
    end
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

-- Gift wrapping function using Chan's algorithm
function GiftWrapping(points)
    local n = #points
    if n < 3 then
        return points -- Invalid input, need at least 3 points
    end

    -- Find the leftmost point
    local leftmost = 1
    for i = 2, n do
        if points[i].x < points[leftmost].x then
            leftmost = i
        elseif points[i].x == points[leftmost].x and points[i].y < points[leftmost].y then
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
            if Orientation(points[p], points[i], points[q]) == 2 then
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
        local prev = (i - 2 + count) % count + 1
        local next = i % count + 1
        local perpPrev = GetPerpendicularVectorAngle(polygon[prev], polygon[i])
        local perpNext = GetPerpendicularVectorAngle(polygon[i], polygon[next])
        local x1 = polygon[i].x + perpPrev.x * polygon[i].radius
        local y1 = polygon[i].y + perpPrev.y * polygon[i].radius
        local x2 = polygon[i].x + perpNext.x * polygon[i].radius
        local y2 = polygon[i].y + perpNext.y * polygon[i].radius
        table.insert(newPolygon, { x = x1, y = y1, radius = polygon[i].radius })
        table.insert(newPolygon, { x = x2, y = y2, radius = polygon[i].radius })
    end
    return newPolygon
end

--TRACK GROUPING


function TrackContextMenu(saveName)
    for k, size in pairs(WHEEL_SAVE_NAMES) do
        if CheckSaveNameTable(saveName, size) then
            AddContextButton("hud-context-blank", "Set suspension to wheel", 3, true, false)
            for i = 1, 10 do
                AddContextButton("hud-context-blank", "Set suspension to track group " .. i, 3, true, false)
            end
        end
    end
end

function TrackContextButton(name, deviceId)
    for i = 1, 10 do
        if name == "Set suspension to track group " .. i then
            SendScriptEvent("UpdateTrackGroups", deviceId .. "," .. i, "", false)
        end
    end
    if name == "Set suspension to wheel" then
        SendScriptEvent("UpdateTrackGroups", deviceId .. ",11", "", false)
    end

end


function UpdateTrackGroups(deviceId, group)
    data.trackGroups[deviceId] = group
end



