--[[
	短弓兵-321
	对应monsterid:暂未定
]]
local DuanGongBing = class("DuanGongBing", function ( params )
	local animal = Character:_create(params)
	return animal
end)

function DuanGongBing:create(params)
	return DuanGongBing.new(params)
end

function DuanGongBing:_initCache()
	XTHD.createSprite("res/spine/effect/321/langbing_qiangjianbi1.png")
end

function DuanGongBing:doAnimationEvent(event)
	--[[注意：
		1.在技能结束时，原先选定的攻击对象可能已经死亡了
	  ]]
	local name = event.eventData.name

	if name == BATTLE_ANIMATION_EVENT.onAtkDone then
		local _skillData 	= self:getSkillByAction(BATTLE_ANIMATION_ACTION.ATTACK)
	    local targets 		= self:getSelectedTargets(BATTLE_ANIMATION_ACTION.ATTACK)
		local _targetList 	= targets
		if _targetList == nil or #_targetList < 1 then
			do
				return
			end
		end

		--[[取第一个对象，也是最近的一个]]
		local _target_enemy = _targetList[1]
		if _target_enemy then
			local _arrow = XTHDArrow:createWithParams({fileName = "res/spine/effect/321/langbing_qiangjianbi1.png" , autoRotate = true})
			_arrow:setScale(self:getScaleY())
			--起始位置
			local _targetSlot = self:getSlotPositionInWorld("firePoint")
			
			_arrow:setPosition(_targetSlot.x, _targetSlot.y)
			--目标位置
			local _randValue = math.random(20)-10
			local _midPointPos = _target_enemy:getSlotPositionInWorld("midPoint")
			local endPos = cc.p(_midPointPos.x + _randValue,_midPointPos.y + _randValue)

			local pos_delta = getDistance( endPos, _targetSlot )
			local bezier = nil
			local bezier_pos1 = nil
			local bezier_pos2 = nil
			local bezier_pos3 = nil

		    local mid_x = 87/47*(_targetSlot.y-endPos.y)/2+(_targetSlot.x-endPos.x)/2
	        bezier_pos1 = cc.p(_targetSlot.x, _targetSlot.y)
	        bezier_pos2 = cc.p(_targetSlot.x-mid_x, _targetSlot.y+ mid_x/47*87)
			bezier_pos3 = cc.p(endPos.x, endPos.y)
			
			bezier = {
		        bezier_pos1,
				bezier_pos2,
				bezier_pos3
		    }

			local dt = getDynamicTime(pos_delta, 1000)
			local actionBezier = cc.BezierTo:create(dt, bezier)

			XTHD.dispatchEvent({
				name = EVENT_NAME_BATTLE_PLAY_EFFECT,
				data = {node = _arrow,spine = self},
			})
			
			_arrow:runAction(cc.Sequence:create(actionBezier,cc.CallFunc:create(function()
				local _rotate = _arrow:getRotation()
				animalClickedAnimation({
							rotation = _rotate
							,randValue = _randValue
							,path = "res/spine/effect/321/langbing_qiangjianbi11.png"
							,attacker = self
							,beAttacker = _target_enemy
						})
				_arrow:removeFromParent()
				--[[攻击的帧事件，此时敌人应该出发受击操作]]
				self:doHurt({skill = _skillData,targets = targets})	
			end)))

		end
	end

end

return DuanGongBing
