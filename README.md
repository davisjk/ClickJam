# AHKAutoClicker
## Terms
* AHK = AutoHotKey
* The letters 'L' and 'R' before a key specify either the left or right variation of that key.
* The command stack is the list of functions the autoclicker performs in order.
* The key spam is the configured keyboard key that is being pressed repeatedly before each function in the command stack (off by default).
## Usage
_Formatted such that the key combination is on the left hand side of '=' and the functionality is on the right hand side._
### AHK script control keys
* f1 = (un)pause the script (the autoclicker will pause but inputs to modify the command stack can still be performed including stopping the autoclicker)
* f2 = ignore all input expect f2 (the autoclicker keeps clicking and can't be stopped until f2 is pressed again)
* f3 = reload the script (stops anything that is running like the autoclicker)
* f4 = edit the script (but why would you want to do that when it's PERFECT)
### Turning on/off the autoclicker
_If any variant of the autoclicker is on, the below hotkeys will instead stop the autoclicker._
* **\`** = start left clicking where the mouse is (this is only ever left click, not affected by the command stack)
* **LShift + \`** = use the command stack to click and press keys in order (if the command stack is empty, left click in the location the mouse was in when the autoclicker was started
* **LClick** = stop the autoclicker (and left click)
### Modifying the command stack
* todo
## Modification notes (boils down to AHK basics)
* \` is the escape character in AHK -_-
* **a := b** sets the variable a to the value of the variable b
* **a = b** sets the variable a to the string "b"
