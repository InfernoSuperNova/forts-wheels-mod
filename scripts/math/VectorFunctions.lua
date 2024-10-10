--VectorFunctions.lua
--- forts script API ---

-- Scale a vector by a factor
---@param vector{x:number, y:number} The vector to scale
---@param factor number The factor to scale by
---@return {x:number, y:number}
function ScaleVector(vector, factor)
    return { x = vector.x * factor, y = vector.y * factor }
end

-- Add two vectors
---@param vector1 {x:number, y:number} Vector one to add
---@param vector2 {x:number, y:number} Vector two to add
---@return {x:number, y:number}
function AddVectors(vector1, vector2)
    return { x = vector1.x + vector2.x, y = vector1.y + vector2.y }
end

-- Subtract one vector from another
---@param vector1 {x:number, y:number} Vector one to add
---@param vector2 {x:number, y:number} Vector two to add
---@return {x:number, y:number}
function SubtractVectors(vector1, vector2)
    return Vec3(vector1.x - vector2.x, vector1.y - vector2.y)
end

-- Normalize a vector
---@param vector {x:number, y:number} Vector to normalize
---@return {x:number, y:number}
function NormalizeVector(vector)
    local length = ((vector.x) ^ 2 + (vector.y) ^ 2) ^ 0.5
    return Vec3(vector.x / length, vector.y / length)
end

-- Find the closest edge of a polygon to a point
---@param point {x:number, y:number} The position of the point to check from
---@param polygon {table:{x:number, y:number}} Table of positions representing polygon
---
function FindClosestEdge(point, polygon)
    local closestEdge = nil
    local closestDistance = 10e11
    for i = 1, #polygon do
        local j = i % #polygon + 1
        if j < i then continue end
        local edgeStart, edgeEnd = polygon[i], polygon[j]
        
        edgeStart.z = -100
        edgeEnd.z = -100
        local closestPoint = ClosestPointOnLineSegment(point, edgeStart, edgeEnd)
        local distance = Distance(point, closestPoint)
        if distance < closestDistance then
            closestEdge, closestDistance = { edgeStart = edgeStart, edgeEnd = edgeEnd }, distance
        end
    end
    return { closestEdge = closestEdge, closestDistance = closestDistance }
end
-- Find the closest distance of a reference and 2 points

function ClosestDistanceOfTwoPoints(reference, point1, point2)
    local closest = ClosestPointOnLineSegment(reference, point1, point2)
    return Distance(reference, closest)
end
-- Compute the distance between a point and an edge
function DistanceToEdge(point, edgeStart, edgeEnd)
    local closestPoint = ClosestPointOnLineSegment(point, edgeStart, edgeEnd)
    return Distance(point, closestPoint)
end

-- Compute the perpendicular vector from a point to a vertex
function PerpendicularToVertex(point, vertex)
    local vector = SubtractVectors(vertex, point)
    return NormalizeVector({ x = -vector.y, y = vector.x })
end

function Vec3Lerp(vec1, vec2, t)
    return Vec3(
        vec1.x + (vec2.x - vec1.x) * t,
        vec1.y + (vec2.y - vec1.y) * t,
        vec1.z + (vec2.z - vec1.z) * t
    )
end


--gets a perpendicular angle as a vector
function GetPerpendicularVector(point1, point2)
    local dx = point2.x - point1.x
    local dy = point2.y - point1.y
    local len = math.sqrt(dx * dx + dy * dy)
    dx = dx / len
    dy = dy / len
    return Vec3(dx, dy)
end

--gets a perpendicular angle as a vector
function GetPerpendicularVectorAngle(point1, point2)
    local dx = point2.x - point1.x
    local dy = point2.y - point1.y
    local len = math.sqrt(dx * dx + dy * dy)
    dx = dx / len
    dy = dy / len
    local nx = -dy -- negate the normal vector
    local ny = dx  -- negate the normal vector
    return { x = nx, y = ny }
