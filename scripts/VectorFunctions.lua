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

--- Computes the distance between a point and an edge.
--- @param point table The point: {x:number, y:number}.
--- @param edgeStart table The starting point of the edge: {x:number, y:number}.
--- @param edgeEnd table The ending point of the edge: {x:number, y:number}.
--- @return number The distance between the point and the edge.
function DistanceToEdge(point, edgeStart, edgeEnd)
    local closestPoint = ClosestPointOnLineSegment(point, edgeStart, edgeEnd)
    return Distance(point, closestPoint)
end

--- Computes the perpendicular vector from a point to a vertex.
--- @param point table The point: {x:number, y:number}.
--- @param vertex table The vertex: {x:number, y:number}.
--- @return table The perpendicular vector: {x:number, y:number}.
function PerpendicularToVertex(point, vertex)
    local vector = SubtractVectors(vertex, point)
    return NormalizeVector({ x = -vector.y, y = vector.x })
end

--- Computes the perpendicular vector angle as a vector between two points.
--- @param point1 table The first point: {x:number, y:number}.
--- @param point2 table The second point: {x:number, y:number}.
--- @return table The perpendicular vector as an angle: {x:number, y:number}.
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

--- Computes the perpendicular vector from a point to an edge.
--- @param point table The point: {x:number, y:number}.
--- @param edgeStart table The starting point of the edge: {x:number, y:number}.
--- @param edgeEnd table The ending point of the edge: {x:number, y:number}.
--- @return table The perpendicular vector: {x:number, y:number}.
function PerpendicularToEdge(point, edgeStart, edgeEnd)
    local edgeVector = SubtractVectors(edgeEnd, edgeStart)
    local pointVector = SubtractVectors(point, edgeStart)
    local projectionLength = Dot(pointVector, edgeVector) / Dot(edgeVector, edgeVector)
    local projectionVector = ScaleVector(edgeVector, projectionLength)
    local perpendicularVector = SubtractVectors(pointVector, projectionVector)
    return NormalizeVector({ x = -perpendicularVector.y, y = perpendicularVector.x })
end

--- Calculates the perpendicular vector to the given vector.
--- @param vector table The input vector: {x:number, y:number}.
--- @return table The perpendicular vector: {x:number, y:number}.
function PerpendicularVector(vector)
    local nx = -vector.y
    local ny = vector.x
    return { x = nx, y = ny }
end

--- Calculates the magnitude (length) of a 2D vector.
--- @param v table The input vector: {x:number, y:number}.
--- @return number The magnitude of the vector.
function VecMagnitude(v)
    return math.sqrt(v.x ^ 2 + v.y ^ 2)
end

--- Calculates the signed magnitude of a 2D vector based on the x-coordinate sign.
--- @param v table The input vector: {x:number, y:number}.
--- @return number The signed magnitude of the vector.
function VecMagnitudeDir(v)
    local magnitude = math.sqrt(v.x ^ 2 + v.y ^ 2)
    if v.x < 0 then
        magnitude = -magnitude
    end
    return magnitude
end

--- Calculates the offset perpendicular vector between two points.
--- @param p1 table The first point: {x:number, y:number}.
--- @param p2 table The second point: {x:number, y:number}.
--- @param offset number The offset distance.
--- @return table The offset perpendicular vector: {x:number, y:number}.
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

--- Calculates the average coordinates of a list of points or forces.
--- @param Coords table[] The list of coordinates: {{x:number, y:number}, ...}.
--- @return table The average coordinates: {x:number, y:number}.
function AverageCoordinates(Coords)
    local output = { x = 0, y = 0 }
    if #Coords == 0 then
        return output
    end
    for k, coords in pairs(Coords) do
        output.x = output.x + coords.x
        output.y = output.y + coords.y
    end
    output.x = output.x / #Coords
    output.y = output.y / #Coords
    return output
end

--- Calculates the Euclidean distance between two points.
--- @param point1 table The first point: {x:number, y:number}.
--- @param point2 table The second point: {x:number, y:number}.
--- @return number The distance between the two points.
function Distance(point1, point2)
    return math.sqrt((point2.x - point1.x) ^ 2 + (point2.y - point1.y) ^ 2)
end

--- Checks if a point is inside a polygon using the winding number algorithm.
--- @param point table The point to check: {x:number, y:number}.
--- @param polygon table[] The polygon represented by a table of vertices: {{x:number, y:number}, ...}.
--- @return boolean True if the point is inside the polygon, false otherwise.
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

---Dot product between two points
---@param point1{x:number, y:number} First point
---@param point2{x:number, y:number} Second point
---@return number Dot Dot product
function Dot(point1, point2)
    return point1.x * point2.x + point1.y * point2.y
end

---Cross product between two points
---@param point1{x:number, y:number} First point
---@param point2{x:number, y:number} Second point
---@return number Cross Cross product
function CrossProduct(point1, point2)
    return point1.x * point2.y - point2.x * point1.y
end

---Gets the angle between two points as a vector
---@param point1{x:number, y:number} First point
---@param point2{x:number, y:number} Second point
---@return {x:number, y:number} Angle Angle vector
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

---Finds the closest point on a line segment from another point
---@param p{x:number, y:number} Point to search from
---@param a{x:number, y:number} First point of line segment
---@param b{x:number, y:number} Second point of line segment
---@return {x:number, y:number} Coordinates Point on line
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

