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



### Plans

1. refaktoroi koodi eri komponentteihin !!
2. set hotkey (configure modin asetutksista) !!
3. c näppäin ->
4. miten monta esinettä uupuu !
5. menu/esci päällä ei voi avata findia
6. ChatLOG pois

Evaluation:
- Nopeempi käynnistys suoraan peliin modi päällä
14. CI/CD: debug nappi automaattisesti disabled kun publish
- debugViesteihin joku parempi (ruudun laitaan)
8. (Onko GLOBAL pakko käyttää vai voiko importtaa?)
9. kuiskaa kaikki viestit pelaajalle pelkästään
-> Semanttinen haku -> käytä descriptioneita apuna -> (TF-IDF haku)
- fuzzy search
-> Custom GUI kuvakkeilla (iso)
- API versio uudempaan?
- GitHubiin issuet

Fixed:
12. Valmiiksi rakennettua nuotiota ei voi asettaa jos resurssit uupuu uuteen !
-> Spacetus ongelma
- lokalisaatiolle parempi vaihtoehto?
- ennakkosyötössä ärsyttävä jos teksti on täysin sama kuin ehdotettu ja ei rakenna suoraan -> voisi siis lähettää tekstin heti kun painaa entteriä (valitsee ennakkosyötön)
1. chess_piece > chess piece. käytännössä lokalisoidut nimet hakuun
- autoprompt toimiin
- Resurssit ei riitä -> kerro mitä puuttuu
2. erottele resurssi ja reseptivika
*-* ESC ongelma
13. Organize tasks
10. repeat previous
- GitHubiin