battery_info=$(pmset -g batt)

percent=$(echo "$battery_info" | egrep -Eo '\d+%' | head -1 | tr -d '%')
charging_indicator=$(echo "$battery_info" | grep -q discharging && echo "🔋" || echo "⚡")

if [ "$percent" -gt 75 ]; then
    color="green"
elif [ "$percent" -ge 50 ]; then
    color="yellow"
elif [ "$percent" -ge 25 ]; then
    color="colour208"
else
    color="red"
fi

echo "#[fg=${color}]${charging_indicator}${percent}%#[fg=default]"
