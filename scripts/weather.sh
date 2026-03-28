#!/usr/bin/env bash
# Weather for Lyon via wttr.in — outputs Waybar JSON

LOCATION="Lyon"
CACHE="/tmp/waybar-weather.json"
CACHE_TTL=1800  # seconds (30 min)

# Use cache if fresh enough
if [ -f "$CACHE" ] && [ $(( $(date +%s) - $(stat -c %Y "$CACHE") )) -lt $CACHE_TTL ]; then
    cat "$CACHE"
    exit 0
fi

DATA=$(curl -sf --max-time 5 "https://wttr.in/${LOCATION}?format=j1" 2>/dev/null)

if [ -z "$DATA" ]; then
    echo '{"text": "󰖙 --°C", "tooltip": "Weather unavailable", "class": "unavailable"}'
    exit 0
fi

TEMP=$(echo "$DATA"    | jq -r '.current_condition[0].temp_C')
FEELS=$(echo "$DATA"   | jq -r '.current_condition[0].FeelsLikeC')
DESC=$(echo "$DATA"    | jq -r '.current_condition[0].weatherDesc[0].value')
HUMID=$(echo "$DATA"   | jq -r '.current_condition[0].humidity')
WIND=$(echo "$DATA"    | jq -r '.current_condition[0].windspeedKmph')
CODE=$(echo "$DATA"    | jq -r '.current_condition[0].weatherCode')

# Tomorrow forecast
TMRW_MAX=$(echo "$DATA" | jq -r '.weather[1].maxtempC')
TMRW_MIN=$(echo "$DATA" | jq -r '.weather[1].mintempC')
TMRW_DESC=$(echo "$DATA" | jq -r '.weather[1].hourly[4].weatherDesc[0].value')

case $CODE in
    113)                         ICON="󰖙" ;;  # Clear/Sunny
    116)                         ICON="󰖕" ;;  # Partly cloudy
    119|122)                     ICON="󰖔" ;;  # Cloudy/Overcast
    143|248|260)                 ICON="󰖑" ;;  # Fog/Mist
    176|293|296|299|302|305|308) ICON="󰖗" ;;  # Rain
    179|182|185|281|284|311|314|317|320|323|326) ICON="󰖘" ;;  # Sleet/Snow
    200|386|389|392|395)         ICON="󰖓" ;;  # Thunder
    329|332|335|338)             ICON="󰼶" ;;  # Heavy snow
    *)                           ICON="󰖙" ;;
esac

TEXT="${ICON} ${TEMP}°C"
TOOLTIP="Lyon — ${DESC}\nFeels like: ${FEELS}°C  |  Humidity: ${HUMID}%  |  Wind: ${WIND} km/h\nTomorrow: ${TMRW_DESC}, ${TMRW_MIN}–${TMRW_MAX}°C"

OUT="{\"text\": \"${TEXT}\", \"tooltip\": \"${TOOLTIP}\"}"
echo "$OUT" | tee "$CACHE"
