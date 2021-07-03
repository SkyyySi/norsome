#!/usr/bin/env bash
if command -v xdg-user-dir > /dev/null; then
	PICTURES_DIR="$(xdg-user-dir PICTURES)"
else
	PICTURES_DIR="${HOME}/Pictures"
fi

WALLPAPER_DIRS=(
	"${HOME}/backgrounds"
	"${HOME}/wallpapers"
	"${PICTURES_DIR}/backgrounds"
	"${PICTURES_DIR}/wallpapers"
	'/usr/share/backgrounds'
	'/usr/share/wallpaper'
)

list_images() {
	[[ -d "${1}" && -n $(command ls "${1}/") ]] || return 1

	local list
	list=( $(echo "${1}/"*.{png,bmp,jpg,jpeg,gif,tiff}) $(echo "${1}/"**/*.{png,bmp,jpg,jpeg,gif,tiff}) )

	printf '%s\n' "${list[@]}"
}

for i in "${!WALLPAPER_DIRS[@]}"; do
	list_images "${WALLPAPER_DIRS[i]}" | uniq -u | sort | sed '/*/d'
done
