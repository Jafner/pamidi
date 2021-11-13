#!/bin/bash
#
# Assumes a stock PopOS installation with xdotool
#
# X-Touch Mini Mappings (Mackie Mode)
# =====================
# Col#, Knob press, 	knob turn, 	top button, 	bottom button
# 1, 	32, 		16,  		89,		87
# 2,	33,		17,		90,		88
# 3,	34,		18,		40,		91
# 4,	35,		19,		41,		92
# 5,	36,		20,		42,		86
# 6,	37,		21,		43,		93
# 7,	38,		22,		44,		94
# 8,	39,		23,		45,		95
#
# Fader = 8
# ---------------------
# Misc. Info
# Knobs and buttons are all channel 0
# Fader is channel 8
# Button presses (including knobs) are notes at velocity 127
# Knob turns counter-clockwise are a value of 64 + n, 
# where n is a small number reflecting the amount it was turned within the last polling period
# Knob turns clockwise are a value of 0 + n,
# where n is a small number reflecting the amount it was turned within the last polling period

# Default column apps
# When you (re)start the script, it looks for the pids of the binaries specified for each column and sets the pid for each column
# These are overridden for the session by the bind_application function
 	
initialize(){
	echo "Initializing"
	echo "Checking for xdotool"
	if ! hash xdotool &> /dev/null; then
		echo "xdotool could not be found, exiting"
		exit 2
	else
		echo "xdotool found"
	fi
	echo "Waiting for pulseaudio service to start..."
	while [ ! $(systemctl --machine=joey@.host --user status pamidi.service) ]; do
		echo "Pulseaudio service not started, waiting..."
		sleep 2
	done
	col_1_app_pid=-1
	col_2_app_pid=-1
	col_3_app_pid=-1
	col_4_app_pid=-1
	col_5_app_pid=-1
	col_6_app_pid=-1
	col_7_app_pid=-1
	col_8_app_pid=-1
	assign_profile_1
	print_col_app_ids
	echo "Initialized pamidi"
	notify-send "Initialized pamidi"
}

assign_profile_1() {
	echo "Setting profile 1"
}

assign_profile_2() {
	echo "Setting profile 2"
}

print_col_app_ids() {
	echo "Col 1: $col_1_app_pid"
	echo "Col 2: $col_2_app_pid"
	echo "Col 3: $col_3_app_pid"
	echo "Col 4: $col_4_app_pid"
	echo "Col 5: $col_5_app_pid"
	echo "Col 6: $col_6_app_pid"
	echo "Col 7: $col_7_app_pid"
	echo "Col 8: $col_8_app_pid"
}

change_volume_mackie() {
	# take the pid of an app
	# set the volume of all streams for that app

	# get the volume change amount
	if (( $2 >= 64 )); then
		vol_change="-$(expr $2 - 64)"
	else
		vol_change="+$2"
	fi

	# take the pid and change the volume for each of its streams
	app_pid=$1

	all_sink_inputs="$(pacmd list-sink-inputs)"
	all_sink_inputs="$(paste \
		<(printf '%s' "$all_sink_inputs" | grep 'application.process.id' | cut -d'"' -f 2) \
		<(printf '%s' "$all_sink_inputs" | grep 'index: ' | rev | cut -d' ' -f 1 | rev))"

	echo "$all_sink_inputs" | while read line ; do
		pid=$(echo "$line" | cut -f1)
		if [[ "$pid" == "$1" ]]; then
			stream_id="$(echo "$line" | cut -f2)"
			pactl set-sink-input-volume $stream_id $vol_change% 2> /dev/null
		fi
	done
}

