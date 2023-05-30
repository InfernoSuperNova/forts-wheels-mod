--helperDebug.lua
--- forts script API ---
function HighlightCoords(coords)
    for k, coord in pairs(coords) do
        SpawnCircle(coord, 50, { r = 255, g = 100, b = 100, a = 255 }, data.updateDelta)
    end
end

function HighlightPolygon(coords)
    for coord = 1, #coords do
        SpawnCircle(coords[coord], 50, { r = 255, g = 100, b = 100, a = 255 }, data.updateDelta)
        SpawnLine(coords[coord], coords[coord % #coords + 1], {r = 255, g = 255, b = 255, a = 255}, data.updateDelta)
    end
end

---Highlights a vector with a position, direction, and optional magnitude
---@param pos Vector2D the position
---@param direction Vector2D the direction (and magnitude)
function HighlightDirectionalVector(pos, direction)

    local pos2 = {x = pos.x + direction.x * 50, y = pos.y + direction.y * 50}
    SpawnLine(pos, pos2, {r = 255, g = 255, b = 255, a = 255}, 0.04)
    SpawnCircle(pos, Distance(pos, pos2) / 5, {r = 255, g = 255, b = 255, a = 255}, 0.04)
end


function ToggleCollisionDebug()
    ModDebug.collision = not ModDebug.collision
    if ModDebug.collision then
        EnableTerrainDebug()
    else
        DisableTerrainDebug()
    end
end
function ToggleUpdateDebug()
    ModDebug.update = not ModDebug.update
end
function ClearDebugControls()
        DeleteControl("", "debugControl")  
end

function DebugLog(string)
    if ModDebug.update then 
        DebugText = DebugText .. string .. "\n"
    end 
end
function DebugUpdate()
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
    AddTextControl("", "terrainStat1", "", ANCHOR_TOP_LEFT, {x = 550, y = 15}, false, "")
    AddTextControl("", "terrainStat2", "", ANCHOR_TOP_LEFT, {x = 550, y = 30}, false, "")
    AddTextControl("", "terrainStat3", "", ANCHOR_TOP_LEFT, {x = 550, y = 45}, false, "")
end

function EnableTerrainDebug()
    SetControlText("", "terrainStat1", "Largest block: " .. BlockStatistics.largestBlock)
    SetControlText("", "terrainStat2", "Total vertex count: " .. BlockStatistics.totalNodes)
    SetControlText("", "terrainStat3", "Total block count: " .. BlockStatistics.totalBlocks)
end
function DisableTerrainDebug()
    SetControlText("", "terrainStat1", "")
    SetControlText("", "terrainStat2", "")
    SetControlText("", "terrainStat3", "")
end