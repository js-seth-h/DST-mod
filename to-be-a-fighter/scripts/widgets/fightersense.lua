local Widget = require "widgets/widget"
local BadgeWheel = require("util.badgewheel") 
local CountDown = require("util.countdown") 

-- CHORES = {"LUMBERJACK", "LUMBERJACK" }
FW = nil -- global var for helping develop widget
local FighterSenseWheel = Class(Widget, function(self)
  Widget._ctor(self, "FighterSenseWheel") 

  -- return;

  self.root = self:AddChild(BadgeWheel())
  FW = self.root
  self.root:CreateBadges(4) 
  --[[
  주요 설정 

  * 기능 5분간 끄기 / 원상복구
    * 파이터 센스 (공격시 무장) 하기 
    * 위기 대응 & 반사신경

  * 파이터 센스시, 근거리 무기 유지 hold melee
  * 파이터 센스시, 원거리 무기 유지 hold projectile

  * 휠 닫기
  ]]

  self:BtnOffence5() 
  self:BtnDefence5()

  self:BtnHoldMelee()
  self:BtnHoldProjectile()
  -- self:BtnClose()
  end)
function FighterSenseWheel:BtnOffence5()

  local img = nil
  local btn = self.root:GetBadge(1)  
  img = btn:InvIcon("armordragonfly") 
  img:SetPosition(10, 0)
  img:SetScale(0.7)

  img = btn:InvIcon("spear_wathgrithr") 
  img:SetRotation(-15)
  img:SetPosition(-12,0)
  img:SetScale(0.6)

  local function EnableIcon() 
    btn[1]:SetTint(1, 1, 1, 1)
    btn[2]:SetTint(1, 1, 1, 1)
    btn:Text(nil)
  end 
  local function DisableIcon()  
    btn[1]:SetTint(1, 1, 1, .5) 
    btn[2]:SetTint(1, 1, 1, .5) 
  end 



  local cd = CountDown( 60 * 5 , function(countdown)
    local remain = countdown.count 
    local str = string.format("%d:%02d", math.floor(remain / 60) , remain % 60 ) 
    btn:Text(str)
    if remain <= 0 then 
     TUNING.FS_COMBAT_INSTINCT = true 
     ThePlayer.components.talker:Say("NOW, My 'Combat Instinct' teach me how to fight!!")
     EnableIcon()
   end 
   end)

  btn:SetOnClick( function()   
    if TUNING.FS_COMBAT_INSTINCT then 
      TUNING.FS_COMBAT_INSTINCT = false 
      DisableIcon() 
      ThePlayer.components.talker:Say("Relex 'Combat Instinct' for a while.", 2)
      cd:ReStart()
    else 
      TUNING.FS_COMBAT_INSTINCT = true 
      EnableIcon()
      ThePlayer.components.talker:Say("Awaking My 'Combat Instinct'.")
      cd:Turnoff()
    end 
    end)

  btn:SetOnFocus( function() 
    if TUNING.FS_COMBAT_INSTINCT then 
      ThePlayer.components.talker:Say("'Combat Instinct', I know how to fight.", 2)
    else
      ThePlayer.components.talker:Say("I forgot 'Combat Instinct', do you know it?", 2) 
    end 
    end) 


  if TUNING.FS_COMBAT_INSTINCT then 
    EnableIcon()
  else
    DisableIcon()  
  end 



end

function FighterSenseWheel:BtnDefence5() 
  local img = nil
  local btn = self.root:GetBadge(2) 
  img = btn:InvIcon("tentaclespike") 
  img:SetPosition(-19, 13)
  img:SetScale(0.5)
  img:SetTint( 1,1, 1, .4)
  img = btn:InvIcon("tentaclespike")
  img:SetRotation(7)
  img:SetPosition(-12, 7)
  img:SetScale(0.7)
  img:SetTint(.5, .5, .5, .4)

  img = btn:InvIcon("armordragonfly") 
  img:SetRotation(15)
  img:SetPosition(12, -10)
  img:SetScale(0.7)

  -- btn:Text("")  

  local function EnableIcon() 
    btn[3]:SetTint(1, 1, 1, 1)
    btn:Text(nil)
  end 
  local function DisableIcon()  
    btn[3]:SetTint(1, 1, 1, .5) 
  end 



  local cd = CountDown( 60 * 5 , function(countdown)
    local remain = countdown.count 
    local str = string.format("%d:%02d", math.floor(remain / 60) , remain % 60 ) 
    btn:Text(str)
    if remain <= 0 then 
     TUNING.FS_DEFENSIVE_INSTINCT = true 
     ThePlayer.components.talker:Say("NOW, My 'Defensive Instinct' will keep me safe!!")
     EnableIcon()
   end 
   end)

  btn:SetOnClick( function()   
    if TUNING.FS_DEFENSIVE_INSTINCT then 
      TUNING.FS_DEFENSIVE_INSTINCT = false 
      DisableIcon() 
      ThePlayer.components.talker:Say("I will OK without 'Defensive Instinct' for a while.", 2)
      cd:ReStart()
    else 
      TUNING.FS_DEFENSIVE_INSTINCT = true 
      EnableIcon()
      ThePlayer.components.talker:Say("Awaking My 'Defensive Instinct'.")
      cd:Turnoff()
    end 
    end)

  btn:SetOnFocus( function() 
    if TUNING.FS_DEFENSIVE_INSTINCT then 
      ThePlayer.components.talker:Say("I am feeling safety with 'Defensive Instinct'.", 2)
    else
      ThePlayer.components.talker:Say("Without 'Defensive Instinct', I am in danger.", 2) 
    end 
    end) 


  if TUNING.FS_DEFENSIVE_INSTINCT then 
    EnableIcon()
  else
    DisableIcon()  
  end 

