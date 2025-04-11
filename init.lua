local ADDR_COMM_MODE = 0x898690
local ADDR_UPDATE_MATCHEND = 0x482908
--local ADDR_SPELL_CAST = 0x487b60
--local ADDR_GETLOCK = 0x489653
local function getSelf()
	local mode = memory.readint(ADDR_COMM_MODE)
	if mode==4 then return battle.manager.player1 end
	if mode==5 then return battle.manager.player2 end
end

local function protection(p)
--lock
	--p.opponent.confusionDebuffTimer = math.max(p.opponent.confusionDebuffTimer,5) --covered
	--p.opponent.collisionType = 3
	memory.writeint(p.opponent.ptr + 0x770, 0)
	memory.writeint(p.opponent.ptr + 0x790, 0)
	memory.writeint(p.opponent.ptr + 0x7a8, 0)
--avoid being attacked
	p.meleeInvulTimer = math.max(p.meleeInvulTimer, 1)
	p.grabInvulTimer = math.max(p.grabInvulTimer, 1)
	p.projectileInvulTimer = math.max(p.projectileInvulTimer, 1)
end

---[[
memory.hooktramp(ADDR_UPDATE_MATCHEND, 7,
	memory.createcallback(0, function(cs)
		local p = getSelf()
		if p then protection(p) end
		
		if(battle.manager.frameCount==1) then print(soku.sceneId-13, p.isRight) end
	end)
)
--]]

--[[local test
soku.SubscribeSceneChange(function(id, scene)
	if id~=soku.Scene.Battle then return end
	return function()
		if battle.manager.matchState~=5 then return end
		local p= battle.manager.player2
		protection(p)
		return -1
	end
end)
--]]