end

-- Compute the perpendicular vector from a point to an edge
function PerpendicularToEdge(point, edgeStart, edgeEnd)
    local edgeVector = SubtractVectors(edgeEnd, edgeStart)
    local pointVector = SubtractVectors(point, edgeStart)
    local projectionLength = Dot(pointVector, edgeVector) / Dot(edgeVector, edgeVector)
    local projectionVector = ScaleVector(edgeVector, projectionLength)
    local perpendicularVector = SubtractVectors(pointVector, projectionVector)
    return NormalizeVector({ x = -perpendicularVector.y, y = perpendicularVector.x })
end

function PerpendicularVector(vector)
    local nx = -vector.y
    local ny = vector.x
    return Vec3(nx,ny)
end

function VecMagnitude(v)
    return math.sqrt(v.x ^ 2 + v.y ^ 2)
end

function VecMagnitudeDir(v)
    local magnitude = math.sqrt(v.x ^ 2 + v.y ^ 2)
    if v.x < 0 then
        magnitude = -magnitude
    end
    return magnitude
end

function OffsetPerpendicular(p1, p2, offset)
    -- calculate vector between two points
    local V = { x = p2.x - p1.x, y = p2.y - p1.y }

    -- calculate unit vector of V
    local mag = VecMagnitude(V)
    local U = { x = V.x / mag, y = V.y / mag }

    -- calculate vector perpendicular to V
    local perp = { x = -U.y, y = U.x }

    -- scale perpendicular vector by offset distance and add to original point
    local offsetVector = Vec3(perp.x * offset, perp.y * offset)

    return offsetVector
end

--gets the average of a list of co ordinates
function AverageCoordinates(Coords)
    local output = Vec3(0,0)
    if #Coords == 0 then return output end
    for k, coords in pairs(Coords) do
        output.x = output.x + coords.x
        output.y = output.y + coords.y
    end
    output.x = output.x / #Coords
    output.y = output.y / #Coords
    return output
end

function Distance(a, b)
    return math.sqrt((b.x - a.x) ^ 2 + (b.y - a.y) ^ 2)
end

-- Check if a point is inside a polygon using the winding number algorithm.
function PointInsidePolygon(point, polygon)
    local wn = 0
    for i = 1, #polygon do
        local j = i % #polygon + 1
        if (polygon[i].y <= point.y and polygon[j].y > point.y) or
            (polygon[i].y > point.y and polygon[j].y <= point.y) then
            local vt = (point.y - polygon[i].y) / (polygon[j].y - polygon[i].y)
            if point.x < polygon[i].x + vt * (polygon[j].x - polygon[i].x) then
                wn = wn + 1
            end
        end
    end
    return wn % 2 == 1
end

-- Calculate the closest point on a line segment to a point.
function Dot(a, b)
    return a.x * b.x + a.y * b.y
end

function CrossProduct(v1, v2)
    return v1.x * v2.y - v2.x * v1.y
end

function GetAngleVector(point1, point2)
    local dx = point2.x - point1.x
    local dy = point2.y - point1.y
    local len = Distance(point1, point2)
    if len == 0 then
        return { x = 0, y = 0 }
    else
        return { x = dx / len, y = dy / len }
    end
end

function ClosestPointOnLineSegment(p, a, b)
    local ap = { x = p.x - a.x, y = p.y - a.y }
    local ab = { x = b.x - a.x, y = b.y - a.y }
    local abSquaredLength = Dot(ab, ab)
    local t = Dot(ap, ab) / abSquaredLength
    if t < 0 then
        return a
    elseif t > 1 then
        return b
    else
        return { x = a.x + t * ab.x, y = a.y + t * ab.y }
    end
end

