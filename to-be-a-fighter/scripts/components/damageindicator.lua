
local Inst = require "util.instance" 
local DamageIndicator = Class(function(self, inst)
  self.inst = inst
  self:install() 

  end,
  nil,
  { })

function round(num) 
  if num >= 0 then return math.floor(num+.5) 
    else return math.ceil(num-.5) end
  end

  function DamageIndicator:install()
    local player = self.inst
    print("DamageIndicator setup")
  -- local health = player.components.health
  local function _onChange(inst, data)
    -- if TUNING.SHOW_HP_CHANGES == "none" then return end
    -- print("_onChange", data.newpercent, data.oldpercent, inst.components.health.maxhealth, (data.newpercent - data.oldpercent))
    local maxhealth = Inst(inst):health_Max()  
    local amount =  round((data.newpercent - data.oldpercent) * maxhealth)
    -- print(amount)
    if (amount > 0 and not TUNING.SHOW_HEAL ) then return end
    if (amount < 0 and not TUNING.SHOW_DAMAGE ) then return end
    if math.abs(amount) < TUNING.HIDE_HP_CHANGES_LESS then return end 
    self:CreateDamageIndicator(inst, amount)

  end
  player:ListenForEvent("healthdelta", _onChange)
end




local FollowText = _G.require "widgets/followtext"
Vector3 = _G.Vector3
function DamageIndicator:CreateDamageIndicator(parent, amount)  
  -- print("CreateDamageIndicator", amount)
  local hud = ThePlayer.HUD
  if hud == nil then return end

  local widget = hud:AddChild(FollowText(_G.NUMBERFONT, 10))
  widget:SetOffset(Vector3(0,-400,0))
  widget:SetTarget(parent)


  local color
  if amount < 0 then
    color = TUNING.HEALTH_LOSE_COLOR
  else
    color = TUNING.HEALTH_GAIN_COLOR
  end
  widget.text:SetColour(color.r, color.g, color.b, color.a) 

  local dp_no = "%d";
  local dp_yes = "%.1f";
  local format = dp_no  
  amount = math.abs(amount)
  widget.text:SetString(string.format(format, amount)) 


  local function _indicatorMove()
    local t = 0
    local t_max = TUNING.LABEL_TIME
    local dt = TUNING.LABEL_TIME_DELTA 
    while t < t_max do 
      t = t + dt
      widget:SetOffset( Vector3(0,-(400 +  300 * math.sqrt(math.sqrt(t )) ) ,0))
      widget.text:SetSize( TUNING.LABEL_FONT_SIZE * math.sqrt( t ))
      Sleep(dt)

    end 

    widget:Kill()    
  end 
  parent:StartThread(_indicatorMove)

  return  
end

return DamageIndicator