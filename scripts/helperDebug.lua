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
