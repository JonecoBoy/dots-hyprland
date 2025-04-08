#!/bin/sh

while true; do
    waypaper --random --monitor eDP-1 --folder ~/Pictures/wallpapers
    waypaper --random --monitor HDMI-A-1 --folder ~/Pictures/wallpapers
    sleep 600  # Change wallpapers every 10 minutes
done

