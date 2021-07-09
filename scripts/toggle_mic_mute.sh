#!/bin/sh
for i in $(pactl list sources short | awk '{print $2}'); do
	pactl set-source-mute "${i}" toggle
done