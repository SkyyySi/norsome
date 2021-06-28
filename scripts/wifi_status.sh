#!/bin/sh
while true; do
	WIFI_STATUS="$(nmcli -c no r wifi)" > /dev/null

	if [ "${WIFI_STATUS}" != "${OLD_WIFI_STATUS}" ]; then
		echo "${WIFI_STATUS}"
	fi

	OLD_WIFI_STATUS="${WIFI_STATUS}"

	sleep 1
done