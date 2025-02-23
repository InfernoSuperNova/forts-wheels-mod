--for debugging
--ShowAntiAirTrajectories = true
--ShowAntiAirTargets = true
--ShowAntiAirLockDowns = true

ShootableProjectile["sbpp_f16"] = true
ShootableProjectile["sbpp_Biplane"] = true
ShootableProjectile["sbpp_grenade"] = true
ShootableProjectile["sbpp_sidewinder"] = true
ShootableProjectile["sbpp_hellcat"] = true
ShootableProjectile["sbpp_p51"] = true
ShootableProjectile["sbpp_ac130"] = true
ShootableProjectile["sbpp_apache"] = true
ShootableProjectile["sbpp_littlebird"] = true
ShootableProjectile["sbpp_mig15"] = true
ShootableProjectile["sbpp_spitfire"] = true
ShootableProjectile["sbpp_b52"] = true
ShootableProjectile["sbpp_hydra"] = true
ShootableProjectile["sbpp_hellfire"] = true
ShootableProjectile["sbpp_bomb250kg"] = true
ShootableProjectile["sbpp_howitzer105mm"] = true
ShootableProjectile["sbpp_flare"] = true
ShootableProjectile["sbpp_alcm"] = true
ShootableProjectile["sbpp_rp3"] = true
--107

--key and value used.
PlaneSaveNames = {
	["thunderbolt"]=-1000,
	["nighthawk"]=-1000,
	["sbpp_f16"]=-1200,
	["sbpp_Biplane"]=-851,
	["sbpp_hellcat"]=-809-100,
	["sbpp_p51"]=-838-100,
	["sbpp_ac130"]=-838-100,
	["sbpp_apache"]=-0-1000,
	["sbpp_littlebird"]=-0-1000,
	["sbpp_mig15"]=-838-100,
	["sbpp_spitfire"]=-838-100,
	["sbpp_b52"]=-0-1000,
}
--lift_strength = GetProjectileParamFloat(saveName, 2, "sb_planes.lift_multiplier", 4.3) elevator_strength = GetProjectileParamFloat(saveName, 2, "sb_planes.elevator", 70000)*-0.02
--NOTE: this is fixed, therefor does not account for commander changes

--default: 30000. 36000 is the limit of flak about
ProjectileVisibleRanges = {
	--Planes
	["nighthawk"] =		12500,
	["thunderbolt"] =	30000,
	
	["sbpp_Biplane"] =	9000,
	["sbpp_hellcat"] =	25000,
	["sbpp_p51"] =		25000,
	["sbpp_f16"] =		30000,
	["sbpp_apache"] =	25000,
	["sbpp_littlebird"] =24000,
	["sbpp_ac130"] =		30000,
	["sbpp_mig15"] =		25000,
	["sbpp_spitfire"] =	25000,
	["sbpp_b52"] =		30000,
	
	--Missiles
	["sbpp_sidewinder"] =18000,
	["sbpp_hydra"] =		18000,
	["sbpp_hellfire"] =	20000,
	["sbpp_rp3"] =	20000,
	["sbpp_alcm"] =	20000,
	
	--Bombs
	["bomb"] =			10000,
	["paveway"] =		11500,
	
	["sbpp_grenade"] =	7000,
	["sbpp_bomb250kg"] =	10000,
	["sbpp_howitzer105mm"]=14000,
	
	--???
	["sbpp_flare"] =		35000,
	
	--Basegame projectiles
	["mortar"] =			9000,
	["missile"] =		20000,
	["rocketemp"] =		20500,
	["rocket"] =			20000,
	["mortar2"] =		10000,
	["ol_marker_sweep"]=	20500,
	["ol_marker_focus"]=	20500,
	["turret"] =			20500,
	["missile2"] =		20500,
	["howitzer"] =		20400,
}

AntiAirMaxRanges = {
	["machinegun"] =		12000,
	["flak"] =			36000,
	["shotgun"] =		48500,
	["hardpointflak"] =	100000,
}

data.OffensiveFireProbability["hardpointflak"] = 0
--data.FireDuringRebuildProbability["flak"] = 0
--data.AntiAirOpenDoor["flak"] = { ["mortar"] = false, }
--data.AntiAirErrorStdDev["sniper3AA"] = Balance(0.8, 0)
data.AntiAirFireProbability["hardpointflak"] = Balance(0.8, 0.9)
AntiAirFireProbabilityHumanAssist["hardpointflak"] = data.AntiAirFireProbability["hardpointflak"]
--AntiAirAddContextButton["sniper3AA"] = 0.9
--
--UpgradeSource["turreta"] = "hardpoint"


--[[function OnPortalUsed(nodeA, nodeB, nodeADest, nodeBDest, objectTeamId, objectId, isBeam)
   if plane then
      if objectTeamId%MAX_SIDES == teamId then
         table.insert(data.TrackedProjectiles, { ProjectileNodeId = nodeId, AntiAirWeapons = {}, Claims = {} })
      end
   end
end]]

data.flakDetonationTimings = {}

function BetterLog(a)
	Log(tostring(a))
end

function findMeetingTime(id1, id2)
	local epsilon = 1e-5

	local pos1 = NodePosition(id1)
	local vel1 = NodeVelocity(id1)
	local pos2 = NodePosition(id2)
	local vel2 = NodeVelocity(id2)

	local t_x = nil
	if math.abs(vel1.x - vel2.x) > epsilon then
		t_x = (pos2.x - pos1.x) / (vel1.x - vel2.x)
	end

	local t_y = nil
	if math.abs(vel1.y - vel2.y) > epsilon then
		t_y = (pos2.y - pos1.y) / (vel1.y - vel2.y)
	end

	if t_x and t_y and math.abs(t_x - t_y) <= epsilon then
		return t_x
	end

	if t_x then
		return t_x
	end
	if t_y then
		return t_y
	end

	return nil
