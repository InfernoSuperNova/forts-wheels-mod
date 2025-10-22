local moveLeft_down = false --keybinds
local moveRight_down = false
local control_down = false
local keybind_down_last_frame = false
local last_selected_controllerId = -1
local current_UI_deviceStructureId = nil

local smallui_move  = false
local smallui_min_x = 200
local smallui_max_x
local smallui_scale = 0.225
local smallui_size
local smallui_pos   = {}




function UpdateControls(frame)
    EvalMoveKeybinds()

    
    if frame % 3 == 0 then
        ThrottleControl()
    end
    
    
    UpdateSmallUI()
    
end

function OnControlActivated(name, code, doubleClick)

    SetControlFrame(0)
    local uid = GetLocalClientIndex()
    if name == "brake" and code then
        if data.brakes[code] then
            SendScriptEvent("UpdateBrakes", 0 .. "," .. code, "", false)
            SetControlSpriteByParent("root", "brake", "hud-brake-icon")
        else
            SendScriptEvent("UpdateBrakes", 1 .. "," .. code, "", false)
            SetControlSpriteByParent("root", "brake", "hud-brake-pressed-icon")
        end
    elseif name == "info" .. uid .. "1" or name == "info" .. uid .. "2" then
        if Metric then
            Metric = false
        else
            Metric = true
        end
    elseif name == "info" .. uid .. "3" then
        PrintKeybinds(false, {"MoveLeft", "MoveRight", "ToggleBrake"})
    elseif name == "close" then
        Deselect()
    elseif name == "smallui-box" then

        if smallui_move then
            smallui_move = false

        elseif doubleClick then
            smallui_move = true

        elseif control_down then
            FocusCamOnController()
        end

    elseif string.sub(name, 1, 16) == "button_cosmetic_" then
        GetCosmeticWheelChoice(code)
    end
end

function IsValidController(deviceId)
    if  deviceId ~= -1
    and CheckSaveNameTable(GetDeviceType(deviceId), CONTROLLER_SAVE_NAME)
    and IsDeviceFullyBuilt(deviceId)
    and (GetDeviceTeamIdActual(deviceId) == GetLocalTeamId())
    then
        return true
    else
        return false
    end
end

function GetControlledStructureId(controllerId)
    if IsValidController(controllerId) then
        -- Getting structure ID directly from device maybe sometimes give wrong value, this is a workaround
        return GetDeviceStructureId(controllerId)
        --return NodeStructureId(GetDevicePlatformA(controllerId))
    else
        return nil
    end
end


