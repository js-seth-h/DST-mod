name = "Battle Sense"  
description = "Battle Sense(a.k.a 'To Be A Fighter') is helpful tool for combat & life guard"

author = "js.seth.h"
version = "1.6a"

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
--This determines whether it causes a server to be marked as modded (and shows in the mod list)
client_only_mod = true

server_filter_tags = {"combat", "fighter", "weapon", "damange indicators", "damange", "auto", "equip", "equipment", "amulet"}

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