end
--[[
function findPassingTime(id1, id2)
	local epsilon = 1e-5  -- Small threshold to account for floating-point precision

	-- Retrieve positions and velocities
	local pos1 = NodePosition(id1)
	local vel1 = NodeVelocity(id1)
	local pos2 = NodePosition(id2)
	local vel2 = NodeVelocity(id2)

	-- Calculate relative positions and velocities
	local dx = pos1.x - pos2.x
	local dy = pos1.y - pos2.y
	local dvx = vel1.x - vel2.x
	local dvy = vel1.y - vel2.y

	-- Calculate time of closest approach or passing
	local t = nil
	if math.abs(dvx) > epsilon then
		t = -dx / dvx
	elseif math.abs(dvy) > epsilon then
		t = -dy / dvy
	end

	-- Validate the time to ensure it is positive (future event)
	if t and t >= 0 then
		return t
	end

	-- No valid passing time found
	return nil
end]]

--[[function findPassingTime(id1, id2)
	local epsilon = 1e-5  -- Small threshold to account for floating-point precision

	-- Retrieve positions and velocities
	local pos1 = NodePosition(id1)
	local vel1 = NodeVelocity(id1)
	local pos2 = NodePosition(id2)
	local vel2 = NodeVelocity(id2)

	-- Calculate relative positions and velocities
	local dx = pos1.x - pos2.x
	local dy = pos1.y - pos2.y
	local dvx = vel1.x - vel2.x
	local dvy = vel1.y - vel2.y

	-- Calculate the time when the distance between projectiles is minimized
	local a = dvx^2 + dvy^2
	local b = 2 * (dx * dvx + dy * dvy)
	local c = dx^2 + dy^2

	if math.abs(a) < epsilon then
		if math.abs(b) < epsilon then
			return nil -- No relative motion
		else
			local t = -c / b
			if t >= 0 then
				return t
			else
				return nil
			end
		end
	else
		local discriminant = b^2 - 4 * a * c
		if discriminant < 0 then
			return nil -- No real solution
		else
			local sqrt_discriminant = math.sqrt(discriminant)
			local t1 = (-b + sqrt_discriminant) / (2 * a)
			local t2 = (-b - sqrt_discriminant) / (2 * a)

			local t_min = nil
			if t1 >= 0 and t2 >= 0 then
				t_min = math.min(t1, t2)
			elseif t1 >= 0 then
				t_min = t1
			elseif t2 >= 0 then
				t_min = t2
			end

			return t_min
		end
	end
end

function findMeetingOrPassingTime(id1, id2)
	local epsilon = 1e-5  -- Small threshold to account for floating-point precision

	-- Retrieve positions and velocities
	local pos1 = NodePosition(id1)
	local vel1 = NodeVelocity(id1)
	local pos2 = NodePosition(id2)
	local vel2 = NodeVelocity(id2)

	-- Calculate time using x components if velocities are not zero
	local t_x = nil
	if math.abs(vel1.x - vel2.x) > epsilon then
		t_x = (pos2.x - pos1.x) / (vel1.x - vel2.x)
	end

	-- Calculate time using y components if velocities are not zero
	local t_y = nil
	if math.abs(vel1.y - vel2.y) > epsilon then
		t_y = (pos2.y - pos1.y) / (vel1.y - vel2.y)
	end

	-- Check if times are consistent within the threshold
	if t_x and t_y and math.abs(t_x - t_y) <= epsilon then
		return t_x  -- or t_y since they are approximately equal
	end

	-- If only one of them is valid, return that
	if t_x then
		return t_x
	end
	if t_y then
		return t_y
	end

	-- If no valid meeting time found, find passing time
	return findPassingTime(id1, id2)
end]]

function calculate_min_distance(P_f, V_f, P_1, V_1)
	local Vr = {
		x = V_f.x - V_1.x,
		y = V_f.y - V_1.y
	}

	local P_diff = {
		x = P_f.x - P_1.x,
		y = P_f.y - P_1.y
	}

	local a = Vr.x * Vr.x + Vr.y * Vr.y
	local b = 2 * (P_diff.x * Vr.x + P_diff.y * Vr.y)
	local c = P_diff.x * P_diff.x + P_diff.y * P_diff.y

	-- Find the time of closest approach
	local t_min = -b / (2 * a)

	-- Calculate the minimum distance
	local D_min_squared = a * t_min * t_min + b * t_min + c
	local D_min = math.sqrt(D_min_squared)

	return D_min
end

function calculate_firing_velocity(P_f, P_t, v, t)
	-- Calculate direction vector from P_f to P_t
	local D = {
		x = P_t.x - P_f.x,
		y = P_t.y - P_f.y
	}

	-- Calculate the magnitude of D
	local D_magnitude = math.sqrt(D.x * D.x + D.y * D.y)

	-- Normalize the direction vector (D_u)
	local D_u = {
		x = D.x / D_magnitude,
		y = D.y / D_magnitude
	}

	-- Calculate the firing velocity vector V_f
	local V_f = {}
	if v then
		-- If speed is given, calculate V_f based on speed
		V_f.x = v * D_u.x
		V_f.y = v * D_u.y
	elseif t then
		-- If time is given, calculate V_f based on time to target
		V_f.x = D.x / t
		V_f.y = D.y / t
	else
		-- If neither is given, return nil
		return nil
	end

	return V_f
end

distance = GetDistance

function positionAtTime(pos, vel, t)
	return { x = pos.x + vel.x * t, y = pos.y + vel.y * t }
end