function CreateUI(deviceStructureId, uid)
    current_UI_deviceStructureId = deviceStructureId

    SetControlFrame(0)
    local position = { x =200, y = ScreenMaxY - 150}
    local size = { x = 662, y = 371.25}
    AddButtonControl("HUDPanel", "throttle backdrop", path .. "/ui/textures/HUD/HUD Box.png", ANCHOR_TOP_LEFT, size, position, "Panel")
    LoadControl(path .. "/ui/throttleSlider.lua", "HUDPanel")
    LoadControl(path .. "/ui/brakeSlider.lua", "HUDPanel")
	SetControlRelativePos("GXWheelThrottle", "ThrottleSlider", Vec3(250, ScreenMaxY - 120))
	SetControlRelativePos("GXWheelBrake", "BrakeSlider", Vec3(400, ScreenMaxY - 45))
	
    for i = 1, 3 do
        AddTextButtonControl("throttle backdrop", "info" .. uid .. i, CurrentLanguage.PromptRightClick, ANCHOR_TOP_LEFT, {x = 50, y = 35 + i * 25, z = -10}, false, "Panel")
        SetButtonCallback("root", "info" .. uid .. i, deviceStructureId)
    end
    AddTextButtonControl("throttle backdrop", "gridSpeed" .. uid, CurrentLanguage.PromptRightClick, ANCHOR_TOP_LEFT, {x = 50, y = 74, z = -10}, false, "Readout")
    AddTextButtonControl("throttle backdrop", "powerWeightRatio" .. uid, CurrentLanguage.PromptRightClick, ANCHOR_TOP_LEFT, {x = 50, y = 99, z = -10}, false, "Readout")

    SetControlText("throttle backdrop", "info" .. uid .. "3", "Show hotkeys")
    SetControlStyle("throttle backdrop", "info" .. uid .. "3", "Fine")

    for i = 1, 3 do
        AddTextButtonControl("throttle backdrop", "info" .. uid .. i+3, CurrentLanguage.PromptRightClick, ANCHOR_TOP_RIGHT, {x = 612, y = 35 + i * 25, z = -10}, false, "Panel")
    end
    AddTextButtonControl("throttle backdrop", "gearRatio" .. uid, CurrentLanguage.PromptRightClick, ANCHOR_TOP_RIGHT, {x = 612, y = 74, z = -10}, false, "Readout")
    AddTextButtonControl("throttle backdrop", "engineForce" .. uid, CurrentLanguage.PromptRightClick, ANCHOR_TOP_RIGHT, {x = 612, y = 99, z = -10}, false, "Readout")

    SetControlText("throttle backdrop", "info" .. uid .. "6", CurrentLanguage.PromptRightClick)
    SetControlStyle("throttle backdrop", "info" .. uid .. "6", "Fine")

    AddTextButtonControl("throttle backdrop", "close", "x", ANCHOR_TOP_LEFT, {x = 612, y = 20, z = -10}, false, "Heading")
    SetButtonCallback("root", "close", deviceStructureId)

    CreateBrakeButton(deviceStructureId)

    --initialize throttle
    local posThrottle = {x = 273.5, y = 15} -- MAKE CONST PLSSS
    local posBrake = {x = 123, y = 15}
    --if the structure doesn't already have a throttle, create it
    if not data.throttles[deviceStructureId] then
        if ControlExists("root", "ThrottleSlider") then
            SendScriptEvent("UpdateThrottles", IgnoreDecimalPlaces(posThrottle.x, 3) .. "," .. posThrottle.y .. "," .. deviceStructureId, "", false)
        end
        SetControlRelativePos("ThrottleSlider", "SliderBar", posThrottle)
        SetControlRelativePos("BrakeSlider", "SliderBar", posBrake)
    end
    if not data.brakeSliders[deviceStructureId] then
        if ControlExists("root", "BrakeSlider") then
            SendScriptEvent("UpdateBrakeSliders", IgnoreDecimalPlaces(posBrake.x, 3) .. "," .. posBrake.y .. "," .. deviceStructureId, "", false)
        end
        SetControlRelativePos("BrakeSlider", "SliderBar", posBrake)
    end
    
    --set the device slider to whatever the throttle is in the structure throttles table
    if data.throttles[deviceStructureId] then
        SetControlRelativePos("ThrottleSlider", "SliderBar", data.throttles[deviceStructureId])
    end

    if data.brakeSliders[deviceStructureId] then
        SetControlRelativePos("BrakeSlider", "SliderBar", data.brakeSliders[deviceStructureId])
    end
end

function CreateBrakeButton(deviceStructureId)
    AddButtonControl("HUDPanel", "brake", "hud-brake-icon", ANCHOR_CENTER_CENTER, {x = 51.56, y = 41.25}, {x = 524, y = ScreenMaxY - 62}, "Normal")
    SetButtonCallback("root", "brake", deviceStructureId)
    --if the structure doesn't already have a brake, then create it

    if data.brakes[deviceStructureId] == nil then
        SendScriptEvent("UpdateBrakes", 0 .. "," .. deviceStructureId, "", false)
    else
        
        if data.brakes[deviceStructureId] then
            SetControlSpriteByParent("root", "brake", "hud-brake-pressed-icon")
        else
            SetControlSpriteByParent("root", "brake", "hud-brake-icon")
        end
    end
end

