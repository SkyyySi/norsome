#!/usr/bin/env bash
run_on_start_up=(
	'timidity -iA'
	'picom'
	'pasystray'
	'xscreensaver -no-splash'
	'unclutter -b'
	'blueman-applet 2>/dev/null'
	'lxsession --session=awesome --de=awesome'
	'ulauncher'
#	'bash /home/simon/.screenlayout/90_tripplescreen.sh'
#	'bash /home/simon/.config/start_jack.sh'
#	'gnome-flashback 2>/dev/null'
#	'glava -d >/dev/null'
)

run() {
	if ! pgrep -f "${1}"; then
		while true; do
			bash -c "${@}"
		done
	fi
}

for i in "${run_on_start_up[@]}"; do
	run "${i}"&
done