end

function FighterSenseWheel:BtnHoldMelee()

  local img = nil
  local btn = self.root:GetBadge(3) 
  img = btn:InvIcon("armordragonfly") 
  img:SetPosition(0,  22)
  img:SetScale(0.4)
  img:SetTint(1,1,1,.8)

  img = btn:InvIcon("spear_wathgrithr") 
  img:SetRotation(-15)
  img:SetPosition(-12, 22)
  img:SetScale(0.3)
  img:SetTint(1,1,1,.8)


  img = btn:InvIcon("spear") 
  img:SetScale(.8)
  img:SetRotation(15)
  img:SetPosition(-2, -3)
 
  
  btn:Text("hold") 

  local function EnableIcon() 
    btn[3]:SetTint(1, 1, 1, 1) 
    btn:Text("hold")
  end   
  local function DisableIcon()  
    btn[3]:SetTint(.7, .7, .7, .7)  
    btn:Text("free")
  end 


  btn:SetOnClick( function()   
    if TUNING.FS_HOLD_MELEE then 
      TUNING.FS_HOLD_MELEE = false 
      DisableIcon() 
      ThePlayer.components.talker:Say("Relex hands for the battles", 2) 
    else 
      TUNING.FS_HOLD_MELEE = true 
      EnableIcon()
      ThePlayer.components.talker:Say("I got sticky hands") 
    end 
    end)

  btn:SetOnFocus( function() 
    if TUNING.FS_HOLD_MELEE then 
      ThePlayer.components.talker:Say("Hold tight, trustworthy melee weapon in my hands.", 2)
    else
      ThePlayer.components.talker:Say("My hand will get strongest melee weapon just in time", 2) 
    end 
    end) 


  if TUNING.FS_HOLD_MELEE then 
    EnableIcon()
  else
    DisableIcon()  
  end 
end

function FighterSenseWheel:BtnHoldProjectile()
  local img = nil
  local btn = self.root:GetBadge(4) 
  img = btn:InvIcon("armordragonfly") 
  img:SetPosition(0,  22)
  img:SetScale(0.4)
  img:SetTint(1,1,1,.8)

  img = btn:InvIcon("spear_wathgrithr") 
  img:SetRotation(-15)
  img:SetPosition(-12, 22)
  img:SetScale(0.3)
  img:SetTint(1,1,1,.8)

  img = btn:InvIcon("boomerang") 
  img:SetScale(.8)
  img:SetRotation(180)

  btn:Text("hold") 

  local function EnableIcon() 
    btn[3]:SetTint(1, 1, 1, 1)
    btn:Text("hold")
  end 
  local function DisableIcon()  
    btn[3]:SetTint(.7, .7, .7, .7) 
    btn:Text("free")
  end 

  btn:SetOnClick( function()   
    if TUNING.FS_HOLD_PROJECTILE then 
      TUNING.FS_HOLD_PROJECTILE = false 
      DisableIcon() 
      ThePlayer.components.talker:Say("Release a boomerang, Grip a spear!", 2) 
    else 
      TUNING.FS_HOLD_PROJECTILE = true 
      EnableIcon()
      ThePlayer.components.talker:Say("Long distance warfare is prepared.") 
    end 
    end)

  btn:SetOnFocus( function() 
    if TUNING.FS_HOLD_PROJECTILE then 
      ThePlayer.components.talker:Say("Keep a Distance, it is a Strategy", 2)
    else
      ThePlayer.components.talker:Say("For victory, I will do close combat!", 2) 
    end 
    end) 


  if TUNING.FS_HOLD_PROJECTILE then 
    EnableIcon()
  else
    DisableIcon()  
  end 

end

function FighterSenseWheel:BtnClose()
  local img = nil
  local btn = self.root:GetBadge(5) 

end

function FighterSenseWheel:OnUpdate(dt) 
  -- print("onUpdate", dt)
end


return FighterSenseWheel