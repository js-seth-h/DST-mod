
function dump(label, t)
  if t == nil then
    print(label," got nil table")
    return 
  end 
  print(label, ">>>>>>>>>>>>>>>>>>>>>>>>>")  
  for k,v in pairs(t) do  print("     ", k, v) end 
  print("<<<<<<<<<<<<<<<<<<<<<<<<<<<<")
end

local Inst = require "util.instance" 
local PrefabLibary = require("util.prefablibrary")  

local WeaponLib = PrefabLibary(function (proto)
  local stat = {} 
  if proto.components.armor ~= nil then 
    stat.armor = {}
    stat.armor.absorb_percent = proto.components.armor.absorb_percent
    stat.armor.maxcondition = proto.components.armor.maxcondition
    stat.armor.hasTags = proto.components.armor.tags ~= nil
  end
  if proto.components.weapon ~= nil then
    stat.weapon = {}
    stat.weapon.damage = proto.components.weapon.damage
    stat.weapon.longdistance = proto.components.weapon.attackrange ~= nil
    stat.weapon.projectile = proto.components.projectile ~= nil
    stat.weapon.reasonable = stat.weapon.damage >= TUNING.SPEAR_DAMAGE -- reasonable weapon = spear or stronger 
    if proto.components.finiteuses ~= nil then  
      stat.weapon.total = proto.components.finiteuses.total
    else
      stat.weapon.total = 999999
    end 
  end
  return stat
  end)

local EnemyLib = PrefabLibary( function(proto) 
  local stat = {} 
  if proto.components.combat ~= nil then 
    stat.combat = {}
    stat.combat.damage = proto.components.combat:CalcDamage(ThePlayer) or 0 
  end  
  return stat
  end)

local FighterSense = Class(function(self, inst) 
  self.inst = inst
  -- self.life_threat = false
  -- self:installMasterSim()  
  -- self.inst:DoPeriodicTask(0.3, function() self:Contingency() end)

  self:installOffenceSense()
  self:installDefenceSense()

  end,
  nil,
  { })



local PREFAB_LIFE_GIVING_AMULET = "amulet"


local function _weaponFinder(item) 
  return item.stat.weapon ~= nil 
end
local function _weaponSorter(a, b)  
  local dmgA = a.stat.weapon.damage
  local dmgB = b.stat.weapon.damage  
  local pctA = Inst(a):inventoryitem_PercentUsed() / 100
  local pctB = Inst(b):inventoryitem_PercentUsed() / 100
  local durationA = a.stat.weapon.total * pctA 
  local durationB = b.stat.weapon.total * pctB

  -- print("WS", dmgA, dmgB, durationA, durationB)
  if dmgA ~= dmgB then
    return dmgA > dmgB
  else  
    return durationA < durationB 
  end 
end
local function _armorFinder(item) 
  if not item.stat.armor then return false end 
  local ITEM = Inst(item)
  if ITEM:equippable_EquipSlot() ~= EQUIPSLOTS.BODY then return false end  
  local pct = ITEM:inventoryitem_PercentUsed()
  if pct <= 0 then return false end
  -- if item.components.armor:GetPercent() <= 0 then return false end
  return true
end
local function _armorAmuletFinder(item)
  if item.prefab == PREFAB_LIFE_GIVING_AMULET then return true end
  return _armorFinder(item) 
end

local function _armorSorter(a, b)  
  if a.prefab == PREFAB_LIFE_GIVING_AMULET then return true end
  if b.prefab == PREFAB_LIFE_GIVING_AMULET then return false end

  local absorbA = a.stat.armor.absorb_percent
  local absorbB = b.stat.armor.absorb_percent 
  local pctA = Inst(a):inventoryitem_PercentUsed() / 100
  local pctB = Inst(b):inventoryitem_PercentUsed() / 100
  local durationA = a.stat.armor.maxcondition * pctA
  local durationB = b.stat.armor.maxcondition *  pctB
  if a.stat.armor.hasTags then  durationA = 0 end
  if b.stat.armor.hasTags then  durationB = 0 end 

  -- print("AS", absorbA, absorbB, durationA, durationB)

  if absorbA ~= absorbB then
    return absorbA > absorbB
  else  
    return durationA < durationB 
  end 
end

local function _headFinder(item) 
  if not item.stat.armor then return false end
  local ITEM = Inst(item)
  if ITEM:equippable_EquipSlot() ~= EQUIPSLOTS.HEAD then return false end  
  local pct = ITEM:inventoryitem_PercentUsed()
  if pct <= 0 then return false end 
  return true
end  
local function _equippable(item)
  return Inst(item):equippable() ~= nil 
end 