function SubdivideLineSegment(startPoint, endPoint, distance, startingOffset)
    local segmentLength = Distance(startPoint, endPoint)
    local directionX = (endPoint.x - startPoint.x) / segmentLength
    local directionY = (endPoint.y - startPoint.y) / segmentLength
    local points = {}

    local t = startingOffset or 0 -- Starting offset
    while t < segmentLength do
        local x = startPoint.x + (t * directionX)
        local y = startPoint.y + (t * directionY)
        table.insert(points, {pos = Vec3(x, y), perp = Vec3(directionX, directionY)})
        t = t + distance
    end
    local remainder = segmentLength - t + distance
    points.remainder = remainder
    return points
end

function SubdivideLineSegmentWithBowing(startPoint, endPoint, distance, startingOffset, bowing)
    local segmentLength = Distance(startPoint, endPoint)
    local directionX = (endPoint.x - startPoint.x) / segmentLength
    local directionY = (endPoint.y - startPoint.y) / segmentLength
    local normal = PerpendicularVector(Vec3(directionX, directionY))
    local points = {}

    local t = startingOffset or 0 -- Starting offset
    while t < segmentLength do
        local x = startPoint.x + (t * directionX)
        local y = startPoint.y + (t * directionY)
        local pos = Vec3(x, y)
        table.insert(points, {pos = pos})
        t = t + distance
    end

    for i = 1, #points do
        local point = points[i]
        local bowSinValue = ((i - 1 + startingOffset / distance) / (#points))
        local bowValue = bowing * math.sin(bowSinValue * math.pi)

        point.pos = point.pos + bowValue * normal
    end
    local remainder = segmentLength - t + distance
    points.remainder = remainder
    return points
end

function rotateVector(vector, angle)
    local x = vector.x
    local y = vector.y
    local x_rotated = x * math.cos(angle) - y * math.sin(angle)
    local y_rotated = x * math.sin(angle) + y * math.cos(angle)
    return Vec3(x_rotated, y_rotated)
end

function PointsAroundArc(center, radius, point1, point2, pointDistance, offset, clockwise)
    local startingDistance =  Distance(point1, point2)
    if startingDistance < pointDistance then
        return { points = { }, remainder = offset + startingDistance }
    end
    local startAngle = math.atan2(point1.y - center.y, point1.x - center.x) + offset / radius
    local endAngle = math.atan2(point2.y - center.y, point2.x - center.x)




    if not clockwise then 
        startAngle = startAngle - pointDistance / radius
    end
    -- Adjust endAngle based on the clockwise parameter
    if clockwise and endAngle < startAngle then
        endAngle = endAngle + 2 * math.pi
    elseif not clockwise and startAngle < endAngle then
        startAngle = startAngle + 2 * math.pi
    end

    local numPoints = math.floor(math.abs(endAngle - startAngle) / (pointDistance / radius))
    
    
    local points = {}

    for i = 0, numPoints do
        local angle = startAngle + (clockwise and i or -i) * (pointDistance / radius)
        local x = center.x + radius * math.cos(angle)
        local y = center.y + radius * math.sin(angle)
        
        local point = Vec3(x, y)
        local perp = NormalizeVector(PerpendicularVector(center - point))
        table.insert(points, {perp = perp, pos = point})
    end

    local remainder = math.abs(endAngle - startAngle) * radius % (pointDistance)
    return { points = points, remainder = remainder }
end

function AngleToVector(angle)
    local radians = math.rad(angle)
    local x = math.cos(radians)
    local y = math.sin(radians)
    return { x = x, y = y }
end

--create a minimum sized rectangle around a polygon
function CalculateSquare(points)
    local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge

    for _, point in pairs(points) do
        if point.x < minX then minX = point.x end
        if point.x > maxX then maxX = point.x end
        if point.y < minY then minY = point.y end
        if point.y > maxY then maxY = point.y end
    end
    
    local pointA = {x = minX, y = minY}
    local pointB = {x = minX, y = maxY}
    local pointC = {x = maxX, y = maxY}
    local pointD = {x = maxX, y = minY}
    
    
    return {pointA, pointB, pointC, pointD}
end

  
function MinimumCircularBoundary(points)
    local square = CalculateSquare(points)
    local radius = Distance(square[1], square[3]) / 2
    local pos = AverageCoordinates(square)
    return {
        x = pos.x, y = pos.y, r = radius, square = square
    }

end

function GetFourOutermostPoints(points)
    local topLeft, topRight, bottomLeft, bottomRight
    local topLeftIndex, topRightIndex, bottomLeftIndex, bottomRightIndex
    for index, point in pairs(points) do
        if not topLeft then
            topLeft = point
            topLeftIndex = index
        elseif point.x + point.y < topLeft.x + topLeft.y then
            topLeft = point
            topLeftIndex = index
        end

        if not topRight then
            topRight = point
            topRightIndex = index
        elseif point.x - point.y > topRight.x - topRight.y then
            topRight = point
            topRightIndex = index
        end

        if not bottomLeft then
            bottomLeft = point
            bottomLeftIndex = index
        elseif point.x - point.y < bottomLeft.x - bottomLeft.y then
            bottomLeft = point
            bottomLeftIndex = index
        end

        if not bottomRight then
            bottomRight = point
            bottomRightIndex = index
        elseif point.x + point.y > bottomRight.x + bottomRight.y then
            bottomRight = point
            bottomRightIndex = index
        end
    end
    return {topLeftIndex, topRightIndex, bottomLeftIndex, bottomRightIndex}
end

function CircleLineSegmentCollision(circleCenter, radius, segmentStart, segmentEnd)
    -- Calculate the vector from the segment start to the circle center
    local segmentVector = SubtractVectors(segmentEnd, segmentStart)
    local circleVector = SubtractVectors(circleCenter, segmentStart)

    -- Calculate the projection of the circle center vector onto the segment vector
    local segmentLength = VecMagnitude(segmentVector)
    local projectionScalar = Dot(circleVector, segmentVector) / (segmentLength * segmentLength)

    -- Calculate the closest point on the segment to the circle center
    local closestPoint
    if projectionScalar < 0 then
        closestPoint = segmentStart
    elseif projectionScalar > 1 then
        closestPoint = segmentEnd
    else
        closestPoint = AddVectors(segmentStart, ScaleVector(segmentVector, projectionScalar))
    end

    -- Calculate the distance between the closest point and the circle center
    local distance = Distance(closestPoint, circleCenter)

    -- Check if the distance is less than or equal to the circle radius
    if distance <= radius then
        -- Calculate the collision response vector
        local collisionResponse = ScaleVector(NormalizeVector(SubtractVectors(circleCenter, closestPoint)),
        radius - distance)
        return collisionResponse
    else
        return nil
    end
end







---Calculates the normal of a point and a line segment
---@param lineA{x:number, y:number} First point of the line segment
---@param lineB{x:number, y:number} Second point of the line segment
---@param pos{x:number, y:number} Point to check from
---@return number Normal Normal ranging between -1 and 1
-- function CalculateCollisionNormal(lineA, lineB, pos)
--     local lineSegment = { x = lineB.x - lineA.x, y = lineB.y - lineA.y }
--     local point = { x = pos.x - lineA.x, y = pos.y - lineA.y }
--     local dot = Dot(lineSegment, point)
--     return (dot >= 0) and 1 or -1
-- end



function CalculateCollisionNormal(lineA, lineB, point)
    -- Calculate the direction vector perpendicular to the line segment
    local direction = {x = lineB.y - lineA.y, y = lineA.x - lineB.x}

    -- Calculate the vector from lineA to the given point
    local lineToPoint = {x = point.x - lineA.x, y = point.y - lineA.y}

    -- Calculate the dot product of the direction vector and the line-to-point vector
    local dotProduct = direction.x * lineToPoint.x + direction.y * lineToPoint.y

    -- Determine the sign of the dot product
    local sign = dotProduct >= 0 and 1 or -1

    return sign
end


