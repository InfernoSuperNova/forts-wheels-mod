--Tracks.lua
function InitializeTracks()
    data.trackGroups = {}
end

function UpdateTracks()
    DebugLog("---------Start of UpdateTracks---------")
    local prevTime = GetRealTime()
    ClearEffects()
    local delta = GetRealTime() - prevTime
    DebugLog("  Clear effects took " .. delta .. "s")
    prevTime = GetRealTime()
    FillTracks()
    delta = GetRealTime() - prevTime
    DebugLog("  Fill tracks took " .. delta .. "s")
    prevTime = GetRealTime()
    SortTracks()
    delta = GetRealTime() - prevTime
    DebugLog("  Sort tracks took " .. delta .. "s")
    prevTime = GetRealTime()
    GetTrackSetPositions()
    delta = GetRealTime() - prevTime
    DebugLog("  GetTrackSetPositions took " .. delta .. "s")
    prevTime = GetRealTime()
    DrawTracks()
    delta = GetRealTime() - prevTime
    DebugLog("  Draw tracks took " .. delta .. "s")
    DebugLog("---------End of UpdateTracks---------\n")
end

function TrueUpdateTracks()
    Displacement = {}
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
    for side = 1, 2 do
        --get the count of devices on a side
        local count = GetDeviceCountSide(side)
        for device = 0, count do
            local id = GetDeviceIdSide(side, device)
            PlaceSuspensionPosInTable(id)
        end
    end
end

function PlaceSuspensionPosInTable(id)
    if DeviceExists(id) and CheckSaveNameTable(GetDeviceType(id), WheelSaveName) and IsDeviceFullyBuilt(id) then
        if not data.trackGroups[id] then data.trackGroups[id] = 1 end
        local trackGroup = data.trackGroups[id]
        local actualPos = WheelPos[id]
        if actualPos.x < LocalScreen.MaxX + 500 and actualPos.x > LocalScreen.MinX - 500 then

            --get the structure that the track set belongs to
            local structureId = GetDeviceStructureId(id)
            --local actualPos = WheelPos[id]
            --put it into a table unique to that structure...
            if not Tracks[structureId] then Tracks[structureId] = {} end
            if not Tracks[structureId][trackGroup] then Tracks[structureId][trackGroup] = {} end
            local suspensionPos = actualPos
            if Displacement[id] then
                suspensionPos = {
                    x = actualPos.x + Displacement[id].x,
                    y = actualPos.y + Displacement[id].y,
                }
            end
            
            --SpawnCircle(suspensionPos, WheelRadius, { r = 255, g = 255, b = 255, a = 255 }, 0.04)
            if not TracksId[structureId] then TracksId[structureId] = {} end
            TracksId[structureId][id] = suspensionPos

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


                
                local prevTime = GetRealTime()
                SortedTracks[structure][trackGroup] = ReverseTable(GiftWrapping(trackSet))
                local delta = GetRealTime() - prevTime
                DebugLog("gift wrapping took " .. delta .. "s")
                
                prevTime = GetRealTime()
                PushedTracks[structure][trackGroup] = PushOutTracks(SortedTracks[structure][trackGroup], WheelRadius)
                delta = GetRealTime() - prevTime
                DebugLog("Track pushing took " .. delta .. "s")
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
    local effectPath
    local angle
    --trackgroup of 11 represents wheel
    if trackGroup == 11 then
        angle = (TrackOffsets[base].x / WheelRadius) * (WheelRadius - TrackWidth)

        effectPath = path .. "/effects/wheel.lua"
    else
        angle = TrackOffsets[base].x
        effectPath = path .. "/effects/track_sprocket.lua"
    end

    for device, pos in pairs(Tracks[base][trackGroup]) do
        local vecAngle = AngleToVector(angle)
        local effect = SpawnEffectEx(effectPath, pos, vecAngle)
        table.insert(LocalEffects, effect)
    end
end

function DrawTrackTreads(trackSet, base, trackGroup)
    --exclude wheels
    if trackGroup == 11 then return end
    --loop through segments of the tracks
    for wheel = 1, #trackSet, 2 do
        --Only if there's more than 2 points (1 wheel) in set
        if #trackSet > 2 then
            DrawTrackTreadsFlat(trackSet, wheel, base)
        end
    end
    for wheel = 2, #trackSet, 2 do
        local index = (wheel / 2 - 1) % #SortedTracks[base][trackGroup] + 1
        local center = SortedTracks[base][trackGroup][index]
        
        DrawTrackTreadsRound(center, trackSet[(wheel - 3) % #trackSet + 1], trackSet[wheel - 1], base)

            

        

    end
end

function DrawTrackTreadsRound(center, track1, track2, base)
    --HighlightPolygon({center, track1, track2})
    local offset = TrackOffsets[base].x % TrackLinkDistance
    local offset_length = offset / WheelRadius * 1.2

    local arc = PointsAroundArc(center, WheelRadius, track2, track1, TrackLinkDistance, offset_length)




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

    local points = SubdivideLineSegment(trackSet[wheel], trackSet[wheel % #trackSet + 1], TrackLinkDistance,
        -TrackOffsets[correspondingDevice].x % TrackLinkDistance)
    --loop through points on the track
    for point = 1, #points do
        SpawnEffectEx(path .. "/effects/track.lua", points[point], angle)

        if points[point + 1] then
            local newPos = AverageCoordinates({ points[point], points[point + 1] })
            SpawnEffectEx(path .. "/effects/track_link.lua", newPos, angle)
        end
        --SpawnCircle(point, 5, { r = 255, g = 255, b = 255, a = 255 }, 0.05)
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

function PushOutTracks(polygon, distance)
    local newPolygon = {}
    local count = #polygon
    for i = 1, count do
        local j = i % count + 1
        local dx = polygon[j].x - polygon[i].x
        local dy = polygon[j].y - polygon[i].y
        local len = math.sqrt(dx * dx + dy * dy)
        dx = dx / len
        dy = dy / len
        local nx = -dy -- negate the normal vector
        local ny = dx  -- negate the normal vector
        local x1 = polygon[i].x + nx * distance
        local y1 = polygon[i].y + ny * distance
        local x2 = polygon[j].x + nx * distance
        local y2 = polygon[j].y + ny * distance
        table.insert(newPolygon, { x = x1, y = y1 })
        table.insert(newPolygon, { x = x2, y = y2 })
    end
    return newPolygon
end

--TRACK GROUPING

function OnContextMenuDevice(deviceTeamId, deviceId, saveName)
    if CheckSaveNameTable(saveName, WheelSaveName) then
        AddContextButton("hud-context-blank", "Set suspension to wheel", 3, true, false)
        for i = 1, 10 do
            AddContextButton("hud-context-blank", "Set suspension to track group " .. i, 3, true, false)
        end
    end
end

function OnContextButtonDevice(name, deviceTeamId, deviceId, saveName)
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