---Subdivides a given line segment into a table of points.
---@param startPoint{x:number, y:number} First point of the line segment
---@param endPoint{x:number, y:number} Second point of the line segment
---@param distance number Distance between points to generate
---@param startingOffset number The offset of the first point to generate
---@return {points:{}, remainder:number} Table Table of points and the remainder
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

    return { points = points, remainder = t }
end

---Creates an arc consisting of a table of points. Calculates the start and end angles of the arc from the angle between the startPoint and the centerPoint,
---and the angle between the endPoint and the centerPoint. Radius is radius, startingOffset is the offset in distance for the first point. distance is for all of the rest of the points.
---@param centerPoint{x:number, y:number} The center point of the circle
---@param startPoint {x:number, y:number} The starting point of the arc, used to calculate the starting angle
---@param endPoint {x:number, y:number} The ending point of the arc, used to calculate the end angle
---@param radius number The radius of the arc
---@param distance number The distance between points on the arc
---@param startingOffset number The offset of the first point on the arc
---@return {points:{}, remainder:number} Table Table of points and the remainder
function SubdivideArc(centerPoint, startPoint, endPoint, radius, distance, startingOffset)
    -- This function subdivides an arc into smaller segments and returns the points along the arc

    local points = {} -- An array to store the points along the arc
    local startAngle = CalculateAngle(centerPoint, startPoint)
    local endAngle = CalculateAngle(centerPoint, endPoint)

    local adjustedStartAngle = startAngle - (startingOffset / radius)
    local adjustedStartPos = CalculateCirclePoint(centerPoint, radius, adjustedStartAngle)
    table.insert(points, adjustedStartPos) -- Insert the adjusted starting position into the points array

    local currentAngle = adjustedStartAngle
    local currentDistance = 0

    -- Loop until the current distance along the arc exceeds the radius times the absolute difference between the end angle and adjusted start angle
    while currentDistance <= radius * math.abs(endAngle - adjustedStartAngle) do
        currentAngle = currentAngle -
        (distance / radius)                                                   -- Decrease the current angle by the specified distance divided by the radius
        local point = CalculateCirclePoint(centerPoint, radius, currentAngle) -- Calculate the position on the circle based on the current angle
        table.insert(points, point)                                           -- Insert the calculated point into the points array
        currentDistance = currentDistance + distance                          -- Increase the current distance by the specified distance
    end

    local remainder = radius * math.abs(endAngle - currentAngle) -- Calculate the remaining arc length
    HighlightCoords({ startPoint, endPoint, adjustedStartPos })
    --BetterLog(remainder) -- Output the remaining arc length (presumably for debugging or logging purposes)
    return { points = points, remainder = remainder } -- Return the points array and the remaining arc length
end

--- Calculates the angle between two points.
--- @param point1 table The first point: {x:number, y:number}.
--- @param point2 table The second point: {x:number, y:number}.
--- @return number The angle between the two points, in radians.
function CalculateAngle(point1, point2)
    local dx = point2.x - point1.x
    local dy = point2.y - point1.y
    local angle = math.atan2(dy, dx)
    return angle
end

--- Displaces an angle along a circle given a radius and displacement value.
--- @param originalAngle number The original angle, in radians.
--- @param radius number The radius of the circle.
--- @param displacement number The displacement value along the circumference of the circle.
--- @return number The new displaced angle, in radians.
function DisplaceAngle(originalAngle, radius, displacement)
    local circumference = 2 * math.pi * radius
    local fraction = displacement / circumference
    local angle = originalAngle + (fraction * 2 * math.pi)
    return angle
end

--- Calculates the coordinates of a point on a circle given the center, radius, and angle.
--- @param circle table The center of the circle: {x:number, y:number}.
--- @param radius number The radius of the circle.
--- @param angle number The angle around the circle, in radians.
--- @return table The coordinates of the point on the circle: {x:number, y:number}.
function CalculateCirclePoint(circle, radius, angle)
    local x = circle.x + radius * math.cos(angle)
    local y = circle.y + radius * math.sin(angle)
    return { x = x, y = y }
end

--- Converts an angle in degrees to a normalized 2D vector.
--- @param angle number The angle in degrees.
--- @return table The 2D vector representation of the angle: {x:number, y:number}.
function AngleToVector(angle)
    local radians = math.rad(angle)
    local x = math.cos(radians)
    local y = math.sin(radians)
    return { x = x, y = y }
end

---Creates a bounding square that encompasses a table of points
---@param points table[] -- Table containing {x, y} pairs
---@return table[] square Table containing two points representing square
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
        { x = topLeftX,     y = topLeftY },
        { x = bottomRightX, y = bottomRightY }
    }
end

---Gets the minimum bounding circle of a table of points
---@param points table[] -- Table containing {x, y} pairs
---@return {x:number, y:number, r:number} table returns the position and radius
function MinimumCircularBoundary(points)
    local square = CalculateSquare(points)
    local radius = Distance(square[1], square[2]) / 2
    local pos = AverageCoordinates(square)
    return {
        x = pos.x, y = pos.y, r = radius
    }
end

---Checks the collision between a circle and a line segment
---@param circleCenter{x:number, y:number} Centerpoint of the circle
---@param wheelRadius number Radius of the circle
---@param segmentStart {x:number, y:number} Start of the line segment
---@param segmentEnd {x:number, y:number} End of the line segment
---@return {x:number, y:number} collisionResponse The result of the collision
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
        return { x = nil, y = nil }
    end
end