change_volume_standard() {
	# take the pid of an app
	# set the volume of all streams for that app

	# get the new volume value

	new_vol=$2

	# take the pid and change the volume for each of its streams
	app_pid=$1

	all_sink_inputs="$(pacmd list-sink-inputs)"
	all_sink_inputs="$(paste \
		<(printf '%s' "$all_sink_inputs" | grep 'application.process.id' | cut -d'"' -f 2) \
		<(printf '%s' "$all_sink_inputs" | grep 'index: ' | rev | cut -d' ' -f 1 | rev))"

	echo "$all_sink_inputs" | while read line ; do
		pid=$(echo "$line" | cut -f1)
		if [[ "$pid" == "$1" ]]; then
			stream_id="$(echo "$line" | cut -f2)"
			pactl set-sink-input-volume $stream_id $new_vol% 2> /dev/null
		fi
	done
}

change_mic_volume_standard(){
	# take the stream ID of a microphone and change its volume

	new_vol=$2

	mic_sid=$1


}

toggle_mute() {
	# take the pid of an app
	# toggle mute all streams for that app

	app_pid=$1

	all_sink_inputs="$(pacmd list-sink-inputs)"
        all_sink_inputs="$(paste \
                <(printf '%s' "$all_sink_inputs" | grep 'application.process.id' | cut -d'"' -f 2) \
                <(printf '%s' "$all_sink_inputs" | grep 'index: ' | rev | cut -d' ' -f 1 | rev))"

        echo "$all_sink_inputs" | while read line ; do
                pid=$(echo "$line" | cut -f1)
                if [[ "$pid" == "$1" ]]; then
                        stream_id="$(echo "$line" | cut -f2)"
                        pactl set-sink-input-mute $stream_id toggle
                fi
	done
}

mute_on() {
	# take the pid of an app
	# mute all streams for that app

	app_pid=$1

	all_sink_inputs="$(pacmd list-sink-inputs)"
        all_sink_inputs="$(paste \
                <(printf '%s' "$all_sink_inputs" | grep 'application.process.id' | cut -d'"' -f 2) \
                <(printf '%s' "$all_sink_inputs" | grep 'index: ' | rev | cut -d' ' -f 1 | rev))"

        echo "$all_sink_inputs" | while read line ; do
                pid=$(echo "$line" | cut -f1)
                if [[ "$pid" == "$1" ]]; then
                        stream_id="$(echo "$line" | cut -f2)"
                        pactl set-sink-input-mute $stream_id on
                fi
	done
}

mute_off() {
	# take the pid of an app
	# unmute all streams for that app

	app_pid=$1

	all_sink_inputs="$(pacmd list-sink-inputs)"
        all_sink_inputs="$(paste \
                <(printf '%s' "$all_sink_inputs" | grep 'application.process.id' | cut -d'"' -f 2) \
                <(printf '%s' "$all_sink_inputs" | grep 'index: ' | rev | cut -d' ' -f 1 | rev))"

        echo "$all_sink_inputs" | while read line ; do
                pid=$(echo "$line" | cut -f1)
                if [[ "$pid" == "$1" ]]; then
                        stream_id="$(echo "$line" | cut -f2)"
                        pactl set-sink-input-mute $stream_id off
                fi
	done
}

get_stream_index_from_pid(){
	all_sink_inputs="$(pacmd list-sink-inputs)"
	all_sink_inputs="$(paste \
		<(printf '%s' "$all_sink_inputs" | grep 'application.process.id' | cut -d'"' -f 2) \
		<(printf '%s' "$all_sink_inputs" | grep 'index: ' | rev | cut -d' ' -f 1 | rev))"

	stream_ids=""
	echo "$all_sink_inputs" | while read line ; do
		pid=$(echo "$line" | cut -f1)
		if [[ "$pid" == "$1" ]]; then
			echo "$line" | cut -f2
		fi
	done
}

get_binary_from_pid(){
	output="$(paste -d"\t" \
		<(printf '%s' "$output" | grep 'application.process.id' | cut -d'"' -f 2) \
		<(printf '%s' "$output" | grep 'application.process.binary' | cut -d'"' -f 2))"

	echo "$output" | while read line ; do
		pid=$(echo "$line" | cut -f1)
		if [[ "$pid" == "$1" ]]; then
			echo "$line" | cut -f2
		fi
	done
}

