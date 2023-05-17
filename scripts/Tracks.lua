--Tracks.lua
function InitializeTracks()
    data.trackGroups = {}
end

function UpdateTracks()
    ClearEffects()
    DebugLog("Clear effects good")
    FillTracks()
    DebugLog("Fill tracks good")
    SortTracks()
    DebugLog("Sort tracks good")
    GetTrackSetPositions()
    DebugLog("GetTrackSetPositions good")
    DrawTracks()
    DebugLog("Draw tracks good")
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
            DebugLog(Displacement)
            if not Tracks[structureId] then Tracks[structureId] = {} end
            if not Tracks[structureId][trackGroup] then Tracks[structureId][trackGroup] = {} end
            local suspensionPos = {
                x = actualPos.x + Displacement[id].x,
                y = actualPos.y + Displacement[id].y,
            }
            --SpawnCircle(suspensionPos, WheelRadius, { r = 255, g = 255, b = 255, a = 255 }, 0.04)
            if not TracksId[structureId] then TracksId[structureId] = {} end
            TracksId[structureId][id] = suspensionPos

            table.insert(Tracks[structureId][trackGroup], suspensionPos)
        end
    end
end

function SortTracks()
    for structure, trackSets in pairs(Tracks) do
        if not PushedTracks[structure] then PushedTracks[structure] = {} end
        for trackGroup, trackSet in pairs(trackSets) do
            if not SortedTracks[structure] then SortedTracks[structure] = {} end
            --Don't do unnecessary track calculations if the wheel is a wheel
            if trackGroup ~= 11 then
                SortedTracks[structure][trackGroup] = JarvisWrapping(trackSet)
                DebugLog("Jarvis wrapping good")
                
                PushedTracks[structure][trackGroup] = PushOutTracks(SortedTracks[structure][trackGroup], WheelRadius)
                DebugLog("Track pushing good")
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
        for trackGroup, trackSet in pairs(trackSets) do
            DrawTrackTreads(trackSet, base, trackGroup)
            DrawTrackSprockets(base, trackGroup)
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
        if #trackSet > 2 then
            DrawTrackTreadsRound(center, trackSet[(wheel - 3) % #trackSet + 1], trackSet[wheel - 1], base)
        end
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

function JarvisWrapping(points)
    -- Check if all points have the same Y level
    local same_y_level = true
    local y_level = points[1].y
    for i = 2, #points do
        if points[i].y ~= y_level then
            same_y_level = false
            break
        end
    end

    -- If all points have the same Y level, sort by X value to find leftmost point
    if same_y_level then
        table.sort(points, function(a, b) return a.x < b.x end)
        return points
    end

    -- Otherwise, find the leftmost point as before
    local leftmost_index = 1
    local leftest_value = points[1].x or 0
    for point = 2, #points do
        if points[point] and points[point].x and points[point].x > leftest_value then
            leftest_value = points[point].x
            leftmost_index = point
        end
    end
    for i = 2, #points do
        if points[i].x < points[leftmost_index].x then
            leftmost_index = i
        end
    end

    -- Find the hull points as before
    local hull_points = {}
    local current_point = leftmost_index
    local loopCount = 1
    repeat
        table.insert(hull_points, points[current_point])
        local next_point = 1
        local farthest_point = next_point
        for i = 1, #points do
            if i ~= current_point and i ~= next_point then
                local cross_product = (points[i].x - points[current_point].x) *
                    (points[next_point].y - points[current_point].y) -
                    (points[i].y - points[current_point].y) * (points[next_point].x - points[current_point].x)
                if next_point == current_point or cross_product < 0 or (cross_product == 0 and Distance(points[i], points[current_point]) > Distance(points[farthest_point], points[current_point])) then
                    next_point = i
                    farthest_point = i
                end
            end
        end
        current_point = next_point
        --Prevents an infinite loop if it were to happen (input length ^ 2 + 1 is max complexity)
        if loopCount == math.pow(#points, 2) + 1 then
            return hull_points
        end
        loopCount = loopCount + 1
    until current_point == leftmost_index
    return hull_points
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
