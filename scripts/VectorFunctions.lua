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
    local closestEdge, closestDistance = nil, 10e11
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
    local ny = dx -- negate the normal vector
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
    return math.sqrt(v.x^2 + v.y^2)
end
function VecMagnitudeDir(v)
    local magnitude = math.sqrt(v.x^2 + v.y^2)
    if v.x < 0 then
        magnitude = -magnitude
    end
    return magnitude
end
function OffsetPerpendicular(p1, p2, offset)
    -- calculate vector between two points
    local V = {x = p2.x - p1.x, y = p2.y - p1.y}

    -- calculate unit vector of V
    local mag = VecMagnitude(V)
    local U = {x = V.x/mag, y = V.y/mag}

    -- calculate vector perpendicular to V
    local perp = {x = -U.y, y = U.x}

    -- scale perpendicular vector by offset distance and add to original point
    local offsetVector = {x = perp.x * offset, y = perp.y * offset}

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

function PointSideOfLine(point, lineStart, lineEnd)
    local vec1 = {
        x = lineEnd.x - lineStart.x,
        y = lineEnd.y - lineStart.y
    }
    local vec2 = {
        x = point.x - lineStart.x,
        y = point.y - lineStart.y
    }

    return vec1.x * vec2.y - vec1.y * vec2.x
end


function VectorDirection(fromPos, toPos)
    local vec = {
        x = toPos.x - fromPos.x,
        y = toPos.y - fromPos.y
    }
    local length = math.sqrt(vec.x^2 + vec.y^2)
    if length > 0 then
        vec.x = vec.x / length
        vec.y = vec.y / length
    end
    return vec
end
function CrossProduct(v1, v2)
    return v1.x * v2.y - v2.x * v1.y
end

function GetAngleVector(point1, point2)
    local dx = point2.x - point1.x
    local dy = point2.y - point1.y
    local len = math.sqrt(dx * dx + dy * dy)
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
        table.insert(points, {x = x, y = y})
        t = t + distance
    end

    return points
end

    function PointsAroundArc(center, radius, p1, p2, spacing, offset)

        
        local angle1 = math.atan2(p1.y - center.y, p1.x - center.x)
        local angle2 = math.atan2(p2.y - center.y, p2.x - center.x)
        local angle_diff = angle2 - angle1
        local start_angle = angle1 + offset
        if math.sign(angle_diff) == -1 then 
            angle1, angle2 = angle2, angle1
            angle_diff = angle1 - angle2
            angle_diff = (math.pi * 2 + angle_diff)
            start_angle = angle2 + offset
        end
        local trackFactor = 1.4
        local arc_length = angle_diff * radius
        local num_points = math.ceil(arc_length / spacing)
        if num_points == 0 then return {} end
        local angle_incr = angle_diff / (num_points - 1)

        local points = {}
        for i = 1, num_points - 1, math.sign(num_points) do
            local angle = start_angle + (i - 1) * angle_incr
            local x = center.x + radius * math.cos(angle)
            local y = center.y + radius * math.sin(angle)
            table.insert(points, {x = x, y = y})
        end
        return points
    end



function AngleToVector(angle)
    local radians = math.rad(angle)
    local x = math.cos(radians)
    local y = math.sin(radians)
    return { x = x, y = y }
end


