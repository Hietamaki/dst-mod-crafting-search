# Don't Starve Together mod: Type to Craft

## Problem
It is hard to find from the menu what you want to craft.

## Solution

Use typing for faster crafting.

## References
 - `screens/chatinputscreen.lua`
 - mod: Craft Hotkey
 - mod: Slash Commands For Creative

## Dev log

### v.01 - What I've learned
Turns out there is no official documentation, not even API. So the way to learn is to find other mods with similar functionality and using the game scripts as reference.

So far I've found no way to reload specific script, but running c_reset() seems to work as long as there is no error in code, in which case game needs reboot. So the dev experience is a bit laborous. Crash logs can be found in ~/.klei/ (Linux)

Game functions can be run with adding GLOBAL. prefix to functions. Though some don't seem to require it like TheFrontEnd.



- GitHubiin
- GitHubiin issuet
- Pilko koodi osiin
- debugViesteihin joku parempi (ruudun laitaan)
- Nopeempi käynnistys suoraan peliin modi päällä
*-* ESC ongelma
- ChatLOG pois
- korvaa " " -> _
- Resurssit ei riitä viesti erikseen
- Resurssit ei riitä -> kerro mitä puuttuu
- vaihda hotkey
- autoprompt toimiin
- lokalisaatiolle parempi vaihtoehto?
- semanttinen haku
- fuzzy search
- menu päällä -> ei toimivaksi
- live search (kuvilla)
- API versio uudempaan?
- ennakkosyötössä ärsyttävä jos teksti on täysin sama kuin ehdotettu ja ei rakenna suoraan -> voisi siis lähettää tekstin heti kun painaa entteriä (valitsee ennakkosyötön)

1. chess_piece > chess piece. käytännössä lokalisoidut nimet hakuun
2. erottele resurssi ja reseptivika
3. kerro mitä uupuu
4. set hotkey (configure modin asetutksista)
5. c näppäin ->
6. esci päällä ei voi avata findia
7. refaktoroi koodi eri komponentteihin! Onko GLOBAL pakko käyttää vai voiko importtaa?
8. kuiskaa kaikki viestit pelaajalle pelkästään
9. repeat previous
10. miten monta esinettä uupuu