function findPassingTime(id1, id2)
	local epsilon = 1e-5  -- Small threshold to account for floating-point precision
	local maxIterations = 100  -- Maximum iterations for the bisection method
	local pos1 = NodePosition(id1)
	local vel1 = NodeVelocity(id1)
	local pos2 = NodePosition(id2)
	local vel2 = NodeVelocity(id2)

	-- Initial time range
	local t_min, t_max = 0, 100  -- Start with a large initial range
	local best_t = t_min
	local min_dist = distance(positionAtTime(pos1, vel1, t_min), positionAtTime(pos2, vel2, t_min))

	for i = 1, maxIterations do
		local t_mid = (t_min + t_max) / 2
		local newPos1 = positionAtTime(pos1, vel1, t_mid)
		local newPos2 = positionAtTime(pos2, vel2, t_mid)
		local dist_mid = distance(newPos1, newPos2)

		if dist_mid < min_dist then
			min_dist = dist_mid
			best_t = t_mid
		end

		local newPos1_min = positionAtTime(pos1, vel1, t_min)
		local newPos2_min = positionAtTime(pos2, vel2, t_min)
		local dist_min = distance(newPos1_min, newPos2_min)

		local newPos1_max = positionAtTime(pos1, vel1, t_max)
		local newPos2_max = positionAtTime(pos2, vel2, t_max)
		local dist_max = distance(newPos1_max, newPos2_max)

		if dist_min < dist_max then
			t_max = t_mid
		else
			t_min = t_mid
		end
	end

	-- Perform gradient descent-like refinement
	local learning_rate = 0.1
	local tolerance = 1e-6
	local prev_dist = min_dist
	for i = 1, maxIterations do
		local newPos1 = positionAtTime(pos1, vel1, best_t)
		local newPos2 = positionAtTime(pos2, vel2, best_t)
		local grad = (distance(positionAtTime(pos1, vel1, best_t + epsilon), positionAtTime(pos2, vel2, best_t + epsilon)) - prev_dist) / epsilon

		best_t = best_t - learning_rate * grad
		if best_t < 0 then best_t = 0 end

		local new_dist = distance(newPos1, newPos2)
		if math.abs(new_dist - prev_dist) < tolerance then
			break
		end
		prev_dist = new_dist
	end

	return best_t
end

function findMeetingOrPassingTime(id1, id2)
	local epsilon = 1e-5  -- Small threshold to account for floating-point precision

	-- Retrieve positions and velocities
	local pos1 = NodePosition(id1)
	local vel1 = NodeVelocity(id1)
	local pos2 = NodePosition(id2)
	local vel2 = NodeVelocity(id2)

	-- Calculate time using x components if velocities are not zero
	local t_x = nil
	if math.abs(vel1.x - vel2.x) > epsilon then
		t_x = (pos2.x - pos1.x) / (vel1.x - vel2.x)
	end

	-- Calculate time using y components if velocities are not zero
	local t_y = nil
	if math.abs(vel1.y - vel2.y) > epsilon then
		t_y = (pos2.y - pos1.y) / (vel1.y - vel2.y)
	end

	-- Check if times are consistent within the threshold
	if t_x and t_y and math.abs(t_x - t_y) <= epsilon then
		return t_x  -- or t_y since they are approximately equal
	end

	-- If only one of them is valid, return that
	if t_x then
		return t_x
	end
	if t_y then
		return t_y
	end

	-- If no valid meeting time found, find passing time using bisection and gradient descent hybrid method
	return findPassingTime(id1, id2)
end

-- Function to check if a position is within a 45-degree arc
function isWithinArc(from, target, forward, requiredAngle)
	local dx = target.x - from.x
	local dy = target.y - from.y

	local length = math.sqrt(dx * dx + dy * dy)

	if length == 0 then
		return false
	end

	-- Normalize the vector
	local nx = dx / length
	local ny = dy / length

	local ux = forward.x
	local uy = forward.y

	local dotProduct = nx * ux + ny * uy

	local angle = math.acos(dotProduct) * (180 / math.pi)

	return angle <= requiredAngle
end

-- Function to rotate a vector by a given angle in degrees
function rotateVector(vector, angleDegrees)
	local angleRadians = angleDegrees * (math.pi / 180)
	local cosTheta = math.cos(angleRadians)
	local sinTheta = math.sin(angleRadians)

	local rotatedX = vector.x * cosTheta - vector.y * sinTheta
	local rotatedY = vector.x * sinTheta + vector.y * cosTheta

	return { x = rotatedX, y = rotatedY }
end

function GetDistance(b,a)
	local x, y = a.x-b.x, a.y-b.y
	return (x * x + y * y ) ^ 0.5
end

function limit(num, min, max)
	return math.min(math.max(num, min), max)
end


