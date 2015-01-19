local Widget = require "widgets/widget"
local ImageButton = require "widgets/imagebutton"
local Image = require "widgets/image"
local BadgeWheel = require("chores-lib.badgewheel") 
local CountDown = require("chores-lib.countdown") 
local Inst = require "chores-lib.instance" 

CW = nil

local PLACER_GAP = {
  pinecone = 3,
  dug_grass = 1,
  dug_berrybush = 2,
  dug_sapling = 1
}

local ATLASINV = "images/inventoryimages.xml"
local MAX_HUD_SCALE = 1.25
local ChoresWheel = Class(Widget, function(self)
  Widget._ctor(self, "Chores") 

  self:SetHAnchor(ANCHOR_RIGHT)
  self:SetVAnchor(ANCHOR_BOTTOM)
  self:SetScaleMode(SCALEMODE_PROPORTIONAL) 
  self:SetMaxPropUpscale(MAX_HUD_SCALE)

  self.root = self:AddChild(Image("images/fepanels.xml","panel_mod1.tex"))

  self.root:SetPosition(-200,300) 
  self.root:SetSize(400,450)
  self.root:SetTint(1,1,1,0.5)


  -- for k, v in pairs(TheWorld.minimap.MiniMap) do
  --   print("minimap - ", k , v)
  -- end
  CW = self.root
  -- self.root:CreateBadges(4) 

  self.flag ={
    axe = {pinecone = false},
    pickaxe = { nitre = false, goldnugget = true},
    shovel = { dug_grass = true, dug_berrybush = true, dug_sapling = true},
    backpack = { cutgrass = true, berries = true, twigs = true, flint = true},
    book_gardening = { dug_grass = true, dug_berrybush = false, dug_sapling = false, pinecone = false}
  }

  self.layout ={
    {"axe", "pinecone"},
    {"pickaxe", "nitre","goldnugget"},
    {"backpack", "flint", "cutgrass", "twigs", "berries"},
    {"shovel", "dug_grass", "dug_berrybush", "dug_sapling"},
    {"book_gardening", "dug_grass", "dug_berrybush", "dug_sapling", "pinecone"}
  }



  self.root.btns = {}

  local x,y = -125, 120
  for i, row in pairs(self.layout) do
    local task = row[1]
    self.root.btns[task] = {}
    for inx, icon in pairs(row) do  
      local btn = self:MakeBtn(task, icon)  
      btn:SetPosition( x, y)
      x = x + 60
    end
    y = y - 70
    x = -125
  end

  -- local btn = self.root:AddChild(ImageButton(ATLASINV, "axe.tex"))
  -- -- btn.image:SetTint(1,1,1,0.5) 
  -- btn:SetPosition( -125,125)
  -- CW.btn = btn


  -- local btn2 = self.root:AddChild(ImageButton(ATLASINV, "pinecone.tex"))
  -- -- btn2.image:SetTint(1,1,1,0.5) 
  -- btn2:SetPosition( -70,125)
  -- CW.btn2 = btn2


  -- local btn3 = self.root:AddChild(ImageButton(ATLASINV, "pickaxe.tex"))
  -- -- btn3.image:SetTint(1,1,1,0.5) 
  -- btn3:SetPosition( -125,80)
  -- CW.btn3 = btn3



  -- --[[
  -- To do chores list
  -- - 벌목꾼 도끼
  -- - 광부 (금, 니트로, 일반) 
  -- - 뽑기 (풀, 베리, 묘목)
  -- - 수집 (플린트, 돌, 풀, 가지, 베리, 당근)  손->가방 아이콘
  -- - 농부 (똥주기, 심기)   농장아이콘

  -- ]]

  -- self.placerGap = 3
  -- self.placers = nil

  -- self:BtnLumberJack()
  -- self:BtnMiner()


  -- self:BtnPlanter()
  -- -- self:BtnDeploy()
  -- print('CHO.TEST', CountDown.TEST)
  end)
function ChoresWheel:Toggle()
  if self.shown then
    self:Hide()

    ThePlayer.components.auto_chores:ForceStop()
  else
    self:Show()
  end
