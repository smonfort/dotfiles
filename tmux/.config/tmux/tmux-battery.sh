battery_info=$(pmset -g batt)

percent=$(echo $battery_info | egrep -Eo '\d+%')
charging_indicator=$(echo $battery_info | grep -q discharging && echo "🔋" || echo "⚡")

echo $charging_indicator$percent
