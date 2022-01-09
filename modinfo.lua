name = 'Type to Craft'
description = 'You can search and craft items with typing the recipe\'s name using only your keyboard. Allows building items without navigating menus. \n\n Default bindings:\nC = Open craft prompt.\n Ctrl+C = Repeat last craft.'
author = 'Sakea'
version = '0.000000000000001'
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
    label = "Bind button to open crafting input",
    hover = "Configure which item types should be saved.",

    options = {
      { description = "C (Ctrl+C repeats)", data = "KEY_C" },
      { description = "F (Ctrl+F repeats)", data = "KEY_F" },
      { description = "X (Ctrl+X repeats)", data = "KEY_X" },
      { description = "F1 (F2 repeats)", data = "KEY_F1" },
    },

    default = "KEY_C"
  },
}