function FighterSense:installOffenceSense()
  local fightersense = self
  local player = self.inst

  local _origFnPA = nil 
  local function _overridePA (self, bufferedaction, run, try_instant) 
    -- print("_overridePA")
    fightersense:DoOffenseSense(bufferedaction, run, try_instant)
    _origFnPA(self, bufferedaction, run, try_instant)
  end  
  if TheWorld.ismastersim or IsDST() == false then  
    print("installOffenceSense - PushAction")
    _origFnPA = player.components.locomotor.PushAction
    player.components.locomotor.PushAction = _overridePA
  else 
    print("installOffenceSense - PreviewAction")
    _origFnPA = player.components.locomotor.PreviewAction
    player.components.locomotor.PreviewAction = _overridePA
  end  

end
function FighterSense:installDefenceSense()
  local fightersense = self
  local player = self.inst

  -- 한대 맞으면 방어구 장착 
  local function _onattacked (self, data) 
    data.source = "attacked"
    fightersense:DoDefenseSense(data) 
  end 
  player:ListenForEvent("attacked", _onattacked)

  local function _onArmorBroke(inst, data)
    -- print("_onArmorBroke")
    data.source = "armorbroke"
    fightersense:DoDefenseSense(data) 
  end
  player:ListenForEvent("armorbroke", _onArmorBroke)


  -- local function _armuletCheck(inst, data)
  --   if data.slot ~= EQUIPSLOTS.BODY then return end
  --   fightersense:UpdateAmulet()
  -- end
  -- player:ListenForEvent("equipped", _armuletCheck)
  -- player:ListenForEvent("unequipped", _armuletCheck)
  
  -- self:UpdateAmulet()
  if IsDST() then

    player:DoPeriodicTask(0.3, function() self:Contingency() end) 
  else 
    local _origFnGA = self.inst.components.combat.GetAttacked
    local function _overrideGA (self, attacker, damage, weapon) 
      fightersense:ContingencySingle(attacker, damage, weapon)
      _origFnGA(self, attacker, damage, weapon)
    end
    self.inst.components.combat.GetAttacked = _overrideGA
  end
end 
-- function FighterSense:UpdateAmulet()
--   local bodyitem = Inst(self.inst):inventory_GetEquippedItem(EQUIPSLOTS.BODY)
--   self.hasAmulet = bodyitem.prefab == "amulet"
-- end

function FighterSense:DoOffenseSense(bufferedaction, run, try_instant)
  if TUNING.FS_COMBAT_INSTINCT == false then return end
  
  local player = self.inst
  if bufferedaction.action == ACTIONS.ATTACK then 
    local change_hand = true  -- 기본적으로 무기를 변경한다. 
    local hands = Inst(player):inventory_GetEquippedItem(EQUIPSLOTS.HANDS)
    if hands ~= nil and (TUNING.FS_HOLD_PROJECTILE or TUNING.FS_HOLD_MELEE) then
      local stat = WeaponLib:Get(hands)
      if TUNING.FS_HOLD_PROJECTILE and stat.weapon.longdistance then
        change_hand = false
      end 
      if TUNING.FS_HOLD_MELEE and stat.weapon.reasonable then
        change_hand = false
      end 
    end 
    self:DoAutoEquip(change_hand,true,true) 
  end 

end


function FighterSense:DoDefenseSense(data) 
  if TUNING.FS_DEFENSIVE_INSTINCT == false then return end
  self:DoAutoEquip(false,true,true) 
end

function  FighterSense:ContingencySingle(attacker, damage, weapon)
  -- DS/ROG 전용
  if TUNING.FS_DEFENSIVE_INSTINCT == false then return end 
  local takenDmg = self:ExpectedDamage(damage)
  if Inst(self.inst):health_Current() <= takenDmg then
    self.live_giving_amulet = true  
  end
  -- print("ContingencySingle", Inst(self.inst):health_Current(),  takenDmg, self.live_giving_amulet )
  self:DoAutoEquip(false, true, true)
end

function FighterSense:Contingency()
  if TUNING.FS_DEFENSIVE_INSTINCT == false then return end 
  local is_contingency, life_threat, takenDmg = self:AwareContingency() 
  -- self.life_threat = life_threat
  if is_contingency then
    self:DoAutoEquip(false,true,true) 
  end 
end 
function FighterSense:IsThreat(ent)
  if ent == self.inst then return false end
  local ENT = Inst(ent)
  if ENT:combat() == nil then return false end 
  local stat = EnemyLib:Get(ent)  
  if stat.combat.damage <= 0 then return false end 
  local target = ENT:combat_GetTarget()
  if target ~= self.inst then return false end
  if ent:HasTag("player") then return true, nil end

  local range = (ENT:combat_GetAttackRangeWithWeapon() + 1.0 ) -- 거리를 반올림하여 공격거리와 비교하여 공격이.  그래서 여유범위 추가
  local rangeSq = range * range
  local distSq = distsq(ent:GetPosition(), self.inst:GetPosition()) 
  if distSq >  rangeSq then return false end 

  return true, stat
