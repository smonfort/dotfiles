#!/bin/bash

sketchybar --add event aerospace_workspace_change

add_space() {
    local sid=$1
    sketchybar --add item space.$sid left \
        --subscribe space.$sid aerospace_workspace_change front_app_switched \
        --set space.$sid \
        icon="$sid" \
        icon.font="Marker Felt:Wide:14.0" \
        icon.y_offset=-1 \
        label.font="sketchybar-app-font:Regular:14.0" \
        label.padding_left=6 \
        label.y_offset=-2 \
        update_freq=2 \
        click_script="aerospace workspace $sid" \
        script="$CONFIG_DIR/plugins/aerospace.sh $sid"
}

# Group spaces by monitor: big external monitor (1) on the left of the desk,
# then the built-in screen (2), each section led by a device icon.
sketchybar --add item monitor_icon left \
    --subscribe monitor_icon aerospace_workspace_change \
    --set monitor_icon icon="" \
                       label.drawing=off \
                       update_freq=2 \
                       script="$CONFIG_DIR/plugins/monitor_focus.sh 1"

for sid in $(aerospace list-workspaces --monitor 1); do
    add_space "$sid"
done

sketchybar --add item laptop_icon left \
    --subscribe laptop_icon aerospace_workspace_change \
    --set laptop_icon icon="" \
                      label.drawing=off \
                      update_freq=2 \
                      script="$CONFIG_DIR/plugins/monitor_focus.sh 2"

for sid in $(aerospace list-workspaces --monitor 2); do
    add_space "$sid"
done
