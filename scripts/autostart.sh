#!/usr/bin/env bash
# Reset the screenlayout
[[ -f "${HOME}/.screenlayout/layout.sh" ]] && "${HOME}/.screenlayout/layout.sh"

CONFIG_PREFIX="${XDG_CONFIG_DIR:-${HOME}/.config}/awesome/other"

run_once=(
#	"bash ${HOME}/.screenlayout/90_tripplescreen.sh"
#	"bash ${HOME}/.config/start_jack.sh"
#	'glava -d'
#	'gnome-flashback'
	'true'
)

# These processes get re-executed if they halt
run=(
	'blueman-applet'
	'lxqt-policykit-agent'
	'lxqt-powermanagement'
	'lxqt-session -w awesome'
#	'pasystray'
	"picom --config ${CONFIG_PREFIX}/picom/picom.conf"
#	'timidity -iA'
#	'ulauncher'
	'unclutter -b'
	'xscreensaver -no-splash'
)

run() {
	local cmd_split
	      cmd_split=$(printf '%s' "${*}")
	
	if ! pgrep -f "${cmd_split[1]}"; then
		#bash -c "nohup ${*} &> /dev/null"
		bash -c "${*}"
	fi
}

re_run() {
	while true; do
		run "${@}"
		sleep 1
	done
}

for i in "${run_once[@]}"; do
	run "${i}"&
done

for i in "${run[@]}"; do
	re_run "${i}"&
done