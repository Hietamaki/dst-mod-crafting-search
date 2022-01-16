## Dev log


### v.10^-6 micro series - DevLog

Keeping devlog is definitely good idea for gaining overview of the project, goals and the process. It helps to prioritize, reduce stress, share knowledge and motivate, thus bringing value.

I've used this unique metric multiply versioning system. The idea is to grow the number by multiple of 10 on new features that give utility to the project and continues development to that just iterate that number. This involves all actions that bring value to the project, not just code changes. The used unit is util, which aims to quantify the value a change brings, it does not measure the work that a change requires. So targeting high value - low work changes makes the most sense. Refactor could be high utility work also even when it doesn't show itself directly to users, since it eases up development process in the future. So if combined time for some future change, refactor and research is faster than hacking messy code base, refactor and research is more urgent than that new feature. 

Overall I'm getting seriously frustrated with my development experience since DST requires reboot basically every time it encounters error in code. And there's no command prompt to start the development server directly. This wastes so much time. I need more research on better practices.

#### Changes
- 1 µu: update devlog retrospectively
- 2 µu: combine devlog and changelog
- 3 µu: add GitHub/devlog link to workshop for more transparency
- 4 µu: add GPL license


### v.10^-9 nano series - Crafting Pop Up!

I originally started making custom GUI, but then it occured to me, that I could just use the existing crafting GUI and eliminate bunch of work. The menu also has skin support ready made. It required a lot hacking and hooking functions to get it to work nicely with the custom code. Big problem was the logic how the GUI elements interact with each other with respect to focus, reponsibilities, capturing control etc. In future I will aim to to focus on more systematic approach to understand the underlying system before hacking it together.

In the end I'm not sure if making my own implementation would have been any slower solution. In the end it's the direction I want to move this to. Another solution would have been trying to open the right menu from the existing crafting menu. But it would probably require a lot of overwriting functions and the endresult might still be hacky. So right now I'm not interested in that. Either way the GUI base needs some serious refactoring now.

#### Changes
- 1 nu: show recipe popup
- 10 nu: add skin support to recipies
- 100 nu: recipe popup is configurable on/off
- 200 nu: fix scaling without popup

### v.10^-12 pico series - Marketing

This was mainly marketing focus with improvements to requirement messaging. All the missing components are now listed. Main thing was to change the icon to something more informative. I think there was clear jump in adoption rate so communicating your mod is definitely important. It's a good exercise and I could focus more on it later.

Also added primitive skin support (as per request by audience).

#### Changes
- 1 pu: item uses last used skin 
- 10 pu: marketing: new icon
- 20 pu: marketing: new description
- 30 pu: marketing: new screenshot
- 100 pu: list all missed things
- 200 pu: fix plurals in requirements
- 300 pu: fix predictions updated when entered uppercase


### v.10^-15 femto series - Refactor & Binding configurations

This was a lot of refactoring (finally) and adding configuration. I also removed some code related to virtual keyboards inherited from chatinput, since I couldn't test it. Might need to bring that back for broader device support.

The external scripts can't access the GLOBAL object but it can be passed to them. Not sure how the encapsulation is supposed to help, I'm probably missing something.

#### Changes
- 100 fu: remove chat log
- 50 fu: refactor: renaming and moving
- 40 fu: refactor: rm unused code
- 30 fu: refactor: generate itemlists on demand
- 20 fu: refactor: add helper module
- 10 fu: refactor: split code
- 2 fu: custom modifier
- 1 fu: configurable binding


### v.10^-18 atto series - Steam workshop release!

At this point it was problematic that I had to keep commenting out the reboot debug button. So as a solution I found the [DevTools](https://github.com/dstmodders/mod-dev-tools) which handles that. I still need to investigate if there's more to these devtools.

Fixing bugs and QoL improvements. ESC is now captured if menu open, which helps big time with.

#### Changes
- 100 au: ESC does not open menu when prompt open
- 10 au: f1 also closes prompt
- 9 au: doesn't open with other huds open
- 8 au: fix crash with empty strings
- 7 au: fix texture size to power of 2
- 6 au: last item remembered when crafted through prompt
- 5 au: show with icon if invent/build
- 4 au: reorganize tasks
- 3 au: fix placing bufferd items
- 2 au: fix crash on pressing enter
- 1 au: steam workshop release

### v.10^-21 zepto series - Predictive text

Predictive text was introduced in the yocto series, but now it's actually usable with using the localized item names instad of internal identifiers. Creating missing prototypes and choosing predictions directly are two big things.
#### Changes

- 1 zu: prototype missing recipe
- 10 zu: search uses real item names
- 20 zu: lowercase predictive text
- 100 zu: choose predicted text directly
- 200 zu: lowercase text
- 300 zu: text can be entered also without #


### v.10^-24 yocto series - GitHub release

Adding version control, changelog tracking and release on GitHub. I added server reboot button to speed up the development process.

Adding basis for predictive text (use conveniently chat input) and tell about missing ingredients.
#### Changes
- 1 yu: release on github
- 2 yu: fix esc issue
- 3 yu: add readme
- 4 yu: inform when searched item not found
- 10 yu: predictive text
- 20 yu: inform if recipe not known
- 100 yu: inform missing ingredients
- 200 yu: add changelog
- 300 yu: repeat last recipe F1
- 400 yu: debug command: reboot F5
- 500 yu: inform how many missing ingredients required
- 600 yu: fix missing recipes


### v.10^-27 ronto series - POC

Starting my own mod! I used another mod as a basis to get things running. I'll end up replacing all the code so it's used only as a learning resource. To compartementalize the problem, my two immediate goals here are: (1) create item with code, (2) use typing to run code (3) use that inputted text as parameter (4) combine to create proof of concept. 

#### Changes
- 1 ru: copy paste mod as basis
- 2 ru: craft spear on command
- 10 ru: use command to create specific item
- 100 ru: show craft input with hotkey




### v.10^-30 quecto series - Learning phase
Turns out there is no official documentation, not even API. So the way to learn is to find other mods with similar functionality and using the game scripts as reference.

So far I've found no way to reload specific script, but running c_reset() seems to work as long as there is no error in code, in which case game needs reboot. So the dev experience is a bit laborous. Crash logs can be found in ~/.klei/ (Linux)

Game functions can be run with adding GLOBAL prefix to functions. Though some don't seem to require it like TheFrontEnd.

#### Changes
- 1 qu: unbundle scripts.zip
- 10 qu: change willow text to test modding
- 100 qu: research reference mods
- 200 qu: research basic modding info