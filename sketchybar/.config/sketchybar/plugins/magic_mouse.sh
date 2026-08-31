#!/bin/sh

source "$CONFIG_DIR/variables.sh"

# ProductID 617 (0x0269) identifies the Magic Mouse over Apple's HID battery
# reporting service. This is more portable than matching on a BT MAC address.
MAGIC_MOUSE_PRODUCT_ID=617

PERCENTAGE="$(ioreg -c AppleDeviceManagementHIDEventService -r -l 2>/dev/null | awk -v pid="$MAGIC_MOUSE_PRODUCT_ID" '
  /\+-o AppleDeviceManagementHIDEventService/ { capture=1; buf=""; next }
  capture && /^[[:space:]]*\}[[:space:]]*$/ {
    capture=0
    if (buf ~ "\"ProductID\" = " pid "\n") {
      match(buf, /"BatteryPercent" = [0-9]+/)
      if (RSTART) {
        seg = substr(buf, RSTART, RLENGTH)
        sub(/.*= /, "", seg)
        print seg
      }
    }
    next
  }
  capture { buf = buf "\n" $0 }
')"

if [ -z "$PERCENTAGE" ]; then
  sketchybar --set "$NAME" drawing=off
  exit 0
fi

sketchybar --set "$NAME" drawing=on label="${PERCENTAGE}%"
