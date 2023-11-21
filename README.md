# ClickJam -- AHK Customizeable Auto Clicker/Macro
## Terms
* AHK = AutoHotKey
* The letters 'L' and 'R' before a key specify either the left or right variation of that key.
* The 'command queue' is the list of functions ClickJam performs in order.
* The 'key spam' is the configured keyboard key that is being pressed repeatedly before each function in the command queue (off by default).
## Usage
_Formatted such that the key combination is on the left hand side of '=' and the functionality is on the right hand side._
### AHK script control keys
* F1 = (Un)pause ClickJam. ClickJam will pause but inputs to modify the command queue can still be performed including stopping ClickJam because of multithreading.
* F2 = Suspend ClickJam. ClickJam will only respond to F2 again while suspended. If ClickJam is running, it keeps clicking and can't be stopped until F2 is pressed again.
* F3 = Reload the script stopping any running application threads and resetting all options to their defaults.
* F4 = Edit the script (but why would you want to do that when it's PERFECT :þ).
* F6 = Exit all application threads.
* F7 = Prevent modifications to the command queue.
### Turning on/off the autoclicker
_If any variant of ClickJam is on, the below hotkeys will instead stop ClickJam._
* **Numpad Period** = Start left clicking where the mouse is (this is only ever left click, not affected by the command stack).
* **Numpad Zero** = Use the command queue to click and press keys in order. Alternately, if the command queue is empty, left click in the location the mouse was in when ClickJam was started and lock the mouse.
* Clicking any mouse button or moving the mouse wheel will stop the autoclicker and also click/scroll as normal.
### Modifying the command queue
* todo
### Other features
* todo
## Modification notes (boils down to AHK basics that bit me in the rear)
* You may want to modify some default configuration values. You can do this either in a ClickJam.#.ini file as explained above, or you can modify the Global Constants section at the top of ClickJam.ahk.
* \` is the escape character in AHK and was also featured heavily in this autoclicker script -_-
* **a := b** sets the variable a to the value of the variable b
* **a = b** sets the variable a to the string "b"