bind_application() {
	window_pid="$(xdotool getactivewindow getwindowpid)"
	window_name="$(xdotool getactivewindow getwindowname)"
	col_id=$1
	#echo "window_pid=$window_pid"
	#echo "window_name=$window_name"
	#echo "col_id=$col_id"

	case "$col_id" in
		"1" ) col_1_app_pid=$window_pid && notify-send "Set knob $col_id to $window_name" ;;
		"2" ) col_2_app_pid=$window_pid && notify-send "Set knob $col_id to $window_name" ;;
		"3" ) col_3_app_pid=$window_pid && notify-send "Set knob $col_id to $window_name" ;;
		"4" ) col_4_app_pid=$window_pid && notify-send "Set knob $col_id to $window_name" ;;
		"5" ) col_5_app_pid=$window_pid && notify-send "Set knob $col_id to $window_name" ;;
		"6" ) col_6_app_pid=$window_pid && notify-send "Set knob $col_id to $window_name" ;;
		"7" ) col_7_app_pid=$window_pid && notify-send "Set knob $col_id to $window_name" ;;
		"8" ) col_8_app_pid=$window_pid && notify-send "Set knob $col_id to $window_name" ;;
	esac

}

media_play_pause() {
	xdotool key XF86AudioPlay
}
media_prev() {
	xdotool key XF86AudioPrev
}
media_next() {
	xdotool key XF86AudioNext
}
media_stop() {
	xdotool key XF86AudioStop
}

main_mackie(){
	aseqdump -p "X-TOUCH MINI" | \
	while IFS=" ," read src ev1 ev2 ch label1 data1 label2 data2 rest; do
		#echo "$ev1 $ev2 $data1 $data2"
		case "$ev1 $ev2 $data1 $data2" in 
			# column 1
			"Note on 32"* ) bind_application 1 ;; # knob press
		    "Note on 89"* ) toggle_mute $col_1_app_pid ;; # top button
			"Note on 87"* ) print_col_app_ids ;; # bottom button
			"Control change 16"* ) change_volume $col_1_app_pid $data2 ;; # knob turn

			# column 2
			"Note on 33"* ) bind_application 2 ;; # knob press
		    "Note on 90"* ) toggle_mute $col_2_app_pid ;; # top button
			"Note on 88"* ) ;; # bottom button
			"Control change 17"* ) change_volume $col_2_app_pid $data2 ;; # knob turn

			# column 3
			"Note on 34"* ) bind_application 3 ;; # knob press
		    "Note on 40"* ) toggle_mute $col_3_app_pid ;; # top button
			"Note on 91"* ) media_prev ;;
			"Control change 18"* ) change_volume $col_3_app_pid $data2 ;; # knob turn

			# column 4
			"Note on 35"* ) bind_application 4 ;; # knob press
		    "Note on 41"* ) toggle_mute $col_4_app_pid ;; # top button
			"Note on 92"* ) media_next ;;
			"Control change 19"* ) change_volume $col_4_app_pid $data2 ;; # knob turn

			# column 5
			"Note on 36"* ) bind_application 5 ;; # knob press
		    "Note on 42"* ) toggle_mute $col_5_app_pid ;; # top button
			"Note on 86"* ) ;;
			"Control change 20"* ) change_volume $col_5_app_pid $data2 ;; # knob turn

			# column 6
			"Note on 37"* ) bind_application 6 ;; # knob press
		    "Note on 43"* ) toggle_mute $col_6_app_pid ;; # top button
			"Note on 93"* ) media_stop ;;
			"Control change 21"* ) change_volume $col_6_app_pid $data2 ;; # knob turn

			# column 7
			"Note on 38"* ) bind_application 7 ;; # knob press
		    "Note on 44"* ) toggle_mute $col_7_app_pid ;; # top button
			"Note on 94"* ) media_play_pause ;;
			"Control change 22"* ) change_volume $col_7_app_pid $data2 ;; # knob turn

			# column 8
			"Note on 39"* ) bind_application 8 ;; # knob press
		    "Note on 45"* ) toggle_mute $col_8_app_pid ;; # top button
			"Note on 95"* ) ;;
			"Control change 23"* ) change_volume $col_8_app_pid $data2 ;; # knob turn

			# layer a and b buttons
			"Note on 84"* ) assign_profile_1 ;;
			"Note on 85"* ) assign_profile_2 ;;
		esac
	done
}

