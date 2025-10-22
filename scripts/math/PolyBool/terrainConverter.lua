function TerrainToPolygon(block)
    local poly = {}
    for i = 0, #block do
        local pos = block[i]
        poly[#poly+1] = pos.x
        poly[#poly+1] = pos.y
    end
    return poly
end

function TerrainToPolygons(blocks)
    local polygons = {}
    for i = 1, #blocks do
        polygons[#polygons+1] = TerrainToPolygon(blocks[i])
    end
    return polygons
end

function PolygonToTerrain(poly)
    local block = {}
    for i = 1, #poly, 2 do
        block[#block+1] = {x = poly[i], y = poly[i+1]}
    end
    return block
end


function UnionAllTerrain(blocks)

    local polygons = TerrainToPolygons(blocks)
    local changed = true

    while changed do
        changed = false
        local new_polygons = {}
        local skip = {}

        for i = 1, #polygons do
            if skip[i] then continue end
            local a = polygons[i]
            local merged = false

            for j = i + 1, #polygons do
                if skip[j] then continue end
                local b = polygons[j]
                local success, result = TryUnion(a, b)

                if success then
                    table.insert(new_polygons, result)
                    skip[i] = true
                    skip[j] = true
                    changed = true
                    merged = true
                    break
                end

            end

            if not merged and not skip[i] then
                table.insert(new_polygons, a)
            end
        end

        polygons = new_polygons
    end

    BetterLog(polygons)
    
    local newBlocks = PolygonToTerrain(polygons)
    BetterLog(newBlocks)
    return newBlocks
end

function UnionAllTerrain(blocks)
    local polygons = TerrainToPolygons(blocks)
    local result = PolyMan.operations.boolean(polygons[1], polygons[2], "or")
    BetterLog(polygons)
    BetterLog(result)


end

function TryUnion(a, b)

    local result = PolyMan.operations.boolean(a, b, "or")

    return #result <= 1, result[1]
end


function PointsMatch(b1,b2)
    if #b1 ~= #b2 then return false end

    for i = 1, #b1 do
        if b1[i] ~= b2[i] then return false end
    end
    return true
end