function DestroyUI(uid)
    SetControlFrame(0)
    current_UI_deviceStructureId = nil

    if ControlExists("HUDPanel", "throttle backdrop") then
        DeleteControl("HUDPanel", "throttle backdrop")
        DeleteControl("HUDPanel", "GXWheelThrottle")
        DeleteControl("HUDPanel", "GXWheelBrake")
        DeleteControl("HUDPanel", "brake")
    end
end

local function formatValue(value)
    local units = {"", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc"}
    local unitIndex = 1

    -- Keep dividing by 1000 until the number is below 1000,
    -- but make sure the displayed number stays below 100
    while value >= 1000 and unitIndex < #units do
        value = value / 1000
        unitIndex = unitIndex + 1
    end

    -- Round to 3 significant digits, up to 2 before decimal
    local formatted
    if value < 10 then
        formatted = string.format("%.2f", value)
    elseif value < 100 then
        formatted = string.format("%.1f", value)
    else
        formatted = string.format("%.0f", value)
    end

    -- Trim trailing zeros and dots
    formatted = formatted:gsub("(%..-)0+$", "%1"):gsub("%.$", "")

    return formatted .. units[unitIndex]
end


-- TODO: Move to a new home
StructureMass = {
    Result = 0,
    MaterialLookup = {},
    DeviceLookup = {},
    Visited = {}
}

function StructureMass:Get(structureId) 
    self.Result = 0
    self.TeamId = GetStructureTeam(structureId)
    self.CommanderEnabled = IsCommanderActive(self.TeamId)
    self.CommanderState = self.CommanderEnabled and COMMANDER_ACTIVE or COMMANDER_INACTIVE
    self.Visited = {}
    EnumerateStructureLinks(self.TeamId, structureId, "GetStructureMassCallback", false)
    return math.floor(self.Result)
end

-- type = 0 for material 1 for device
function StructureMass:GetMass(saveName, deviceId)
    deviceId = deviceId or 0
    if deviceId == 0 then
        if not self.MaterialLookup[self.TeamId] then self.MaterialLookup[self.TeamId] = {} end
        if not self.MaterialLookup[self.TeamId][self.CommanderState] then self.MaterialLookup[self.TeamId][self.CommanderState] = {} end

        if not self.MaterialLookup[self.TeamId][self.CommanderState][saveName] then 
            self.MaterialLookup[self.TeamId][self.CommanderState][saveName] = GetMaterialValue(saveName, self.TeamId, self.CommanderState, "Mass", 0)
        end
        return self.MaterialLookup[self.TeamId][self.CommanderState][saveName]
    else
        if not self.DeviceLookup[self.TeamId] then self.DeviceLookup[self.TeamId] = {} end
        if not self.DeviceLookup[self.TeamId][self.CommanderState] then self.DeviceLookup[self.TeamId][self.CommanderState] = {} end
        if not self.DeviceLookup[self.TeamId][self.CommanderState][saveName] then 
            local massString = IsWeapon(deviceId) and "WeaponMass" or "Mass"
            self.DeviceLookup[self.TeamId][self.CommanderState][saveName] = GetDeviceValue(GetDeviceType(deviceId), self.TeamId, self.CommanderState, massString, 0)
        end
        return self.DeviceLookup[self.TeamId][self.CommanderState][saveName]
    end
end


local sqrt = math.sqrt
function GetStructureMassCallback(nodeIdA, nodeIdB, linkPos, materialSaveName, deviceId) 
    if (StructureMass.Visited[nodeIdB] and StructureMass.Visited[nodeIdB][nodeIdA]) or (StructureMass.Visited[nodeIdA] and StructureMass.Visited[nodeIdA][nodeIdB])  then return true end
    if not StructureMass.Visited[nodeIdA] then StructureMass.Visited[nodeIdA] = {} end
    StructureMass.Visited[nodeIdA][nodeIdB] = true
    if not StructureMass.Visited[nodeIdB] then StructureMass.Visited[nodeIdB] = {} end
    StructureMass.Visited[nodeIdB][nodeIdA] = true

    if deviceId ~= 0 then
        StructureMass.Result = StructureMass.Result + StructureMass:GetMass(GetDeviceType(deviceId), deviceId)
    end

    local materialMass = StructureMass:GetMass(materialSaveName)
    local posA = PhysLib.NodesRaw[nodeIdA]
    local posB = PhysLib.NodesRaw[nodeIdB]

    local length = sqrt((posA.x - posB.x) * (posA.x - posB.x) + (posA.y - posB.y) * (posA.y - posB.y))
    StructureMass.Result = StructureMass.Result + length * materialMass

    return true
end



function UpdateVehicleInfo(structure, uid)

    --make sure the details exist
    if DrivechainDetails[structure] and DrivechainDetails[structure][1] then
        --define variables
        local velocity = math.abs(DrivechainDetails[structure][1])
        local maxSpeed = DrivechainDetails[structure][2]
        local details = {
            kmhr = string.format("%.0f", velocity / 100 * 3.6),
            mph = string.format("%.0f", velocity / 100 * 2.23694),
            maxkmhr = string.format("%.0f", maxSpeed / 100 * 3.6),
            maxmph = string.format("%.0f", maxSpeed / 100 * 2.23694),
            gridSpeed = string.format("%.0f", velocity),
            maxGridSpeed = string.format("%.0f", maxSpeed),
            gear = DrivechainDetails[structure][3],
            power = DrivechainDetails[structure][4],
            ratio = DrivechainDetails[structure][5],
            engineForce = DrivechainDetails[structure][6],
            throttleValue = DrivechainDetails[structure][7],
            maxGear = DrivechainDetails[structure][8]
        }
        --to stop things from flashing around as much.
        if tonumber(details.kmhr) < 10 then details.kmhr = "0" .. details.kmhr end
        if tonumber(details.mph) < 10 then details.mph = "0" .. details.mph end
        --power

        details.power = formatValue(details.power / 100 * math.abs(details.throttleValue)) .. "/" .. formatValue(details.power / 100)
        details.engineForce = formatValue(details.engineForce / 100)
        



        local ratio = details.ratio
        local displayValue

        if ratio < 1 then
            -- Reduction gear (e.g. 0.12 means 8.33:1)
            displayValue = 1 / ratio
        else
            -- Overdrive or direct
            displayValue = ratio
        end

        -- Format and clean up decimals
        local formatted = string.format("%.2f", displayValue)
        formatted = formatted:gsub("(%..-)0+$", "%1") -- remove trailing zeros
        formatted = formatted:gsub("%.$", "")         -- remove trailing dot

        local displayRatio
        if ratio < 1 then
            displayRatio = formatted .. ":1"
        else
            displayRatio = "1:" .. formatted
        end

        --Top left header
        if Metric then
            SetControlText("throttle backdrop", "info" .. uid .. "1", details.kmhr .. "/" .. details.maxkmhr .. CurrentLanguage.SpeedUnitKmph)
        else
            SetControlText("throttle backdrop", "info" .. uid .. "1", details.mph .. "/" .. details.maxmph .. CurrentLanguage.SpeedUnitMph)
        end
        -- Top left subheader
        SetControlText("throttle backdrop", "gridSpeed" .. uid, details.gridSpeed .. "/" .. details.maxGridSpeed .. "gu/s")


        local structureMass = StructureMass:Get(structure)
        -- Bottom left header
        SetControlText("throttle backdrop", "info" .. uid .. "2", string.format("%.0f", structureMass / 100) .. "T")

        -- Bottom left subheader
        SetControlText("throttle backdrop", "powerWeightRatio" .. uid,  formatValue(DrivechainDetails[structure][4] / structureMass) .. "pwr/wt")
       
        -- Top right header
        SetControlText("throttle backdrop", "info" .. uid .. "4", CurrentLanguage.GearText .. details.gear .. "/" .. details.maxGear)
        
        -- Top right subheader
        SetControlText("throttle backdrop", "gearRatio" .. uid, displayRatio)

        
        -- Bottom right header
        SetControlText("throttle backdrop", "info" .. uid .. "5", CurrentLanguage.PowerText .. details.power)

        -- Bottom right subheader
        SetControlText("throttle backdrop", "engineForce" .. uid, details.engineForce .. "")









    end
end

function CreateSmallUI()
    if SmallUIExists then return end
    SmallUIExists = true
    SetControlFrame(0)

    smallui_size  = {x = 254 * smallui_scale, y = 70 * smallui_scale}
    smallui_max_x = 867 - smallui_size.x
    smallui_pos   = {x = math.min(smallui_pos.x or smallui_max_x, smallui_max_x), y = (ScreenMaxY - 113) - smallui_size.y} --take bottom right corner of where it should be and sub size

    local par = "smallui-box"
    AddButtonControl("HUDPanel", par, "hud-smallui-box", ANCHOR_TOP_LEFT, smallui_size, smallui_pos, "panel")

    local size = ScaleVector(Vec3(56, 45), smallui_scale)
    local pos =  ScaleVector(Vec3(34, 12), smallui_scale)
    AddSpriteControl(par, "smallui-left", "hud-smallui-arrow", ANCHOR_TOP_LEFT, size, pos, false)
    RotateSpriteControl(par, "smallui-left", 2)

    pos.x = pos.x + 65 * smallui_scale
    AddSpriteControl(par, "smallui-brake", "hud-smallui-brake", ANCHOR_TOP_LEFT, size, pos, false)

    pos.x = pos.x + 65 * smallui_scale
    AddSpriteControl(par, "smallui-right", "hud-smallui-arrow", ANCHOR_TOP_LEFT, size, pos, false)

    AddTextControl("HUDItems", "smallui-tooltip-1", "Double Click to move", ANCHOR_TOP_LEFT, {x=-30,y=-53.3}, false, "ListToolTips")
    AddTextControl("HUDItems", "smallui-tooltip-2", "Control-RMB to change size", ANCHOR_TOP_LEFT, {x=-30,y=-41.3}, false, "ListToolTips")
    AddTextControl("HUDItems", "smallui-tooltip-3", "Control-LMB to focus camera", ANCHOR_TOP_LEFT, {x=-30,y=-29.3}, false, "ListToolTips")
end

function DestroySmallUI()
    if not SmallUIExists then return end
    SmallUIExists = false
    SetControlFrame(0)
    if ControlExists("HUDPanel", "smallui-box") then
        DeleteControl("HUDPanel", "smallui-box")
        DeleteControl("HUDItems", "smallui-tooltip-1")
        DeleteControl("HUDItems", "smallui-tooltip-2")
        DeleteControl("HUDItems", "smallui-tooltip-3")
    end
end

function IsMouseInside(pos, size)
    local m = GetMousePos()

    if      m.x >= pos.x 
        and m.x <  pos.x + size.x

        and m.y >= pos.y
        and m.y <  pos.y + size.y
    then return true
    else return false
    end
end

function FocusCamOnController()
    local controller = GetMostRecentController()
    if not controller then return end

    local strucId = GetControlledStructureId(controller)
    if not strucId then return end

    SetNamedScreenByHeight("landcruisers", GetDevicePosition(controller), math.max(2000, GetStructureRadius(strucId) * 1.5))
    RestoreScreen("landcruisers", 1.5, 0.5, true)
    DeleteNamedScreen("landcruisers")
end

function UpdateSmallUI()
    if #SelectedData.Group ~= 0 then
        return
    end

    if not IsValidController(last_selected_controllerId) then
        DestroySmallUI()
        return
    else
        CreateSmallUI()
    end

    local deviceStructureId = GetControlledStructureId(last_selected_controllerId)
    if not deviceStructureId then
        DestroySmallUI()
        return
    end

    if data.brakes[deviceStructureId] == nil or not data.throttles[deviceStructureId] then InitializeThrottleBrakeData(deviceStructureId) end

    if smallui_move then
        smallui_pos.x = math.min(math.max(GetMousePos().x - 30, smallui_min_x), smallui_max_x)
        SetControlRelativePos("HUDPanel", "smallui-box", smallui_pos)

        ShowControl("HUDItems", "smallui-tooltip-1", false)
        ShowControl("HUDItems", "smallui-tooltip-2", false)
        ShowControl("HUDItems", "smallui-tooltip-3", false)
    else
        ShowControl("HUDItems", "smallui-tooltip-1", IsMouseInside(smallui_pos, smallui_size))
        ShowControl("HUDItems", "smallui-tooltip-2", IsMouseInside(smallui_pos, smallui_size))
        ShowControl("HUDItems", "smallui-tooltip-3", IsMouseInside(smallui_pos, smallui_size))
    end

    if data.throttles[deviceStructureId].x < 273.5 then
        ShowControl("smallui-box", "smallui-left", true)
        ShowControl("smallui-box", "smallui-right", false)

    elseif data.throttles[deviceStructureId].x > 273.5 then
        ShowControl("smallui-box", "smallui-left", false)
        ShowControl("smallui-box", "smallui-right", true)

    else
        ShowControl("smallui-box", "smallui-left", false)
        ShowControl("smallui-box", "smallui-right", false)
    end

    ShowControl("smallui-box", "smallui-brake", data.brakes[deviceStructureId])
end

--returns the selected, or as a fallback the last selected controllerId
function GetMostRecentController()
    local controller = GetLocalSelectedDeviceId()

    if IsValidController(controller) then
        last_selected_controllerId = controller

    elseif IsValidController(last_selected_controllerId) then
        controller = last_selected_controllerId

    else
        last_selected_controllerId = -1
        return nil
    end

    return controller
end

function EvalMoveKeybinds()
    local controller = GetMostRecentController()
    if not controller then return end

    local deviceStructureId = GetControlledStructureId(controller)
    if not deviceStructureId or not data.throttles[deviceStructureId] then return end

    local old_throttle = data.throttles[deviceStructureId].x
    local new_throttle = nil

    if moveLeft_down and moveRight_down then
        keybind_down_last_frame = true
        new_throttle = 273.5

    elseif moveLeft_down then
        keybind_down_last_frame = true
        new_throttle = math.min(old_throttle, 273.5) - 50

    elseif moveRight_down then
        keybind_down_last_frame = true
        new_throttle = math.max(old_throttle, 273.5) + 50

    elseif keybind_down_last_frame then --keybind was released so we set neutral throttle once
        keybind_down_last_frame = false
        new_throttle = 273.5
    end

    if new_throttle then
        new_throttle = Clamp(new_throttle, 33, 514)
        
        SetControlFrame(0)
        if ControlExists("root", "ThrottleSlider") then
            SetControlRelativePos("ThrottleSlider", "SliderBar", {x = new_throttle, y = 15})
        else
            SendScriptEvent("UpdateThrottles", IgnoreDecimalPlaces(new_throttle, 3) .. "," .. 15 .. "," .. deviceStructureId, "", false)
        end
    end
end

-------Keybind callbacks
function MoveLeft()
    moveLeft_down = true
end

function MoveLeft_Up()
    moveLeft_down = false
end

function MoveRight()
    moveRight_down = true
end

function MoveRight_Up()
    moveRight_down = false
end

function ToggleBrake()
    local controller = GetMostRecentController()
    if not controller then return end

    local deviceStructureId = GetControlledStructureId(controller)
    if deviceStructureId then
        if ControlExists("root", "brake") then
            OnControlActivated("brake", deviceStructureId)
        else
            if data.brakes[deviceStructureId] then
                SendScriptEvent("UpdateBrakes", 0 .. "," .. deviceStructureId, "", false)
            else
                SendScriptEvent("UpdateBrakes", 1 .. "," .. deviceStructureId, "", false)
            end
        end
    end
end

function MouseLeft()
    smallui_move = false
end

function CtrlLeft()
    control_down = true
end

function CtrlLeft_Up()
    control_down = false
end

function ScaleUI()
    if not ControlExists("HUDPanel", "smallui-box") then return end
    if IsMouseInside(smallui_pos, smallui_size) then
        smallui_scale = smallui_scale + 0.1
        if smallui_scale > 1 then smallui_scale = 0.125 end
        DestroySmallUI()
        CreateSmallUI()
    end
end

--[[
 --call like e.g. Log_UI_Tree("", "HUDPanel", "")
 --might get stuck in inf loops sometimes

function Log_UI_Tree(parent, name, ind)
    local r = function(a)
        a = string.format("%.2f", a)

        while a:sub(-1) == "0" do
            a = a:sub(1, -2)

            if a:sub(-1) == "." then return a:sub(1, -2) end
        end

        return a
    end
    local pv = function(vec)
        return r(vec.x) .. ", " .. r(vec.y) .. ", " .. r(vec.z)
    end

    local pos = GetControlRelativePos(parent, name)
    local siz = GetControlSize(parent, name)

    local text = ind .. "'" .. name .. "' (relpos=" .. pv(pos) .. ") (size=" .. pv(siz) .. ")"
    
    local cc = GetChildCount(name)
    if cc > 0 then
        text = text .. " (" .. tostring(cc) .. " childs):"
    end

    Log(text)
    
    for i = 0, cc - 1 do
        Log_UI_Tree(name, GetChildName(name, i), ind .. "    ")
    end
end
]]

SmallUIExists = false
-- Contributed by Harder_天使的花园
SelectedData = {Name = true, Group = {}}
    SelectedOnSelf = false

    local onGroupMemberSelected = OnGroupMemberSelected
    function OnGroupMemberSelected(deviceId)
        if onGroupMemberSelected then
            onGroupMemberSelected(deviceId)
        end
        table.insert(SelectedData.Group, deviceId)
    end
    
    local onGroupMemberDeselected = OnGroupMemberDeselected
    function OnGroupMemberDeselected(deviceId)
        if onGroupMemberDeselected then
            onGroupMemberDeselected(deviceId)
        end
        SelectedData.Name = nil
        SelectedOnSelf = nil
        SelectedData.Group = {}
    end


    local previousThrottleX = 0
    local previousBrakeX = 0

    function ThrottleControl()
        local uid = GetLocalClientIndex()
        for _, id in pairs(SelectedData.Group) do
            local deviceStructureId = GetControlledStructureId(id)
            SetControlFrame(0)
            if deviceStructureId then
                --user has a valid controller selected so we should show the UI and read throttle slider

                if (deviceStructureId ~= current_UI_deviceStructureId) and (current_UI_deviceStructureId ~= nil) then 
                    DestroyUI(uid) --recreate UI so button callbacks get updated to new structureid
                end 
                
                if not ControlExists("HUDPanel", "throttle backdrop") then
                    CreateUI(deviceStructureId, uid)
                else
                    local throttlePos = GetControlRelativePos("ThrottleSlider", "SliderBar")
                    --send the pos to the throttles table
                    if ControlExists("root", "ThrottleSlider") and previousThrottleX ~= throttlePos.x then
                        SendScriptEvent("UpdateThrottles", IgnoreDecimalPlaces(throttlePos.x, 3) .. "," .. throttlePos.y .. "," .. deviceStructureId, "", false)
                    end
                    local brakePos = GetControlRelativePos("BrakeSlider", "SliderBar")
                    if ControlExists("root", "BrakeSlider") and previousBrakeX ~= brakePos.x then
                        SendScriptEvent("UpdateBrakeSliders", IgnoreDecimalPlaces(brakePos.x, 3) .. "," .. brakePos.y .. "," .. deviceStructureId, "", false)
                    end
                    previousThrottleX = throttlePos.x
                    previousBrakeX = brakePos.x
                end

                UpdateVehicleInfo(deviceStructureId, uid)

                DestroySmallUI()
            else
                if ControlExists("HUDPanel", "throttle backdrop") then
                    DestroyUI(uid)
                end
                previousThrottleX = 0
                previousBrakeX = 0
            end
        end      
        if #SelectedData.Group == 0 then
            DestroyUI(uid)
        end
    end