main_standard(){
	aseqdump -p "X-TOUCH MINI" | \
	while IFS=" ," read src ev1 ev2 ch label1 data1 label2 data2 rest; do
		#echo "$ev1 $ev2 $data1 $data2"
		case "$ev1 $ev2 $data1 $data2" in 
			# column 1
			"Control change 9 127" ) bind_application 1 ;; # knob press
		    "Control change 17 127" ) mute_on $col_1_app_pid ;; # top button on
			"Control change 17 0" ) mute_off $col_1_app_pid ;; # top button off
			"Control change 25 127" ) print_col_app_ids ;; # bottom button
			"Control change 1 "* ) change_volume_standard $col_1_app_pid $data2 ;; # knob turn

			# column 2
			"Control change 10 127" ) bind_application 2 && echo "bind_application 2";; # knob press
		    "Control change 18 127" ) mute_on $col_2_app_pid;; # top button on
			"Control change 18 0" ) mute_off $col_2_app_pid ;; # top button off
			"Control change 26 127" ) ;; # bottom button
			"Control change 2 "* ) change_volume_standard $col_2_app_pid $data2 ;; # knob turn

			# column 3
			"Control change 11 127" ) bind_application 3 ;; # knob press
		    "Control change 19 127" ) mute_on $col_3_app_pid ;; # top button on
			"Control change 19 0" ) mute_off $col_3_app_pid ;; # top button off
			"Control change 27 127" ) media_prev ;;
			"Control change 3 "* ) change_volume_standard $col_3_app_pid $data2 ;; # knob turn

			# column 4
			"Control change 12 127" ) bind_application 4 ;; # knob press
		    "Control change 20 127" ) mute_on $col_4_app_pid ;; # top button on
			"Control change 20 0" ) mute_off $col_4_app_pid ;; # top button off
			"Control change 28 127" ) media_next ;;
			"Control change 4 "* ) change_volume_standard $col_4_app_pid $data2 ;; # knob turn

			# column 5
			"Control change 13 127" ) bind_application 5 ;; # knob press
		    "Control change 21 127" ) mute_on $col_5_app_pid ;; # top button on
			"Control change 21 0" ) mute_off $col_5_app_pid ;; # top button off
			"Control change 29 127" ) ;;
			"Control change 5 "* ) change_volume_standard $col_5_app_pid $data2 ;; # knob turn

			# column 6
			"Control change 14 127" ) bind_application 6 ;; # knob press
		    "Control change 22 127" ) mute_on $col_6_app_pid ;; # top button on
			"Control change 22 0" ) mute_off $col_6_app_pid ;; # top button off
			"Control change 30 127" ) media_stop ;;
			"Control change 6 "* ) change_volume_standard $col_6_app_pid $data2 ;; # knob turn

			# column 7
			"Control change 15 127" ) bind_application 7 ;; # knob press
		    "Control change 23 127" ) mute_on $col_7_app_pid ;; # top button on
			"Control change 23 0" ) mute_off $col_7_app_pid ;; # top button off
			"Control change 31 127" ) media_play_pause ;;
			"Control change 7 "* ) change_volume_standard $col_7_app_pid $data2 ;; # knob turn

			# column 8
			"Control change 16 127" ) bind_application 8 ;; # knob press
		    "Control change 24 127" ) mute_on $col_8_app_pid ;; # top button on
			"Control change 24 0" ) mute_off $col_8_app_pid ;; # top button off
			"Control change 32 127" ) ;;
			"Control change 8 "* ) change_volume_standard $col_8_app_pid $data2 ;; # knob turn
		esac
	done
}

initialize
main_standard