end
function ChoresWheel:MakeBtn(task, icon)
  local btn =  self.root:AddChild(ImageButton(ATLASINV, icon .. ".tex"))
  btn.image:SetSize(50,50)

  self.root.btns[task][icon] = btn
  local function updateTint() 
    print("updateTint",  self.flag[task][icon])
    if self.flag[task][icon] == false then
      btn.image:SetTint(.2,.2,.2,1)
    else
      btn.image:SetTint(1,1,1,1)
    end 
  end

  print("ti ", task, icon)
  if task ~= icon then updateTint() end

  btn.updateTint = updateTint
  btn:SetOnClick(function() self:BtnClick(task, icon) end)

  local widget = self
  local _OnGainFocus = btn.OnGainFocus 
  btn.OnGainFocus = function (self )
  _OnGainFocus(self)
  widget:BtnGainFocus(task,icon)
end 

local _OnLoseFocus = btn.OnLoseFocus 
btn.OnLoseFocus = function (self )
_OnLoseFocus(self)
widget:BtnLoseFocus(task,icon)
end 

return btn 
end
function ChoresWheel:BtnClick(task, icon) 
  if task == icon then 
    self:DoTask(icon) 
  elseif task == "book_gardening" then
    for k,v in pairs(self.flag[task]) do self.flag[task][k] = false end
    self.flag[task][icon] = true
    for k,v in pairs(self.root.btns[task]) do self.root.btns[task][k].updateTint() end 
  else 
    self.flag[task][icon] = not self.flag[task][icon]
    self.root.btns[task][icon].updateTint() 
  end 
end




function ChoresWheel:BtnGainFocus(task, icon) 
  if task == "book_gardening" and icon == "book_gardening" then

    if self.placers ~= nil then return end 
    self.placers = {}

    local prefab_name = nil
    for prefab, flag in pairs(self.flag[task]) do
      if flag then prefab_name = prefab end 
    end


    local placerGap = PLACER_GAP[prefab_name]

    if prefab_name == nil then return end 

    local placer_item = SpawnPrefab(prefab_name) 
    if placer_item == nil then 
      -- 심을것 없음 에러 
      return
    end
    local placer_name = placer_item.replica.inventoryitem:GetDeployPlacerName()

    self:StartUpdating()

    for xOff = 0, 4, 1 do
      for zOff = 0, 3, 1 do 
        local deployplacer = SpawnPrefab(placer_name)
        table.insert( self.placers, deployplacer)  
        deployplacer.components.placer:SetBuilder(ThePlayer, nil, placer_item)

        local function _testfn(pt) 
          return placer_item:IsValid() and
          placer_item.replica.inventoryitem ~= nil and
          placer_item.replica.inventoryitem:CanDeploy(pt)
        end

        deployplacer.components.placer.testfn = _testfn

        -- deployplacer:RemoveComponent("placer")
        -- deployplacer:AddComponent("placer_orig")
        -- deployplacer.components.placer = deployplacer.components.placer_orig

        local function _replace(self, dt)

          self.can_build = self.testfn == nil or self.testfn(self.inst:GetPosition())
          local color = self.can_build and Vector3(.25,.75,.25) or Vector3(.75,.25,.25)
          self.inst.AnimState:SetAddColour(color.x, color.y, color.z ,0)

        end
        deployplacer.components.placer.OnUpdate = _replace

        local function _reposition(self) 
          local pos = Vector3(ThePlayer.Transform:GetWorldPosition())
          pos = Vector3( math.floor(pos.x), math.floor(pos.y), math.floor(pos.z))
          self.Transform:SetPosition((pos + self.offset ):Get()) 
        end
        deployplacer.offset = Vector3( (xOff -1) * placerGap  , 0, (zOff-1) * placerGap)
        deployplacer.reposition = _reposition
        deployplacer:reposition()
        deployplacer.components.placer:OnUpdate(0)

      end
    end

  end
end

function ChoresWheel:BtnLoseFocus(task, icon)
  if task == "book_gardening" and icon == "book_gardening" then
    if self.placers == nil then return end 
    for k, v in pairs(self.placers) do
      v:Remove()
    end
    self:StopUpdating()
    self.placers = nil
  end 
end


function ChoresWheel:DoTask(task) 
  local flags = {}
  for key, flag in pairs(self.flag[task]) do
    flags[key] = flag
  end

  ThePlayer.components.auto_chores:SetTask(task, flags, self.placers)
  self.placers = nil 
end 


function ChoresWheel:OnUpdate(dt ) 
  if self.placers == nil then return end 
  for k, v in pairs(self.placers) do
    v:reposition()
    v.components.placer:OnUpdate(dt)
  end
end 

return ChoresWheel