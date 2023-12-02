#!/usr/bin/env bash

# path to log file - global variable
FILE="$1"

ansifilter_installed() {
	type ansifilter >/dev/null 2>&1 || return 1
}

system_osx() {
	[ $(uname) == "Darwin" ]
}

pipe_pane_ansifilter() {
	tmux pipe-pane "exec cat - | ansifilter >> $FILE"
}

pipe_pane_sed_osx() {
	# Warning, very complex regex ahead.
	# Some characters below might not be visible from github web view.
	local ansi_codes_osx="(\[([0-9]{1,3}((;[0-9]{1,3})*)?)?[m|K]||]0;[^]+|[[:space:]]+$)"
	tmux pipe-pane "exec cat - | sed -E \"s/$ansi_codes_osx//g\" >> $FILE"
}

pipe_pane_sed() {
    # Original replacement 
	# local ansi_codes="(\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]|)"

    # My new one leaves color codes in, which makes the display appear better                                                                                                  
    # In tests, logs are still easily greppable                                                                                                                                
    local ansi_codes="(\x1b\[[0-9?]\+[^m0-9?])"                                                                                                                                

	tmux pipe-pane "exec cat - | sed -r 's/$ansi_codes//g' >> $FILE"
}

start_pipe_pane() {
	if ansifilter_installed; then
		pipe_pane_ansifilter
	elif system_osx; then
		# OSX uses sed '-E' flag and a slightly different regex
		pipe_pane_sed_osx
	else
		pipe_pane_sed
	fi
}

main() {
	start_pipe_pane
}
main