function Load(gameStart)
	local debugLevel = GetConstant("AI.DebugLevel")
	if debugLevel >= LOG_CONFIG and GetGameMode() ~= "Multiplayer" then
		UpdateLogLevel(debugLevel)
		Log("Load AI Team " .. teamId .. ", difficulty = " .. data.difficulty)
	end

	if AILogLevel >= LOG_ENUMERATION and Fort then
		LogDetail("Initial Fort table")
		for k,action in ipairs(Fort) do
			LogAction(k, action)
		end
	end

	if Fort then
		local startLine = FortTableStartLine or 0

		-- remember the file lines from which the raw actions came from
		-- this is to allow interruption and partial re-recording of AI forts
		for k,action in ipairs(Fort) do
			-- this offset must correspond to the lines added at the start of an AI fort script
			-- in CommandInterpreter::StartRecordingFort
			action.Line = k + startLine

			if false and k > 2 then
				local actionCreateB = Fort[k - 1]
				local actionCreateA = Fort[k - 2]

				if action.Type == CREATE_LINK
					and actionCreateB.Type == CREATE_NODE
					and actionCreateA.Type == CREATE_NODE then

					if action.OriginalNodeAId == actionCreateB.OriginalNodeAId and action.OriginalNodeBId == actionCreateA.OriginalNodeBId then
						LogEnum("Swapping extrusion order at line " .. action.Line)

						Fort[k - 1] = action
						Fort[k] = actionCreateB
					end
				end	
			end				
		end
	end

	if teamId%MAX_SIDES == 1 then
		enemyTeamId = 2
	else
		enemyTeamId = 1
	end
	scriptLocalTeamFlakTarget = teamId
	if teamId == 1 then
		scriptLocalTeamFlakTarget = 101
	elseif teamId == 2 then
		scriptLocalTeamFlakTarget = 102
	end

	data.fortIndex = 1
	data.OriginalToActual = {}
	data.ExpectedNodeDestroy = {}
	data.ExpectedLinkDestroy = {}
	data.DisabledStructure = {}

	data.currWeapon = 0
	data.NextAntiAirIndex = 0
	data.activeBuilding = true
	data.NewNodes = {}
	data.DynamicNodePos = {} -- shifted from original position to fit the terrain (e.g. rope tie downs), key is original node id
	data.DeviceDeleteToRebuild = {} -- when deleting a device to rebuild some structure, to queue the rebuild on delete
	data.Frustration = {}
	data.offenceBucket = 0 -- tracks the opportunities for offence
	data.offencePoints = 100000000 -- shooting weapons require these points so mission scripts can throttle or gate offence
	data.maxGroupSize = 5

	DiscoverOriginalNodes()

	DiscoverUnknownDeviceTargets(SmallArmsPriorities, SmallArmsPrioritiesExclude, "SmallArmsPriorities")
	DiscoverUnknownDeviceTargets(HeavyArmsPriorities, HeavyArmsPrioritiesExclude, "HeavyArmsPriorities")

	if data.FortHasFoundations then
		data.ConstructionErrorToleranceMin = 30
		data.ConstructionErrorToleranceMax = 70
		data.ConstructionErrorToleranceRate = 4
	end

	-- prevent teams executing in the same frame
	-- to avoid CPU usage spikes
	local offset = 0
	if teamId%MAX_SIDES == 2 then
		offset = 0.7
	end
	local fortId = math.floor(teamId/MAX_SIDES)
	offset = offset + 2.3*fortId/4

	ScheduleCall(2 + offset, UpdateAI)
	ScheduleCall(1.5 + offset, TryShootDownProjectiles)
	if not data.HumanAssist then
		ScheduleCall(7 + offset, Repair)
		ScheduleCall(30 + offset, DecayFrustration)
	end

	GetAttackHintsFromProps(teamId%MAX_SIDES)

	data.fwenlee_pwanes = {}

end

