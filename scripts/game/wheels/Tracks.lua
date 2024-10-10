--Tracks.lua
function InitializeTracks()
    data.trackGroups = {}
end

function UpdateTracks(frame)

    -- local lineSegment = {Vec3(-30000, -2500), Vec3(-2700, -4250)}

    -- local subdivsion = SubdivideLineSegment(lineSegment[1], lineSegment[2], 100, frame)

    -- SpawnCircle(lineSegment[1], 100, Red(), 0.04)
    -- SpawnCircle(lineSegment[2], 100, Red(), 0.04)
    -- for i = 1, #subdivsion do
    --     SpawnCircle(subdivsion[i], 50, Blue(), 0.04)
    -- end

    -- BetterLog(100 - subdivsion.remainder)

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
    for _, device in pairs(data.devices) do
        PlaceSuspensionPosInTable(device)
    end
end

function PlaceSuspensionPosInTable(device)
    
    if DeviceExists(device.id) 
    and 
    (IsWheelDevice(device.saveName)
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
            suspensionPos.deviceId = device.id
            suspensionPos.teamId = device.team
            table.insert(Tracks[structureId][trackGroup], suspensionPos)
        end
    end
end

function SortTracks()
    if ReducedVisuals then PushedTracks = Tracks return end
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
                local teamId = Tracks[base][trackGroup][1].teamId
                DrawTrackTreads(trackSet, base, trackGroup, teamId)
                DrawTrackSprockets(base, trackGroup)
            end
        end
    end
end

function DrawTrackSprockets(base, trackGroup)
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
            local effect = SpawnEffectEx(effectPath, pos, vecAngle)
            table.insert(LocalEffects, effect)
        end
    else
        for device, pos in pairs(Tracks[base][trackGroup]) do
            local radius = 75
            if CheckSaveNameTable(pos.saveName, WHEEL_SAVE_NAMES.large) then radius = 150 end
            if CheckSaveNameTable(pos.saveName, WHEEL_SAVE_NAMES.extraLarge) then radius = 250 end
            SpawnCircle(pos, radius, { r = 255, g = 255, b = 255, a = 255 }, 0.06)
        end
    end
end

function DrawTrackTreads(trackSet, base, trackGroup, teamId)
    if ReducedVisuals then return end
    --exclude wheels
    if trackGroup == 11 then return end
    

    BetterLog(trackSet)
    local points = {}
    local previousRemainder = -TrackOffsets[base].x % TRACK_LINK_DISTANCE or 0
    for wheel = 1, #trackSet, 1 do
        local remainder = previousRemainder
        SpawnCircle(trackSet[wheel], 50, { r = 255, g = 0, b = 0, a = 255 }, 0.06)
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



