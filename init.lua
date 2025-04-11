-- 无法避免某些漏网之鱼【2025-04-11】

local Apply_Spectating_Battle = false -- 选项1：是否控制观战
local Apply_Local_Battle = false -- 选项2：是否控制所有情况（测试用，包括本地对战）
		
local ADDR_COMM_MODE = 0x898690
-- local ADDR_COMM_MODE = 0x898804-- 战斗开始会设定这个内存的数值为 battle mode，保存和读取 rep 的时候会从这里读写
local ADDR_UPDATE_MATCHEND = 0x482908
local Flag_Spectating_Battle = false

local function getSelf() -- 只在自己输了的时候的时候生效，自已赢了不管
	local mode = memory.readint(ADDR_COMM_MODE)
	if mode==4 then return battle.manager.player1 end
	if mode==5 then return battle.manager.player2 end
	if mode==6 and Apply_Spectating_Battle then Flag_Spectating_Battle = true end
	--print ("MODE", mode)
end

local function protection(p) -- 保护输者
	--p.opponent.collisionType = 3
-- 禁止对手的吃卡指令和预输入
	memory.writeint(p.opponent.ptr + 0x770-4*5, 0)
	memory.writeint(p.opponent.ptr + 0x770-4*4, 0)
	memory.writeint(p.opponent.ptr + 0x770-4*3, 0)
	memory.writeint(p.opponent.ptr + 0x770-4, 0)
	memory.writeint(p.opponent.ptr + 0x770, 0) -- 吃卡指令
	memory.writeint(p.ptr + 0x770, 0) -- 吃卡指令
-- 预输入
	memory.writeint(p.opponent.ptr + 0x790-4*5, 0)
	memory.writeint(p.opponent.ptr + 0x790-4*4, 0)
	memory.writeint(p.opponent.ptr + 0x790-4*3, 0)
	memory.writeint(p.opponent.ptr + 0x790-4, 0) 
	memory.writeint(p.opponent.ptr + 0x790, 0)  -- 吃卡指令
	memory.writeint(p.ptr + 0x790, 0)  -- 吃卡指令
	
	memory.writeint(p.opponent.ptr + 0x7a8-4*5, 0)
	memory.writeint(p.opponent.ptr + 0x7a8-4*4, 0)
	memory.writeint(p.opponent.ptr + 0x7a8-4*3, 0)
	memory.writeint(p.opponent.ptr + 0x7a8-4, 0) 
	memory.writeint(p.opponent.ptr + 0x7a8, 0) -- 吃卡指令
	memory.writeint(p.ptr + 0x7a8, 0) -- 吃卡指令
-- 输者无敌
	-- memory.writeint(p.ptr + 0x196, 0) -- Hitstop 归零
	p.meleeInvulTimer = 512
	p.grabInvulTimer = 512
	p.projectileInvulTimer = 512
	--if(battle.manager.frameCount<3) then print(Protect, p.meleeInvulTimer, p.grabInvulTimer, p.projectileInvulTimer) end
end

---[[
memory.hooktramp(ADDR_UPDATE_MATCHEND, 7,
	memory.createcallback(0, function(cs)
		Flag_Spectating_Battle = false
		
		local p = getSelf()
		if p then protection(p) end
		
		if Flag_Spectating_Battle or Apply_Local_Battle then 
			protection(battle.manager.player1) 
			protection(battle.manager.player2) 
		end		
	end)
)
--]]
