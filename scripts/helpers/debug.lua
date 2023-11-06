--helperDebug.lua
--- forts script API ---


function HighlightCoords(coords)
    for k, coord in pairs(coords) do
        SpawnCircle(coord, 50, { r = 255, g = 100, b = 100, a = 255 }, data.updateDelta)
    end
end

function HighlightPolygon(coords, colour1)
    if not colour1 then colour1 = {r = 255, g = 255, b = 255, a = 255} end
    local newCoords = FlattenTable(coords)
    for coord = 1, GetHighestIndex(newCoords) do
        --SpawnCircle(coords[coord], 50, colour1, data.updateDelta)
        SpawnLine(newCoords[coord], newCoords[coord % #newCoords + 1], colour1, data.updateDelta)
    end
end

function HighlightPolygonWithDisplacement(coords, displacement, colour1)
    local newCoords = {}
    for index = 1, GetHighestIndex(coords) do
        local coord = coords[index]
        if coord and coord.x then
            newCoords[index] = {x = coord.x + displacement.x, y = coord.y + displacement.y}
        end
    end
    HighlightPolygon(newCoords, colour1)
end

function HighlightCoordsTextWithDisplacement(coords, displacement, colour1)
    SetControlFrame(1)
    for index, pos in pairs(coords) do 
        local name = "blockDebug" .. index
        local newPos = {x = pos.x + displacement.x, y = pos.y + displacement.y, z = -10}
        AddTextControl("worldBlockDebug", name, index .. "", ANCHOR_TOP_LEFT, newPos, true, "Result")
        table.insert(ScheduledDeleteControls, name)
    end
end

--I'm pretty sure this isn't what FlattenTable means. But screw you.
function FlattenTable(tbl) 
    local newTable = {}
    for i = 1, GetHighestIndex(tbl) do
        table.insert(newTable, tbl[i])
    end
    return newTable
end
---Highlights a vector with a position, direction, and optional magnitude
---@param pos Vector2D the position
---@param direction Vector2D the direction (and magnitude)
---@param mag number the magnitude
---@param col Colour the colour
function HighlightDirectionalVector(pos, direction, mag, col)
    col = col or {r = 255, g = 255, b= 255, a = 255}
    local pos2 = {x = pos.x + direction.x * mag, y = pos.y + direction.y * mag, z = -10}
    SpawnLine(pos, pos2, col, 0.04)
    SpawnCircle(pos, Distance(pos, pos2) / 5, col, 0.04)
end


function ToggleCollisionDebug()
    ModDebug.collision = not ModDebug.collision
    if ModDebug.collision then
        EnableTerrainDebug()
    else
        DisableTerrainDebug()
    end
    Notice("Collision debug: " .. tostring(ModDebug.collision))
end
function ToggleUpdateDebug()
    ModDebug.update = not ModDebug.update
    Notice("Update debug: " .. tostring(ModDebug.update))
end
function ToggleForcesDebug()
    ModDebug.forces = not ModDebug.forces
    Notice("Forces debug: " .. tostring(ModDebug.forces))
end
function ClearDebugControls()
    SetControlFrame(0)
        DeleteControl("", "debugControl")  
end

function ClearTerrainDebugControls()
    SetControlFrame(1)
    for _, id in pairs (ScheduledDeleteControls) do
        DeleteControl("worldBlockDebug", id)
    end
    ScheduledDeleteControls = {}
end
function DebugLog(string)
    if ModDebug.update then 
        DebugText = DebugText .. string .. "\n"
    end 
end
function DebugUpdate()
    SetControlFrame(0)

    local mpos = GetMousePos()
    DebugLog(string.format("Mouse: %.2f, %.2f", mpos.x, mpos.y))

    DebugLog("Press Ctrl + Alt + T to hide")
    if not ControlExists("root", "debugControl") then
        AddTextControl("", "debugControl", "", ANCHOR_TOP_RIGHT, {x = 1050, y = 0}, false, "Console")
    end

    
    local lines = SplitLines(DebugText)
    for i = 1, #lines do
        local text = lines[i]
        
        
        if not ControlExists("debugControl", "debugLine" .. i) then
            AddTextControl("debugControl", "debugLine" .. i, text, ANCHOR_TOP_RIGHT, {x = 0, y = 0 + 9 * i}, false, "Readout")
        else
            SetControlText("debugControl", "debugLine" .. i, text)
        end
        
    end
    
    
    DebugText = ""
end

function SplitStringAtPosition(inputString, position)
    local firstPart = string.sub(inputString, 1, position)
    local secondPart = string.sub(inputString, position + 1)
    return { firstPart, secondPart }
end

function CheckCharacterAtPosition(inputString, position)
    local character = string.sub(inputString, position, position)
    return character
end

function ParseColorString(colorString)
    local colorTable = {}

    -- Extracting the numerical values using pattern matching
    local r, g, b, a = colorString:match("r = (%d+), g = (%d+), b = (%d+), a = (%d+)")

    -- Converting the values to numbers and storing in the table
    colorTable.r = tonumber(r)
    colorTable.g = tonumber(g)
    colorTable.b = tonumber(b)
    colorTable.a = tonumber(a)

    return colorTable
end
function InitializeTerrainBlockSats()
    for i = 1, 4 do
        AddTextControl("", "terrainStat" .. i, "", ANCHOR_TOP_LEFT, {x = 200, y = 9 * i}, false, "Readout")
    end
end

function EnableTerrainDebug()
    local largestBlock
    if BlockStatistics.largestBlock > 20 then 
        largestBlock = BlockStatistics.largestBlock .. " WARNING: There are too many nodes in this block! Consider splitting it into smaller blocks"
    else
        largestBlock = BlockStatistics.largestBlock
    end
    SetControlText("", "terrainStat1", "Largest block: " .. largestBlock)
    SetControlText("", "terrainStat2", "Total vertex count: " .. BlockStatistics.totalNodes)
    SetControlText("", "terrainStat3", "Total block count: " .. BlockStatistics.totalBlocks)
    SetControlText("", "terrainStat4", "Press Ctrl + Alt + D to hide")
end
function DisableTerrainDebug()
    SetControlText("", "terrainStat1", "")
    SetControlText("", "terrainStat2", "")
    SetControlText("", "terrainStat3", "")
    SetControlText("", "terrainStat4", "")
end

function DebugHighlightTerrain(frame)
    if ModDebug.collision == true then
        for index, boundary in pairs(data.terrainCollisionBoxes) do
            local colour1 = { r = 255, g = 255, b = 255, a = 255 }
            local colour2 = { r = 150, g = 150, b = 150, a = 255 }
            SpawnCircle(boundary, boundary.r, colour1, 0.04)
            HighlightPolygon(boundary.square, colour2)
            HighlightPolygon(Terrain[index], colour2)
        end
    end
end
