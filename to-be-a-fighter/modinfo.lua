name = "To Be A Fighter"
description = [===[
             To Be A Fighter - ver 1.5
================================================================

As a Fighter, Characters have to be prepared for battle. 

Features 
------------------------------ 

=== Combat Instinct === 

When you attack, you will automatically equip a weapon, helmet and armor piece. 

=== Defensive Instinct === 

When attacked or a hostile approaches, you will automatically put on a helmet and armor piece

(DS/RoG only) It will put on a 'Life Giving Amulet' automatically as well, if you have an amulet. 


=== Damage indicators === 

Shows exactly how much health was lost/gained upon healing or being hit.


=== Gameplay Controls === 

Widget Key (Default "C") show widget that controls options.  

4 buttons are provided. 

Button 1. Toggle Enable Combat Instinct or Disable Combat Instinct in 5 Min. 
Button 2. Toggle Enable Defensive Instinct or Disable Combat Instinct in 5 Min. 
Button 3. In Combat Instinct if a melee weapon is equipped, Toggle Change weapon or not 
Button 3. In Combat Instinct if a projectile weapon is equipped, Toggle Change weapon or not 



Mod Config
------------------------------ 

* Combat Instinct 
Set Default Toggle state of Widget Button 1 
* Defensive Instinct 
Set Default Toggle state of Widget Button 2 
* CI: Keep Melee 
Set Default Toggle state of Widget Button 3 
* CI: Keep Projectile 
Set Default Toggle state of Widget Button 4 

The other options are trivial. 



Changes History 
---------------------
1.5
  fix butterfly crash

1.4
  Widget is Supported in DS/RoG

1.0 ~ 1.3
  Add Life Giving Amulet functionality
  Fix long distance weapon
  Support Widget in DST

0.1 
  Initial development 


]===]


author = "js.seth.h"
version = "1.5"

forumthread = ""

-- This lets other players know if your mod is out of date, update it to match the current version in the game
api_version = 10

-- Can specify a custom icon for this mod!
-- icon_atlas = "ExtendedIndicators.xml"
-- icon = "ExtendedIndicators.tex"

-- Specify compatibility with the game!
dont_starve_compatible = true
reign_of_giants_compatible = true
dst_compatible = true

all_clients_require_mod = false
clients_only_mod = false

server_filter_tags = {"battle", "fighter", "weapon", "damange indicators", "damange", "equipment"}

icon_atlas = "modicon.xml"
icon = "to-be-fighter.tex" 
local alpha = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"}
local KEY_A = 97
local keyslist = {}
local Default_Key =  "C" 
for i = 1,#alpha do 
  keyslist[i] = {description = alpha[i],data = i + KEY_A - 1}
  if alpha[i] == Default_Key then
    Default_Key = keyslist[i].data
  end
end



configuration_options =
{
    {
        name = "togglekey",
        label = "Widget Button",
        options = keyslist,
        default = Default_Key
    },      
    -- {
    --   name = "FIGHTER_SENSE_TRIGGER",
    --   label = "Fighter Sense Trigger",
    --   options = {
    --     {description = "Universal", data = "universal"},
    --     {description = "Keyboard Only", data = "keyboard"},
    --   },

    --   default = "universal",

    -- },

    -- {
    --   name = "LIGHTNING_REFLEXES",
    --   label = "Lightning Reflexes",
    --   options = {
    --     {description = "On", data = "on"},
    --     {description = "Off", data = "off"},
    --   },

    --   default = "on", 
    -- },
    {
      name = "FS_COMBAT_INSTINCT",
      label = "Combat Instinct",
      options = {
        {description = "On", data = "on"},
        {description = "Off", data = "off"},
      },

      default = "on", 
    },
    {
      name = "FS_DEFENSIVE_INSTINCT",
      label = "Defensive Instinct",
      options = {
        {description = "On", data = "on"},
        {description = "Off", data = "off"},
      },

      default = "on", 
    },
    {
      name = "FS_HOLD_MELEE",
      label = "CI: Keep Melee",
      options = {
        {description = "On", data = "on"},
        {description = "Off", data = "off"},
      },

      default = "off", 
    },
    {
      name = "FS_HOLD_PROJECTILE",
      label = "CI: Keep Projectile ",
      options = {
        {description = "On", data = "on"},
        {description = "Off", data = "off"},
      },

      default = "on", 
    },

    {
      name = "SHOW_DAMAGE",
      label = "Show Damage",
      options = {
        {description = "On", data = "on"},
        {description = "Off", data = "off"},
      },

      default = "on",

    },
    {
      name = "SHOW_HEAL",
      label = "Show Heal",
      options = {
        {description = "On", data = "on"},
        {description = "Off", data = "off"},
      },

      default = "on",

    },

    -- {
    --   name = "display_mode",
    --   label = "Display Mode",
    --   options = {
    --     {description = "Bouncy", data = "bouncy"},
    --     {description = "Waving", data = "waving"},
    --     {description = "Straight", data = "straight"},
    --   },

    --   default = "waving",

    -- },


    {
      name = "HIDE_HP_CHANGES_LESS",
      label = "Hide HP Changes Less",
      options = {
        {description = "2 HP", data = "2"},
        {description = "5 HP", data = "5"},
        {description = "10 HP", data = "10"},
        {description = "20 HP", data = "20"},
      },

      default = "2",
    } 
  }
