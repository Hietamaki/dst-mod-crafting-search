name = 'Type to Craft'
description = 'Finder for crafting. You can search and craft items with typing the recipe\'s name using only your keyboard. Allows building items quickly with predictive text and without having to navigate menus.\n\nCrafts the item with the skin that was last chosen.\n\n Default bindings:\n C = Open craft prompt.\n Shift+C = Repeat last craft.'
author = 'Sakea'
version = '0.0000000001'
forumthread = ''

api_version = 10
priority = 1

dont_starve_compatible = false
reign_of_giants_compatible = false
shipwrecked_compatible = false
dst_compatible = true

all_clients_require_mod = false
client_only_mod = true
--server_filter_tags = {}

icon_atlas = 'atlas.xml'
icon       = 'modicon.tex'


configuration_options =
{
  {
    name = "bind",
    label = "Open crafting input",
    hover = "Bind button to open crafting input",

    options = {
      { description = "C", data = "KEY_C" },
      { description = "F", data = "KEY_F" },
      { description = "R", data = "KEY_R" },
      { description = "X", data = "KEY_X" },
      { description = "F1 (F2 repeats)", data = "KEY_F1" },
    },

    default = "KEY_C"
  },
  {
    name = "modifier",
    label = "Repeat last crafting",
    hover = "Bind which modifier + Craft button repeats last crafting. ",

    options = {
      { description = "Shift", data = "KEY_SHIFT" },
      { description = "Ctrl", data = "KEY_CTRL"},
      { description = "Alt", data = "KEY_ALT" },
    },

    default = "KEY_SHIFT"
  },
}