function MinimumCircularBoundary(points)
    local centerX, centerY = 0, 0
    local n = #points
    
    -- Calculate the center of the points
    for i = 1, n do
      centerX = centerX + points[i].x
      centerY = centerY + points[i].y
    end
    centerX = centerX / n
    centerY = centerY / n
    
    -- Calculate the radius of the circle
    local maxDistance = 0
    for i = 1, n do
      local distance = math.sqrt((points[i].x - centerX) ^ 2 + (points[i].y - centerY) ^ 2)
      if distance > maxDistance then
        maxDistance = distance
      end
    end
    
    return {x = centerX, y = centerY, r = maxDistance}
  end

  function CircleLineIntersection(circleCenter, circleRadius, lineStart, lineEnd)
    local intersectionPoints = {}

    -- Calculate the direction vector of the line
    local lineDirection = {x = lineEnd.x - lineStart.x, y = lineEnd.y - lineStart.y}

    -- Calculate the vector from the line start to the circle center
    local toCircleVector = {x = circleCenter.x - lineStart.x, y = circleCenter.y - lineStart.y}

    -- Calculate the length of the line
    local lineLength = math.sqrt(lineDirection.x ^ 2 + lineDirection.y ^ 2)

    -- Calculate the dot product of the line direction vector and the vector to the circle
    local dotProduct = (toCircleVector.x * lineDirection.x + toCircleVector.y * lineDirection.y) / (lineLength * lineLength)

    -- Calculate the closest point on the line to the circle
    local closestPoint = {x = lineStart.x + dotProduct * lineDirection.x, y = lineStart.y + dotProduct * lineDirection.y}

    -- Calculate the distance from the closest point to the circle center
    local distanceToClosestPoint = math.sqrt((circleCenter.x - closestPoint.x) ^ 2 + (circleCenter.y - closestPoint.y) ^ 2)

    -- If the distance to the closest point is less than the radius of the circle, there is an intersection
    if distanceToClosestPoint <= circleRadius then
        -- Calculate the distance from the closest point to the two intersection points
        local d = math.sqrt(circleRadius ^ 2 - distanceToClosestPoint ^ 2)

        -- Calculate the two intersection points
        local intersectionPoint1 = {x = closestPoint.x - d * lineDirection.y / lineLength, y = closestPoint.y + d * lineDirection.x / lineLength}
        local intersectionPoint2 = {x = closestPoint.x + d * lineDirection.y / lineLength, y = closestPoint.y - d * lineDirection.x / lineLength}

        -- Add the intersection points to the table
        table.insert(intersectionPoints, intersectionPoint1)
        table.insert(intersectionPoints, intersectionPoint2)
    end

    return intersectionPoints
end

function MinBoundingCircle(points)
    local n = #points
    if n == 0 then
        return nil
    elseif n == 1 then
        return {x = points[1].x, y = points[1].y, r = 0}
    elseif n == 2 then
        local dx = points[2].x - points[1].x
        local dy = points[2].y - points[1].y
        local r = math.sqrt(dx*dx + dy*dy) / 2
        return {x = (points[1].x + points[2].x) / 2, y = (points[1].y + points[2].y) / 2, r = r}
    end

    -- Shuffle points randomly
    for i = n, 2, -1 do
        local j = GetRandomInteger(1, i, "")
        points[i], points[j] = points[j], points[i]
    end

    -- Initialize circle
    local c = {x = points[1].x, y = points[1].y, r = 0}

    -- Add points to circle one by one
    for i = 2, n do
        local p = points[i]
        if (p.x - c.x)^2 + (p.y - c.y)^2 > c.r^2 then
            c = {x = p.x, y = p.y, r = 0}
            for j = 1, i-1 do
                local q = points[j]
                if (q.x - c.x)^2 + (q.y - c.y)^2 > c.r^2 then
                    c.x = (p.x + q.x) / 2
                    c.y = (p.y + q.y) / 2
                    c.r = math.sqrt((p.x - q.x)^2 + (p.y - q.y)^2) / 2
                    for k = 1, j-1 do
                        local r = points[k]
                        if (r.x - c.x)^2 + (r.y - c.y)^2 > c.r^2 then
                            c = Circumcircle(p, q, r)
                        end
                    end
                end
            end
        end
    end

    return c
end

function Circumcircle(a, b, c)
    local A = b.x - a.x
    local B = b.y - a.y
    local C = c.x - a.x
    local D = c.y - a.y
    local E = A*(a.x + b.x) + B*(a.y + b.y)
    local F = C*(a.x + c.x) + D*(a.y + c.y)
    local G = 2*(A*(c.y - b.y) - B*(c.x - b.x))
    if G == 0 then
        return {x = 0, y = 0, r = math.huge}
    else
        local cx = (D*E - B*F) / G
        local cy = (A*F - C*E) / G
        local r = math.sqrt((a.x - cx)^2 + (a.y - cy)^2)
        return {x = cx, y = cy, r = r}
    end
end
