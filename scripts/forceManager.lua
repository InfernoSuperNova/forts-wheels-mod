--scripts/forceManager.lua

ForceManager = {
    ForceTable = {}
}

function ForceManager.Update(frame)
    for node, force in pairs(ForceManager.ForceTable) do
        dlc2_ApplyForce(node, force)
    end
    ForceManager.ForceTable = {}
end

function ForceManager:ApplyForce(node, force)
    if node == nil or force == nil then
        return
    end
    local existingForce = ForceManager.ForceTable[node] or Vec3(0,0,0)
    
    ForceManager.ForceTable[node] = {x = existingForce.x + force.x, y = existingForce.y + force.y}
end