function OnWeaponFired(weaponTeamId, saveName, weaponId, projectileNodeId, projectileNodeIdFrom)
	if data.gameWinner and data.gameWinner ~= teamId then return end
	local IsPlane = false
	for planeSaveName, _ in pairs(PlaneSaveNames) do
		if GetNodeProjectileSaveName(projectileNodeId) == planeSaveName then
			IsPlane = true
			break
		end
	end
	if weaponTeamId%100 == teamId%MAX_SIDES and IsPlane--[[and PlaneSaveNames[saveName] ]] then
		table.insert(data.fwenlee_pwanes, projectileNodeId)
	elseif weaponTeamId == scriptLocalTeamFlakTarget then
		if saveName == "flak" or saveName == "hardpointflak" then
			Target = data.flakDetonationTimings[weaponId]
			if Target then
				if GetRandomInteger(1,100,"Flak Misfire Chance") > 92 then SetNodeProjectileAgeTrigger(projectileNodeId, GetRandomFloat(1.6,2.6,"Flak Misfire Offset")) return end
				local offsetRange = 0.1 + 0.1*Target.uncertainty
				local detonationOffset = GetRandomFloat(-offsetRange,offsetRange,"Flak Detonation Offset") - 0.04
				if Target.justFired == true then
					Target.justFired = false
					local expectedImpactTime = findMeetingOrPassingTime(projectileNodeId,Target.id)--findPassingTime(projectileNodeId,yes)
					if expectedImpactTime < 0 then expectedImpactTime = data.flakDetonationTimings[weaponId].airburstSetPoint end
					local airburstTime = limit(expectedImpactTime + detonationOffset + limit(NodeVelocity(Target.id).y,-0.08,0.08), 0.12, 3.2)
					data.flakDetonationTimings[weaponId].airburstSetPoint = airburstTime
				else
					data.flakDetonationTimings[weaponId].airburstSetPoint = data.flakDetonationTimings[weaponId].airburstSetPoint + detonationOffset
				end
				if saveName == "hardpointflak" then
					if data.flakDetonationTimings[weaponId].airburstSetPoint < 0.1 then data.flakDetonationTimings[weaponId].airburstSetPoint = 0.22 end
					SetNodeProjectileAgeTrigger(projectileNodeId, data.flakDetonationTimings[weaponId].airburstSetPoint-0.16)
				else
					SetNodeProjectileAgeTrigger(projectileNodeId, data.flakDetonationTimings[weaponId].airburstSetPoint)
				end
			else
				ScheduleCall(0.04,OnWeaponFired,weaponTeamId, saveName, weaponId, projectileNodeId)
			end
		end
	elseif weaponTeamId%MAX_SIDES == enemyTeamId then
		local projectileSaveName = GetNodeProjectileSaveName(projectileNodeId)

		if ShootableProjectile[projectileSaveName] then
			--LogDetail("Enemy weapon " .. saveName .. " fired, tracking " .. (#data.TrackedProjectiles + 1))
			local delay = 0
			if not NoAntiAirReactionTime[saveName] then
				delay = GetRandomFloat(data.AntiAirReactionTimeMin, data.AntiAirReactionTimeMax, "OnWeaponFired 2 T" .. teamId .. ", " .. weaponId .. ", " .. projectileNodeId)
			end
			ScheduleCall(delay, TrackProjectile, projectileNodeId)
		end
	end

	if data.BuildIntoSmoke then
		local projType = GetNodeProjectileSaveName(projectileNodeId)
		if Fort and projType == "smoke" then
			ScheduleCall(0.5, BuildIntoSmoke, projectileNodeId, 4)
		end
	end
end

function TrackProjectile(nodeId)
	local nodeTeamId = NodeTeam(nodeId) -- returns TEAM_ANY if non-existent
	if nodeTeamId%MAX_SIDES == enemyTeamId then -- node may have changed team since firing
		IsPlane = false
		for planeSaveName, _ in pairs(PlaneSaveNames) do
			if GetNodeProjectileSaveName(nodeId) == planeSaveName then
				IsPlane = true
				break
			end
		end
		if IsPlane then
			ScheduleCall(1.5,trackProj,nodeId)
		else
			table.insert(data.TrackedProjectiles, {IsPlane = false, ProjectileNodeId = nodeId, AntiAirWeapons = {}, Claims = {} })
		end
	end
end

function trackProj(nodeId)
	if NodeExists(nodeId) then
		table.insert(data.TrackedProjectiles, {IsPlane = true, ProjectileNodeId = nodeId, AntiAirWeapons = {}, Claims = {} })
	end
end

function AA_GetProjectileGravity(id)
	if id < 0 then return 0 end
	saveName = AA_GetNodeProjectileSaveName(id)
	return PlaneSaveNames[saveName] or GetProjectileGravity(id)
	--if PlaneSaveNames[saveName] then return PlaneSaveNames[saveName] end
	--return GetProjectileGravity(id)
end

function AA_GetNodeProjectileSaveName(id)
	if id < 0 then return FindTrackedProjectile(id).SaveName end
	return GetNodeProjectileSaveName(id)
end

data.AntiAirPeriod = 0.04
function TryShootDownProjectiles()
	local weaponCount = GetAntiAirWeaponCount()
	local fthreadCount = math.floor(data.AntiAirPeriod / 0.04)
	local weaponsPerFthread = math.ceil(weaponCount / fthreadCount)
	--Log(tostring(weaponCount))
	for i = 0, fthreadCount - 1 do
		local starts = i * weaponsPerFthread
		local ends = math.min(i * weaponsPerFthread + weaponsPerFthread, weaponCount - 1)
		--Log(tostring(i) .. " = ".. tostring(starts) .. "-" .. tostring(ends))
		
		ScheduleCall(i * 0.04, TryShootDownProjectilesChild, weaponCount, starts, ends)
		if i >= weaponCount then
			break
		end
	end
	ScheduleCall(data.AntiAirPeriod, TryShootDownProjectiles)
end

function TryShootDownProjectilesChild(weaponCount, weaponIndexStart, weaponIndexEnd)
	if data.gameWinner and data.gameWinner ~= teamId then return end

	for id,lockdown in pairs(data.AntiAirLockDown) do
		if data.gameFrame - lockdown[1] > 2.5*30 then
			data.AntiAirLockDown[id] = nil
		end
	end

	for k,v in ipairs(data.TrackedProjectiles) do
		local nodeTeamId = AA_NodeTeam(v.ProjectileNodeId)
		
		if not v.IsPlane and nodeTeamId%MAX_SIDES ~= enemyTeamId then --[[nodeTeamId == TEAM_ANY ]]
			for _,b in ipairs(v.AntiAirWeapons) do
				if IsAIDeviceAvailable(b) then
					TryCloseWeaponDoorsWithDelay(b, "")
				end
			end

			table.remove(data.TrackedProjectiles, k)
		end
	end

	if not data.Disable and not data.DisableAntiAir then
		if data.NextAntiAirIndex >= weaponCount then
			data.NextAntiAirIndex = 0
		end
		
		--if there are projectiles start the stuffs
		if #data.TrackedProjectiles > 0 then
			local fireTestFlags = FIREFLAG_TEST | FIREFLAG_IGNOREFASTDOORS | FIREFLAG_TERRAINBLOCKS | FIREFLAG_EXTRACLEARANCE
			local rayFlags = RAY_EXCLUDE_CONSTRUCTION | RAY_NEUTRAL_BLOCKS | RAY_PORTAL_BLOCKS | RAY_EXCLUDE_FASTDOORS | RAY_EXTRA_CLEARANCE
			
			--loop through anti air weapons
			--local t0 = GetRealTime()
			for index = weaponIndexStart, weaponIndexEnd do
				local id = GetAntiAirWeaponId(index)
				--dont bother doing anything if the weapon cant fire
				if not IsWeaponReadyToFire(id) then continue end

				local type = GetDeviceType(id)
				local weaponPos = GetWeaponBarrelPosition(id)
				local speed = AntiAirFireSpeed[type] or GetWeaponTypeProjectileSpeed(type)
				local antiAirFireProb = data.AntiAirFireProbability[type]
				local weaponOverride = data.AntiAirWeaponOverride[id]
				if weaponOverride then
					antiAirFireProb = weaponOverride
				end
				local fieldBlockFlags = 0
				if GetWeaponFieldsBlockFiring(id) then
					fieldBlockFlags = FIELD_BLOCK_FIRING
				end

				local range = nil
				if AntiAirFireLeadTimeMax[type] then
					range = AntiAirFireLeadTimeMin[type]*speed
				end

				if antiAirFireProb and not data.AntiAirLockDown[id] and IsAIDeviceAvailable(id) and not IsDummy(id)
					and (GetRandomFloat(0, 1, "") < antiAirFireProb) then
					--LogEnum("AntiAir " .. id .. " type " .. type)

					local dangerOfImpact = false
					local closestTimeToImpact = 1000000
					local bestTarget = nil
					local best_t = nil
					local best_pos = nil
					local best_vel = nil
					
					--loop through projectiles
					
					for i = 1, #data.TrackedProjectiles do
						--Log("Evaluating projectile " .. v.ProjectileNodeId)
						v = data.TrackedProjectiles[i]
						if v.IsVirtual and (data.AntiAirFiresAtVirtualWithin[type] == nil or v.TimeLeft > data.AntiAirFiresAtVirtualWithin[type]) then
							continue
						end

						local projectileId = v.ProjectileNodeId
						local projectileType = AA_GetNodeProjectileType(v.ProjectileNodeId)
						local projectileSaveName = AA_GetNodeProjectileSaveName(v.ProjectileNodeId)
						local antiAirInclude = data.AntiAirInclude[type]
						local antiAirExclude = data.AntiAirExclude[type]

						if projectileType >= 0
							and (projectileType ~= PROJECTILE_TYPE_MISSILE or AA_IsMissileAttacking(projectileId)) and TableLength(v.Claims) == 0
		 					and (antiAirInclude == nil or antiAirInclude[projectileSaveName] == true)
							and (antiAirExclude == nil or antiAirExclude[projectileSaveName] ~= true) then

							local actualPos = AA_NodePosition(projectileId)
							--if projectile too far away, ignore
							local maxRange = AntiAirMaxRanges[type] or 35000
							local actualRange = GetDistance(actualPos,weaponPos)
							if actualRange >= maxRange then
								continue
							end
							
							local currVel = AA_NodeVelocity(projectileId)
							local delta = weaponPos - actualPos

							-- calculate the time it will take to get our projectile to the target position
							local leadTime
							if type == "hardpointflak" then
								leadTime = 1
							else
								local fireDelay = GetWeaponTypeFireDelay(type, teamId)
								local fireRoundsEachBurst = GetWeaponTypeRoundsEachBurst(type, teamId)
								local firePeriod = GetWeaponTypeRoundsPeriod(type, teamId)
								leadTime = fireDelay + 0.5*(fireRoundsEachBurst - 1)*firePeriod
							end

							local d = Vec3Length(delta)
							local targetSpeed = Vec3Length(currVel)
							local timeToImpact = d/(targetSpeed + speed) + leadTime
							local timeToSelf = d/targetSpeed

							pos, vel = PredictProjectilePos(projectileId, timeToImpact)
							local direction = Vec3(vel.x, vel.y)
							Vec3Unit(direction)

							if projectileType == PROJECTILE_TYPE_MISSILE then
								currVel.x = vel.x
								currVel.y = vel.y
							end

							local deltaUnit = Vec3(delta.x, delta.y)
							Vec3Unit(deltaUnit)

							local minTimeToImpact = AntiAirMinTimeToImpact[type] or data.AntiAirMinTimeToImpact

							-- avoid ray cast if there's no chance it will pass further testing
							-- ignore projectile if it's too close to shoot 

							local projectileVisibleRange = ProjectileVisibleRanges[projectileSaveName] or 30000
							
							local predictedRange = GetDistance(pos,weaponPos)

							if timeToImpact > closestTimeToImpact and timeToSelf > minTimeToImpact then continue end
							
						
							-- don't fire at projectiles that are behind the weapon
							local weaponForward = GetDeviceForward(id)
							if Vec3Dot(weaponForward, deltaUnit) > 0 then continue end
							
							local rayHit = CastRayFromDevice(id, pos, 1, rayFlags, fieldBlockFlags)
							local hitDoor = GetRayHitDoor()
							local lineOfSight = rayHit == RAY_HIT_NOTHING or hitDoor
							if not lineOfSight then continue end
							local incomingAngle = ToDeg(math.acos(Vec3Dot(deltaUnit, direction)))

							local trajectoryThreat = lineOfSight and incomingAngle < 15
							-- and projectileType == PROJECTILE_TYPE_MORTAR then
							
							local g = AA_GetProjectileGravity(projectileId)
							if g == 0 or projectileType == PROJECTILE_TYPE_MISSILE then g = 0.00001 end
							local a = 0.5*g/(currVel.x*currVel.x)
							local dydx = currVel.y/currVel.x;
							local x = -delta.x
							local y = -delta.y
							local b = dydx - 2*a*x
							local c = y - (a*x*x + b*x)
							local discriminant = b*b - 4*a*c
							if discriminant > 0 then
								local discriminantSqRt = discriminant ^ 0.5
								local interceptA = (-b + discriminantSqRt)/(2*a)
								local interceptB = (-b - discriminantSqRt)/(2*a)
								local threatA = math.abs(interceptA) < 200
								local threatB = math.abs(interceptB) < 200
							
								if not threatA and not threatB then
									trajectoryThreat = false
								end
								if ShowAntiAirTrajectories and threatA then
									SpawnCircle(weaponPos + Vec3(interceptA, 0), 10, Red(128), data.AntiAirPeriod)
								end
								if ShowAntiAirTrajectories and threatB then
									SpawnCircle(weaponPos + Vec3(interceptB, 0), 10, Red(128), data.AntiAirPeriod)
								end
							end

							if range then
								-- work out roughly where the projectile enters the range of the weapon
								local entryPoint = nil
								local start = -delta.x
								local targetTime = 0
								local doorOffset = 0
								if hitDoor then
									doorOffset = -AntiAirDoorDelay
								end

								local step = 200
								local timeStep = step/math.abs(currVel.x)
								if delta.x < 0 then
									step = -step
								end
								local p1 = a*start*start + b*start + c
								for i = start + step, weaponPos.x, step do
									targetTime = targetTime + timeStep

									local p2 = a*i*i + b*i + c
									if ShowAntiAirTrajectories then
										SpawnLine(weaponPos + Vec3(i - step, p1), weaponPos + Vec3(i, p2), Green(64), data.AntiAirPeriod)
									end
									p1 = p2

									local targetPos = weaponPos + Vec3(i, p2)
									local dist = Vec3Dist(weaponPos, targetPos)
									if range and dist < range then
										if ShowAntiAirTrajectories then
											SpawnCircle(targetPos, 20, White(), data.AntiAirPeriod)
										end
										entryPoint = targetPos
										--Log("entry at " .. targetTime)
										break
									end
								end

								if not entryPoint
									or (AntiAirFireLeadTimeMin[type] == nil or (targetTime + doorOffset) < AntiAirFireLeadTimeMin[type])
									or (AntiAirFireLeadTimeMax[type] == nil or (targetTime + doorOffset) >= AntiAirFireLeadTimeMax[type]) then
										continue
								elseif targetTime <= range/speed then
									timeToImpact = targetTime
									pos = entryPoint
								end
							end
							
							-- Hack fix to the artillery arc attempt at hitting projectiles
							if type == "hardpointflak" then
								--local f = GetDeviceForward(id) if f.x>0 then a={x=0.5,y=-0.5}else a={x=0.5,y=-0.5}end --Not large enough of an offset for this to matter
								if not isWithinArc(weaponPos,pos,{x = 0,y = -1},40) then continue end
								if distance(weaponPos,pos) < 5500 then continue end
							end
							--AimWeapon(id, pos)
							--Log(""..GetAimWeaponAngle()) --check if its firing directly upwards, Note, not necessary as the angle restriction works quite well when combined with directAim flag


							local danger = timeToSelf < minTimeToImpact and trajectoryThreat

							if lineOfSight -- must be able to shoot it
								and (danger or danger == dangerOfImpact) -- ignore unthreatening projectiles if one has been found
								and timeToImpact < closestTimeToImpact then -- target the closest projectile
								--Log("  Best target so far, impact " .. timeToImpact .. " self " .. timeToSelf)
								closestTimeToImpact = timeToImpact
								bestTarget = v
								best_pos = pos
								best_vel = MissileVelToTarget(projectileType, projectileId, vel, pos)

								if ShowAntiAirLockdowns and danger and DoorCountAI(id) > 0 then
									SpawnLine(weaponPos, pos, Red(128), 2.5)
								end
							end
							dangerOfImpact = dangerOfImpact or danger

							-- optimise: avoid further ray casts
							if dangerOfImpact then
								break
							end
						end
					end

					-- shoot at the closest projectile found
					if bestTarget and IsWeaponReadyToFire(id) then
						local uncertainty = 1
						local maxUncertainty = 1

						--Log("best_pos " .. tostring(best_pos) .. " target node " .. bestTarget.ProjectileNodeId)

						local projectileGroup = {}
						if closestTimeToImpact > maxUncertainty then
							-- search for nearby targets and aim for the middle
							local accPos = Vec3()
							local accVel = Vec3()
							local count = 0
							for i = 1, #data.TrackedProjectiles do
								local v = data.TrackedProjectiles[i]
								--Log("  checking projectile " .. tostring(v.ProjectileNodeId))
								if AA_IsMissileAttacking(v.ProjectileNodeId) then
									local pos, vel = PredictProjectilePos(v.ProjectileNodeId, closestTimeToImpact)
									--Log("	 is attacking, time " .. closestTimeToImpact .. " pos " .. tostring(pos))
									if Vec3Length(pos - best_pos) < 500 then
										--Log("		within range")
										local projectileType = AA_GetNodeProjectileType(v.ProjectileNodeId)
										accPos = accPos + pos
										accVel = accVel + MissileVelToTarget(projectileType, v.ProjectileNodeId, vel, pos)
										count = count + 1
										table.insert(projectileGroup, v)
									end
								end
							end

							if ShowAntiAirTargets and count > 1 then
								SpawnCircle(best_pos, 500, White(64), data.AntiAirPeriod)
							end

							if count > 0 then
								best_pos = (1/count)*accPos;
								best_vel = (1/count)*accVel;
							end
						end

						local v = bestTarget
						local pos = best_pos
						local vel = best_vel
						local timeToImpact = closestTimeToImpact
						--LogEnum("Targeting projectile " .. v.ProjectileNodeId .. " with time to impact " .. closestTimeToImpact)

						local projectileSaveName = AA_GetNodeProjectileSaveName(v.ProjectileNodeId)
						local projectileType = AA_GetNodeProjectileType(v.ProjectileNodeId)
						local blocked = false

						if timeToImpact < maxUncertainty then
							-- become more certain as the projectile gets closer
							uncertainty = uncertainty*(timeToImpact/maxUncertainty)
						end

						-- aim at projected target position in the future, with some deviation for balance
						local right = Vec3Unit(Vec3(-vel.y, vel.x))
						pos = pos + uncertainty*GetNormalFloat(data.AntiAirLateralStdDev[projectileType], 0, "")*right

						if ShowAntiAirTargets then
							SpawnLine(best_pos, pos, White(128), data.AntiAirPeriod)
						end

						if ShowAntiAirTargets then
							SpawnEffect("effects/weapon_blocked.lua", best_pos)
							SpawnEffect("effects/weapon_blocked.lua", pos)
						end

						ReserveWeaponAim(id, 1.5*data.AntiAirPeriod)

						-- some weapons should not open doors to shoot down some projectiles (e.g. mini-guns against mortars) unless they are protected
						-- also if there isn't much time left don't open the door
						local slowDoorsBlock = data.AntiAirOpenDoor[type] ~= nil and data.AntiAirOpenDoor[type][projectileSaveName] == false
						local power = data.AntiAirPower[type] or 1
						local doorDelay = 0

						local fireResult = FireWeaponWithPower(id, pos, 0, FIREWEAPON_STDDEVTEST_DEFAULT, fireTestFlags, power)
						if fireResult == FIRE_DOOR then
							doorDelay = AntiAirDoorDelay
						end

						if dangerOfImpact or
							slowDoorsBlock or
							data.AntiAirLockDown[id] then

							blocked = fireResult ~= FIRE_SUCCESS

							--if blocked then
								--LogDetail(id .. " blocked: " .. fireResult .. " danger " .. tostring(dangerOfImpact))
							--end

							-- see if the door is high to make an exception to the open door setting
							if fireResult == FIRE_DOOR and not dangerOfImpact and not data.AntiAirLockDown[id] then
								local nA = GetRayHitLinkNodeIdA()
								local nB = GetRayHitLinkNodeIdB()
								--LogDetail(id .. " testing door: " .. nA .. ", " .. nB)
								if nA > 0 and nB > 0 then
									local posA = AA_NodePosition(nA)
									local posB = AA_NodePosition(nB)
									if posA.y < weaponPos.y - 10 and posB.y < weaponPos.y - 10 then
										--Log(id .. " opening high door for " .. projectileType)
										blocked = false
									end
								end
							end
							--LogDetail(type .. " in danger or does not open doors for " .. projectileType .. ", blocked = " .. tostring(blocked))
						else
							-- don't aim at things we can't see
							local rayFlags = RAY_EXCLUDE_CONSTRUCTION | RAY_NEUTRAL_BLOCKS | RAY_PORTAL_BLOCKS
							local rayHit = CastRayFromDevice(id, pos, 1, rayFlags, fieldBlockFlags)
							blocked = rayHit ~= RAY_HIT_NOTHING
						end

						if not blocked then
							local projSaveName = GetWeaponSelectedAmmo(id)
							local projParams = GetProjectileParams(projSaveName, teamId)

							if hasbit(projParams.FieldType, FIELD2_DECOY_ENEMY_BIT) then
								pos = AimDecoyAtEnemy(pos, id, projParams, fieldBlockFlags)
							end

							local stdDev = data.AntiAirErrorStdDev[type]
							--LogDetail("Shooting down projectile " .. v.ProjectileNodeId .. " weapon " .. id)
							if projSaveName == "flak" or projSaveName == "HardPointFlak" then
								local defaultAirburstSetPoint = data.flakDetonationTimings[id] and data.flakDetonationTimings[id].airburstSetPoint or 0.2
								data.flakDetonationTimings[id] = {id = v.ProjectileNodeId,timeToImpact = timeToImpact,uncertainty = uncertainty,airburstSetPoint = defaultAirburstSetPoint,justFired = true}
							end
							min_distance = math.huge
							for i = 1, #data.fwenlee_pwanes do
								local value = data.fwenlee_pwanes[i]
								local pspeed = GetWeaponMaxFireSpeed(teamId, type)
								local firing_velocity = calculate_firing_velocity(GetDevicePosition(id), pos, pspeed, nil)
								min_distance = calculate_min_distance(pos,firing_velocity, NodePosition(value), NodeVelocity(value))
							end
							if min_distance < 1400 then break end
							local result = FireWeaponWithPower(id, pos, stdDev or 0, FIREWEAPON_STDDEVTEST_DEFAULT, FIREFLAG_EXTRACLEARANCE | FIREFLAG_DIRECTAIM, power)
							if result == FIRE_SUCCESS then

								-- close door in a little delay once the projectile is lost
								if AntiAirClaimsProjectile[type] then
									v.Claims[id] = true
									for i,p in pairs(projectileGroup) do
										p.Claims[id] = true
									end
								end
								InsertUnique(v.AntiAirWeapons, id)
								data.NextAntiAirIndex = index + 1

								if IsSlowFiringAntiAir(id) then
									local timeRemaining = GetWeaponFiringTimeRemaining(id)
									TryCloseWeaponDoorsWithDelay(id, "", timeRemaining)
								end

								-- give a chance to keep firing anti-air weapons
								if GetRandomFloat(0, 100, "") < 50 then
									break
								end
							else
								if result == FIRE_DOOR then
									-- door will be opening, will try again soon
							
									-- remember to close doors that were opened but didn't have an opportunity to close
									InsertUnique(v.AntiAirWeapons, id)
								end
								LogDetail(FIRE[result])
							end
						end
					end

					if dangerOfImpact and DoorCountAI(id) > 0 then
						local timeRemaining = GetWeaponFiringTimeRemaining(id)
						if bestTarget then
							--LogDetail(type .. " has danger of impact from " .. bestTarget.ProjectileNodeId .. " closing doors of " .. id)
							data.AntiAirLockDown[id] = { data.gameFrame, bestTarget.ProjectileNodeId }
						end
						ScheduleCall(timeRemaining, TryCloseWeaponDoors, id)
					end
				end

				data.NextAntiAirIndex = index + 1
			end
			--local t1 = GetRealTime()
			--Log(tostring((t1 - t0)*1000))
		end
	end
end
