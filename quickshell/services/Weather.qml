pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property string tempC:       ""
    property string icon:        ""
    property string description: ""
    property string feelsLike:   ""
    property string humidity:    ""
    property string windKmph:    ""
    property string tomorrowMin: ""
    property string tomorrowMax: ""

    readonly property string displayText: icon ? `${icon} ${tempC}°C` : "…"
    readonly property string tooltipText:
        description ? `${description}\nFeels like: ${feelsLike}°C\nHumidity: ${humidity}%\nWind: ${windKmph} km/h\nTomorrow: ${tomorrowMin}–${tomorrowMax}°C` : ""

    readonly property var iconMap: ({
        113: "󰖙", 116: "󰖕", 119: "󰖔", 122: "󰖑",
        143: "",  176: "",  179: "󰖘", 182: "",  185: "",
        200: "",  227: "󰖘", 230: "󰖘", 248: "",  260: "",
        263: "",  266: "",  281: "",  284: "",  293: "",
        296: "",  299: "",  302: "",  305: "",  308: "",
        311: "",  314: "",  317: "",  320: "󰖘", 323: "󰖘",
        326: "󰖘", 329: "󰖘", 332: "󰖘", 335: "󰖘", 338: "󰖘",
        350: "",  353: "",  356: "",  359: "",  362: "",
        365: "",  368: "󰖘", 371: "󰖘", 374: "",  377: "",
        386: "",  389: "",  392: "󰖘", 395: "󰖘"
    })

    Process {
        id: fetchProc
        command: ["curl", "-sf", "--max-time", "5", "https://wttr.in/Lyon?format=j1"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const data = JSON.parse(text.trim())
                    const cur  = data.current_condition[0]
                    const code = parseInt(cur.weatherCode)
                    const tmr  = data.weather[1]
                    root.tempC       = cur.temp_C
                    root.icon        = root.iconMap[code] ?? ""
                    root.description = cur.weatherDesc[0].value
                    root.feelsLike   = cur.FeelsLikeC
                    root.humidity    = cur.humidity
                    root.windKmph    = cur.windspeedKmph
                    root.tomorrowMin = tmr.mintempC
                    root.tomorrowMax = tmr.maxtempC
                } catch(e) {
                    console.warn("Weather parse error:", e)
                }
            }
        }
    }

    Timer { interval: 1800000; repeat: true; running: true; onTriggered: fetchProc.running = true }
    Component.onCompleted: fetchProc.running = true
}
