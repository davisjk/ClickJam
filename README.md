# AHKAutoClicker
## Terms

* AHK = AutoHotKey
* The letters 'L' and 'R' before a key specify either the left or right variation of that key.
* The 'command queue' is the list of functions the autoclicker performs in order.
* The 'key spam' is the configured keyboard key that is being pressed repeatedly before each function in the command stack (off by default).

## Usage
_Formatted such that the key combination is on the left hand side of '=' and the functionality is on the right hand side._

### AHK script control keys

* `F1` = (Un)pause the application thread. The autoclicker will pause but inputs to modify the command stack can still be performed including stopping the autoclicker because of multithreading.
* `F2` = Suspend the application. The autoclicker will only respond to F2 again while suspended. If the autoclicker is running, it keeps clicking and can't be stopped until F2 is pressed again.
* `F3` = Reload the script stopping any running application threads and resetting all options to their defaults.
* `F4` = Edit the script (but why would you want to do that when it's PERFECT :þ).
* `F6` = Exit all application threads.

### Turning on/off the autoclicker
_If any variant of the autoclicker is on, the below hotkeys will instead stop the autoclicker._

* `` ` `` = Start left clicking where the mouse is (this is only ever left click, not affected by the command stack).
* ``LShift + ` `` = Use the command queue to click and press keys in order. Alternately, if the command queue is empty, left click in the location the mouse was in when the autoclicker was started.
* Clicking any mouse button or moving the mouse wheel will stop the autoclicker and also click or scroll as normal.

### Modifying the command queue

* ``LCtrl + ` `` = Remove one from queue
* `LCtrl + LShift + 3` = Clear the queue

Single click:

* ``LAlt + ` `` = Move without clicking
* `LAlt + LButton` = Left click
* `LAlt + RButton` = Right click
* `LAlt + MButton` = Middle click
* `LAlt + XButton1` = Mouse 4 click
* `LAlt + XButton2` = Mouse 5 click

Click randomly within a rectangle. Click and drag to create a corner of the rectangle at the location the buttons were pressed and a corner where they were let go:

* ``LShift + LAlt + ` `` = Move without clicking
* `LShift + LAlt + LButton` = Left click
* `LShift + LAlt + RButton` = Right click
* `LShift + LAlt + MButton` = Middle click
* `LShift + LAlt + XButton1` = Mouse 4 click
* `LShift + LAlt + XButton2` = Mouse 5 click

Keyboard keys:

* ``LCtrl + LShift + ` `` = Then press a key to change the 'key spam' key to that key at this point in the queue 
* ``LCtrl + LAlt + ` `` = Turn 'key spam' on at this point in the queue
* ``LCtrl + LShift + LAlt + ` `` = Turn 'key spam' off at this point in the queue
* ``RCtrl + ` `` = Then press a key to add a single press of that key to the queue

### Other features

Config file:

* `LCtrl + LShift + R` = Read from the current file, 0-9
* `LCtrl + LShift + W` = Write to the current file, 0-9
* `LShift + LAlt + [0-9]` = Change the file number that is read from and written to. For example, `LShift + LAlt + 1` changes the file to 'ClickJam.1.json'

Modify how the script is run:

* `LCtrl + LShift + 1` = Decrease the delay between clicks by 5ms to a minimum of 1ms
* `LCtrl + LShift + 2` = Increase the delay between clicks by 5ms
* `LCtrl + LShift + 4` = Then press a key to change the 'key spam' key to that key. This can be changed by what's on the queue and will not be changed back when the script is stopped
* `LCtrl + LShift + 5` = Turn 'key spam' on or off. This can be changed by what's on the queue and will not be changed back when the script is stopped

## Modification notes (boils down to AHK basics that bit me in the rear)

* You may want to modify some default configuration values. You can do this either in an ClickJam.#.json file as explained above, or you can modify the Global Constants section at the top of 'main.ahk'.
* `` ` `` is the escape character in AHK and also featured heavily in this autoclicker script -_-
* `a := b` sets the variable a to the value of the variable b
* `a = b` sets the variable a to the string "b"
