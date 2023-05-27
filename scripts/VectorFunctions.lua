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
    return { x = vector1.x - vector2.x, y = vector1.y - vector2.y }
end

-- Normalize a vector
---@param vector {x:number, y:number} Vector to normalize
---@return {x:number, y:number}
function NormalizeVector(vector)
    local length = ((vector.x) ^ 2 + (vector.y) ^ 2) ^ 0.5
    return { x = vector.x / length, y = vector.y / length }
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
        local edgeStart, edgeEnd = polygon[i], polygon[j]
        local closestPoint = ClosestPointOnLineSegment(point, edgeStart, edgeEnd)
        local distance = Distance(point, closestPoint)
        if distance < closestDistance then
            closestEdge, closestDistance = { edgeStart = edgeStart, edgeEnd = edgeEnd }, distance
        end
    end
    return { closestEdge = closestEdge, closestDistance = closestDistance }
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
    return { x = nx, y = ny }
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
    local offsetVector = { x = perp.x * offset, y = perp.y * offset }

    return offsetVector
end

--gets the average of a list of co ordinates
function AverageCoordinates(Coords)
    local output = { x = 0, y = 0 }
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
--modify to return remainder
function SubdivideLineSegment(startPoint, endPoint, distance, startingOffset)
    local segmentLength = Distance(startPoint, endPoint)
    local directionX = (endPoint.x - startPoint.x) / segmentLength
    local directionY = (endPoint.y - startPoint.y) / segmentLength
    local points = {}

    local t = startingOffset or 0 -- Starting offset
    while t < segmentLength do
        local x = startPoint.x + (t * directionX)
        local y = startPoint.y + (t * directionY)
        table.insert(points, { x = x, y = y })
        t = t + distance
    end

    return {points = points, remainder = t}
end

function SubdivideArc(centerPoint, startPoint, endPoint, radius, distance, startingOffset)
    local points = {}
    local startAngle = CalculateAngle(centerPoint.x, centerPoint.y, startPoint.x, startPoint.y)
    local endAngle = CalculateAngle(centerPoint.x, centerPoint.y, endPoint.x, endPoint.y)

    local adjustedStartAngle = DisplaceAngle(startAngle, radius, startingOffset)
    local adjustedStartPos = CalculateCirclePoint(centerPoint, radius, adjustedStartAngle)
    table.insert(points, adjustedStartPos)

    local currentAngle = adjustedStartAngle
    local currentDistance = 0

    while currentDistance <= radius * math.abs(endAngle - adjustedStartAngle) do
        currentAngle = currentAngle - (distance / radius) -- Subtract instead of add
        local point = CalculateCirclePoint(centerPoint, radius, currentAngle)
        table.insert(points, point)
        currentDistance = currentDistance + distance
    end

    local remainder = radius * math.abs(endAngle - currentAngle)
    return { points = points, remainder = remainder }
end

function CalculateAngle(x1, y1, x2, y2)
    local dx = x2 - x1
    local dy = y2 - y1
    local angle = math.atan2(dy, dx)
    return angle
end

function DisplaceAngle(originalAngle, radius, displacement)
    local circumference = 2 * math.pi * radius
    local fraction = displacement / circumference
    local angle = originalAngle + (fraction * 2 * math.pi)
    return angle
end

function CalculateCirclePoint(circle,  radius, angle)
    local x = circle.x + radius * math.cos(angle)
    local y = circle.y + radius * math.sin(angle)
    return {x = x, y = y}
  end

function AngleToVector(angle)
    local radians = math.rad(angle)
    local x = math.cos(radians)
    local y = math.sin(radians)
    return { x = x, y = y }
end
function CalculateSquare(points)
    -- Step 1: Determine the minimum and maximum x and y coordinates
    local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge
    for _, point in ipairs(points) do
        if point.x < minX then
            minX = point.x
        end
        if point.y < minY then
            minY = point.y
        end
        if point.x > maxX then
            maxX = point.x
        end
        if point.y > maxY then
            maxY = point.y
        end
    end

    -- Step 2: Calculate the width and height of the square
    local width = maxX - minX
    local height = maxY - minY

    -- Step 3: Determine the size of the square
    local size = math.max(width, height)

    -- Step 4: Calculate the center point of the square
    local centerX = minX + width / 2
    local centerY = minY + height / 2

    -- Step 5: Calculate the coordinates of the square's corners
    local topLeftX = centerX - size / 2
    local topLeftY = centerY - size / 2
    local bottomRightX = centerX + size / 2
    local bottomRightY = centerY + size / 2

    -- Return the coordinates of the square's corners as a table
    return {
        { x = topLeftX, y = topLeftY },
        { x = bottomRightX, y = bottomRightY }
    }
end
  
function MinimumCircularBoundary(points)
    local square = CalculateSquare(points)
    local radius = Distance(square[1], square[2]) / 2
    local pos = AverageCoordinates(square)
    return {
        x = pos.x, y = pos.y, r = radius
    }

end

function CircleLineSegmentCollision(circleCenter, wheelRadius, segmentStart, segmentEnd)
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
    if distance <= wheelRadius then
        -- Calculate the collision response vector
        local collisionResponse = ScaleVector(NormalizeVector(SubtractVectors(circleCenter, closestPoint)),
            wheelRadius - distance)
        return collisionResponse
    else
        return nil
    end
end

function Circumcircle(a, b, c)
    local A = b.x - a.x
    local B = b.y - a.y
    local C = c.x - a.x
    local D = c.y - a.y
    local E = A * (a.x + b.x) + B * (a.y + b.y)
    local F = C * (a.x + c.x) + D * (a.y + c.y)
    local G = 2 * (A * (c.y - b.y) - B * (c.x - b.x))
    if G == 0 then
        return { x = 0, y = 0, r = math.huge }
    else
        local cx = (D * E - B * F) / G
        local cy = (A * F - C * E) / G
        local r = math.sqrt((a.x - cx) ^ 2 + (a.y - cy) ^ 2)
        return { x = cx, y = cy, r = r }
    end
end
