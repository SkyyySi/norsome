#!/usr/bin/env bash
# License: Unlicense <https://unlicense.org>
# Exit if playerctl is not installed
if ! command -v 'playerctl' > /dev/null; then
	echo 'It looks like playerctl is not installed on your system.'
	exit 1
fi

# Shows usage help when called
usage() {
	echo "${0##*/}: Prints the currently playing song using playerctl"
}

# Read options
while getopts ':hasntcf' ARG; do
	case "${ARG}" in
		'h') usage; exit      ;;
		'a') ARTIST_ONLY=true ;;
		's') STUPID_MODE=true ;;
		'n') NO_STRIP=true    ;;
		't') TITLE_ONLY=true  ;;
		'c') COVER_ONLY=true  ;;
		'f') FOLLOW=true      ;;
		*)   usage; exit 1    ;;
	esac
done

# Print the song title and exit if stupid mode is on
#if ! playerctl metadata artist &> /dev/null; then
#	exit 1
#fi

main() {
	# Print the song cover art and exit if cover mode is on
	if [[ -n "${COVER_ONLY}" ]]; then
		unset COVER
		while ! grep -q '\/' <<<"${COVER}"; do
			unset COVER
			COVER="$(playerctl metadata mpris:artUrl 2> /dev/null)"
			COVER="$(sed 's|^file:\/\/||' <<<"${COVER}")"
		done
		echo "${COVER}"
		return
	fi

	# Get the current song title using playerctl
	SONG_TITLE="$(playerctl metadata title 2> /dev/null)"

	# Exit if no player is found
	if [[ "${SONG_TITLE}" = 'No players found' ]]; then
		return 1
	fi

	# Stupid mode
	if [[ -n "${STUPID_MODE}" ]]; then
		SONG_TITLE="$(playerctl metadata title 2> /dev/null)"
	fi

	# Also grab the artist name if it's not in the title itself
	if ! grep -q ' - ' <<<"${SONG_TITLE}"; then
		SONG_ARTIST="$(playerctl metadata artist 2> /dev/null)"
		FULL_TITLE="${SONG_ARTIST} - ${SONG_TITLE}"
	else
		FULL_TITLE="${SONG_TITLE}"
	fi

	# Strip prefixes like a genre and suffixes in angle brackets, like '[Monstercat Release]'
	# if they are enclosed with angle brackets
	if [[ -z "${NO_STRIP}" ]]; then
		TITLE_tmp="$(sed 's|^\[.*\] ||' <<<"${FULL_TITLE}" | sed 's|^ ||' | sed 's|^- ||')"
		TITLE_tmp="$(rev <<<"${TITLE_tmp}")"
		TITLE_tmp="$(sed 's|^\].*\[ ||' <<<"${TITLE_tmp}")"
		TITLE_tmp="$(rev <<<"${TITLE_tmp}")"
		TITLE_tmp="$(sed 's|free download||gI' <<<"${TITLE_tmp}")"
		TITLE_tmp="$(sed 's|()||g' <<<"${TITLE_tmp}")"
		TITLE_tmp="$(sed 's|\[\]||g' <<<"${TITLE_tmp}")"
		TITLE="${TITLE_tmp}"
	fi

	TITLE="${TITLE:-FULL_TITLE}"

	if [[ -n "${TITLE_ONLY}" ]]; then
		TITLE_NO_ARTIST="$(sed "s|$(grep -o '^.* - ' <<<"${TITLE}")||" <<<"${TITLE}")"
		echo -e "${TITLE_NO_ARTIST}"
	elif [[ -n "${ARTIST_ONLY}" ]]; then
		ARTIST="$(echo "${TITLE}" | grep --color -oP '.* - ' | rev | sed 's| - ||' | rev)"
		echo -e "${ARTIST}"
	else
		echo -e "${TITLE}"
fi
}

if [[ -n "${FOLLOW}" ]]; then
	while true; do
		SONG_TITLE="$(playerctl metadata title 2> /dev/null)"
		if [[ "${SONG_TITLE}" != "${NEW_SONG_TITLE}" ]]; then
			main
		fi
		NEW_SONG_TITLE="${SONG_TITLE}"
	done
else
	main
fi