end
function FighterSense:ExpectedDamage(damage) 
 local INST = Inst(self.inst)
 local items = INST:inventory_GetAllItems()
  -- dump("inven", items) 
  items = self:FilteredItems(items, _equippable)
  -- dump("_equippable", items) 
  items = self:FindStat(items)
  -- dump("FindStat", items) 


  local armors = self:FilteredItems(items, _armorFinder)
  table.sort(armors, _armorSorter)
  -- dump("armors", armors) 


  local helmets = self:FilteredItems(items, _headFinder)
  table.sort(helmets, _armorSorter)

  -- dump("helmets", helmets) 

  -- 계산한 방어구를 장착함을 전제로, 데미지를 계산한다.
  local armor_absorb = 0
  if armors[1] ~= nil then armor_absorb = armors[1].stat.armor.absorb_percent end
  local helmet_absorb = 0
  if helmets[1] ~= nil then helmet_absorb = helmets[1].stat.armor.absorb_percent end

  return damage * ( 1 - armor_absorb) * ( 1- helmet_absorb) 
end

function FighterSense:AwareContingency()
  local is_contingency = false
  local life_threat = false 
  local dmgSum = 0
  local takenDmg = 0
  -- print("AwareContingency      -------------------------------------------")
  local  inst = self.inst
  local x,y,z = inst.Transform:GetWorldPosition()
  local radius = 15
  local ents = TheSim:FindEntities(x,y,z, radius) -- or we could include a flag to the search?
  for k,ent in pairs(ents) do
    local threat, stat = self:IsThreat(ent)
    if threat then is_contingency = true end
    if stat ~= nil then
      dmgSum = dmgSum + stat.combat.damage
    end 
    -- if ENT:combat() ~= nil then 
    --   local stat = EnemyLib:Get(ent)  

    --   if self:IsThreat(ent, ENT, stat) then
    --     is_contingency = true
    --     dmgSum = dmgSum + stat.combat.damage
    --   end
    -- end 
  end


  -- Live Giving Amulet이 DST에서는 동작이 달라서 사용안함 
  if false and is_contingency then
    takenDmg = self:ExpectedDamage(dmgSum)
    if Inst(self.inst):health_Current() <= takenDmg then
      life_threat = true
    end 
  end 
  -- print("AwareContingency = false")
  return is_contingency, life_threat, takenDmg
end

function FighterSense:DoAutoEquip(hand, head, armor) 

  local items = Inst(self.inst):inventory_GetAllItems() 
  items = self:FilteredItems(items, _equippable)
  items = self:FindStat(items)

  if hand then 
    -- print("HANDS ------------------")
    self:ProperEquip(items, _weaponFinder, _weaponSorter, EQUIPSLOTS.HANDS)
  end
  if head then 
    -- print("HEAD ------------------")
    self:ProperEquip(items, _headFinder, _armorSorter, EQUIPSLOTS.HEAD)
  end

  if armor then 
    -- print("BODY ------------------")
    local finder = _armorFinder
    if self.live_giving_amulet then finder = _armorAmuletFinder end
    -- self:ProperEquip(items, _armorAmuletFinder, _armorSorter, EQUIPSLOTS.BODY)
    self:ProperEquip(items, finder, _armorSorter, EQUIPSLOTS.BODY)
  end
end  

function FighterSense:FilteredItems(items, finder)
  -- print("FilteredItems")  
  local result = {}
  for k,v in pairs(items) do
    if finder(v) then
      -- print("ok ", v)
      table.insert(result, v)
    else 
      -- print("bad", v)
    end
  end
  return result
end
function FighterSense:FindStat(items)
  for k, item in pairs(items) do 

    item.stat = WeaponLib:Get(item)
  end 
  return items
end  

function FighterSense:ProperEquip(items,  finder, sorter, eq_slot) 
  local INST = Inst(self.inst)
  local items = self:FilteredItems(items, finder)  
  table.sort(items, sorter)   
  -- print("   ------- sorted ")
  -- for k,v in pairs(items) do  print("      sorted", k, v) end 
  if  items[1] ~= nil then
    if INST:inventory_GetEquippedItem(eq_slot) ~= nil and items[1] == INST:inventory_GetEquippedItem(eq_slot) then
      return  
    end 
    if IsDST() then
      INST:inventory_UseItemFromInvTile(items[1])
    else 
      self.inst.components.inventory:Equip(items[1])
    end 
  end 

end

-- ADDTEST( function () 
-- end )

return FighterSense