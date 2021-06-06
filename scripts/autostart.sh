#!/usr/bin/env bash
# Reset the screenlayout
[[ -f "${HOME}/.screenlayout/layout.sh" ]] && "${HOME}/.screenlayout/layout.sh"

CONFIG_PREFIX="${XDG_CONFIG_DIR:-${HOME}/.config}/awesome/other"

# These cannot be checked with pgrep for some reason
lxqt-policykit-agent&
lxqt-powermanagement&

run=(
	'blueman-applet'
	'lxqt-session -w awesome'
#	'pasystray'
	"picom --config ${CONFIG_PREFIX}/picom/picom.conf"
#	'timidity -iA'
#	'ulauncher'
	'unclutter -b'
	'xscreensaver -no-splash'
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
		sleep 1
	done
}

for i in "${run[@]}"; do
	re_run "${i}"&
done