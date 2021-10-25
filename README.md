# pa-xtouch-control
 Control PulseAudio and X with a Behringer X-Touch Mini
 
 # Dependencies
 This program was written to work within the stock Pop!_OS desktop environment (running X and PulseAudio) with the `xdotool` package installed to enable binding the currently-focused application to a column.  
 
I am open to supporting other window systems if there is sufficient interest.

# Installation as a foreground script

Download the script (via `curl` or `wget`) and `chmod +x pa_xtouch_control` to make it executable. Then run it with `./pa_xtouch_control` and test your Behringer X-Touch Mini to make sure everything is working.

# Installation as a daemon (`systemd`)
1. Download the `pa_xtouch_control.sh` and `pa_xtouch_control.service` files. 
2. Make the `pa_xtouch_control.sh` script executable with `chmod +x pa_xtouch_control.sh`.
3. Place `pa_xtouch_control.sh` into `/usr/bin/` with `mv pa_xtouch_control.sh /usr/bin/`.
4. Place `pa_xtouch_control.service` into `~/.config/systemd/user/` (just 'user', not your username) with `mv pa_xtouch_control.service ~/.config/systemd/user/`
5. Create this directory if it does not already exist `mkdir -p ~/.config/systemd/user/`.
6. Reload systemd with `systemctl --user daemon-reload`.
7. Enable autostart of the systemd service with `systemctl --user enable pa_xtouch_control.service`.
8. Start the service with `systemctl --user start pa_xtouch_control.service`.

You can do all of these steps with:

```bash
curl -o /usr/bin/pa_xtouch_control.sh https://raw.githubusercontent.com/Jafner/pa-xtouch-control/main/pa_xtouch_control.sh && \
chmod +x /usr/bin/pa_xtouch_control.sh && \
mkdir -p ~/.config/systemd/user && \
curl -o ~/.config/systemd/user/pa_xtouch_control.service https://raw.githubusercontent.com/Jafner/pa-xtouch-control/main/pa_xtouch_control.service && \
systemctl --user daemon-reload && \
systemctl --user enable pa_xtouch_control.service && \
systemctl --user start pa_xtouch_control.service
```

 
# Modifying the script

I've done my best to make the script readable and modifyable. Here is a summary of how the script is laid out:  

## Define functions
After some comments, we begin defining functions, which all follow the format

```bash
function_name() {
	# some code here
}
```

Not all of these are used. Some exist for the purpose of making support for other modes (mackie vs. standard mode) easier. 

If you know any bash (terminal commands), you can define your own functions by copying and altering the functions I've written. 

These functions are not exactly optimized, but they should be readable.

## Run the initialization, then main function.
In this script, I initialize the script by setting the col_N_app_pid values (where N is 1-8) to -1, which ensures they will not accidentally affect applications before they are intentionally set.

The main function watches the signals coming in from the "X-TOUCH MINI" device and checks them against its processing logic. I started using Mackie mode, which works differently from Standard mode. Then I switched to developing for Standard mode (only layer A supported for now) because it handles the lighting automatically, instead of requiring sending signals back to the device. 

## Binding an application
When you press a knob on the X-Touch Mini, the script binds the currently-focused-window's process ID (PID) to that column of the controller (the knob, top button, and bottom button). 

Note: PulseAudio does not directly interact with processes, but rather audio streams, which have their own numbering system within PulseAudio. These "Stream Index" values are not "sticky", so refreshing a Firefox YouTube video might cause the stream index to change for that audio stream.

## Changing volume
After binding an application to a column, you can adjust the volume of that application with the rotary encoder. In standard mode, each time you move the encoder it will send a new volume level to the application (between 0% and 127%). In Mackie mode, your changes will be processed as relative (+N% or -N%) to the current volume with no upper limit.
## (Un)Muting an application
After binding an application to a column, you can toggle muting the volume of that application with the top button below the encoder. In standard mode, you can press the button (causing it to light up) to mute the bound application. In Mackie mode, each time you press the button it will toggle the mute of the application. 

## Media Keys
By default (Mackie mode or standard mode), the keys marked with the media key icons for FF, RW, Play/Pause, and Stop work as media keys by sending instructions to the X server to control media.

# Expanding beyond the default configuration
I am more than happy to approve good pull request to add functionality to this script. If you have a different controller with different MIDI signals, I am happy to support your device (as much as reasonable).

## Adding devices
For most MIDI devices, this simply requires copy-pasting the main function to handle the Note on or Control change signals from your controller. I cannot test these PRs, but if they look reasonable, I will approve them.

## Adding functions
If you would like to add a function, please submit a pull request! So long as your pull request adds a function that supports an existing environment with new functionality, I will almost certainly approve it. 
If it adds support for a new environment (device, audio server, or X server), I will probably still approve it.
