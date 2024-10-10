--scripts/forceManager.lua

ForceManager = {

}
ForceTable = {}

function ForceManager.Load()
    ForceTable = {}
end 
function UpdateForceManager(frame)
    for node, force in pairs(ForceTable) do
        dlc2_ApplyForce(node, force)
    end
    ForceTable = {}
end

function ApplyForce(node, force)
    if node == nil or force == nil then
        return
    end
    ForceTable[node] = (ForceTable[node] or Vec3(0,0,0)) + force
end