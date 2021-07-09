#!/usr/bin/env bash
# Reset the screenlayout
[[ -f "${HOME}/.screenlayout/layout.sh" ]] && "${HOME}/.screenlayout/layout.sh"

CONFIG_DIR="${XDG_CONFIG_DIR:-${HOME}/.config}"
CONFIG_PREFIX="${CONFIG_DIR}/awesome/other"

# This script must not be run in a loop
#"${CONFIG_DIR}/awesome/scripts/start_jack.sh"

# These cannot be checked with pgrep for some reason
pkill -fU "${USER}" '^lxqt-policykit-agent'
lxqt-policykit-agent&
lxqt-powermanagement&
playerctld daemon&

run=(
	'nm-applet'
	'blueman-applet'
	'lxqt-session -w awesome'
	'pasystray'
	"picom --config ${CONFIG_PREFIX}/picom/picom.conf"
#	'playerctld daemon'
	'timidity -iA'
	'ulauncher'
	'unclutter -b'
#	'xscreensaver -no-splash'
)

check_running() {
	pgrep -U "${USER}" "^${1}" > /dev/null
}

run() {
	#local cmd_split
	#local cmd=( ${*} )
	local cmd
	read -a cmd <<<"${*}"
	
	if ! check_running "${cmd[0]}"; then
		#awesome-client "naughty.notify({text = 'Spawning ${*}'})"
		bash -c "${*}"
	#else
		#awesome-client "naughty.notify({text = 'NOT spawning ${*}'})"
	fi
}

re_run() {
	while true; do
		run "${*}"
		sleep 10
	done
}

for i in "${run[@]}"; do
	re_run "${i}"&
done

if ! pgrep 'plasma-browser.*' > /dev/null; then
	plasma-browser-integration-host
fi