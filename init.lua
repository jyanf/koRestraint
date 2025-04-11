-- 无法避免某些漏网之鱼
local Apply_Local = false
local Flag_Spectating = false
local ADDR_COMM_MODE = 0x898690
local ADDR_UPDATE_MATCHEND = 0x482908
--local ADDR_SPELL_CAST = 0x487b60
--local ADDR_GETLOCK = 0x489653

local function getSelf() -- 只在自己输了的时候的时候生效，自已赢了不管
	local mode = memory.readint(ADDR_COMM_MODE)
	if mode==4 then return battle.manager.player1 end
	if mode==5 then return battle.manager.player2 end
	if mode==6 then Flag_Spectating = true end	
	--print ("MODE", mode)
end

local function protection(p) -- 保护输者	
	--p.opponent.collisionType = 3
-- 禁止对手的吃卡指令和预输入
	-- memory.writeint(p.opponent.ptr + 0x770-4*5, 0)
	-- memory.writeint(p.opponent.ptr + 0x770-4*4, 0)
	-- memory.writeint(p.opponent.ptr + 0x770-4*3, 0)
	-- memory.writeint(p.opponent.ptr + 0x770-4, 0)
	memory.writeint(p.opponent.ptr + 0x770, 0) -- 吃卡指令
-- 预输入
	-- memory.writeint(p.opponent.ptr + 0x790-4*5, 0)
	-- memory.writeint(p.opponent.ptr + 0x790-4*4, 0)
	-- memory.writeint(p.opponent.ptr + 0x790-4*3, 0)
	-- memory.writeint(p.opponent.ptr + 0x790-4, 0) 
	memory.writeint(p.opponent.ptr + 0x790, 0) 
	
	-- memory.writeint(p.opponent.ptr + 0x7a8-4*5, 0)
	-- memory.writeint(p.opponent.ptr + 0x7a8-4*4, 0)
	-- memory.writeint(p.opponent.ptr + 0x7a8-4*3, 0)
	-- memory.writeint(p.opponent.ptr + 0x7a8-4, 0) 
	memory.writeint(p.opponent.ptr + 0x7a8, 0)
-- 输者无敌
	--p.untech = 0 -- 不能直接修改，要用 hardcode
	--p.hitstop = 
	p.meleeInvulTimer = 256
	p.grabInvulTimer = 256
	p.projectileInvulTimer = 256
	--if(battle.manager.frameCount<3) then print(Protect, p.meleeInvulTimer, p.grabInvulTimer, p.projectileInvulTimer) end
end

---[[
memory.hooktramp(ADDR_UPDATE_MATCHEND, 7,
	memory.createcallback(0, function(cs)
		local Flag_Spectating = false
		local p = getSelf()
		if p then protection(p) end
		if Flag_Spectating then 
			protection(battle.manager.player1) 
			protection(battle.manager.player2) 
		end
		
	end)
)
--]]

---[[ 本地生效
soku.SubscribeSceneChange(function(id, scene)
	if id~=soku.Scene.Battle then return end
	return function()
		if battle.manager.matchState~=5 then return end -- 非 KO，跳过
		protection(battle.manager.player1) 
		protection(battle.manager.player2) 
		return -1
	end
end)
--]]