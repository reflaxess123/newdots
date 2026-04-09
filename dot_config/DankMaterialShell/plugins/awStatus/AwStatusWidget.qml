import QtCore
import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    // Service-status state (from aw-status.py)
    property bool alive: false
    property var dead: []
    property string currentApp: ""
    property string currentTitle: ""

    // Daily-report state (from aw-today.json)
    property int activeSeconds: 0
    property int productiveSeconds: 0
    property int distractionSeconds: 0
    property var byProject: []
    property string reportDate: ""

    popoutWidth: 420
    popoutHeight: 480

    Component.onCompleted: {
        statusTimer.start()
        reportFile.reload()
    }

    // ---- Service status: poll every 10s via aw-status.py ----
    Timer {
        id: statusTimer
        interval: 10000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: statusProcess.running = true
    }

    Process {
        id: statusProcess
        command: ["/home/flyingkuskus/.config/DankMaterialShell/plugins/awStatus/aw-status.py"]
        running: false

        stdout: SplitParser {
            onRead: data => {
                try {
                    var parsed = JSON.parse(data)
                    root.alive = parsed.alive || false
                    root.dead = parsed.dead || []
                    root.currentApp = parsed.current ? (parsed.current.app || "") : ""
                    root.currentTitle = parsed.current ? (parsed.current.title || "") : ""
                } catch (e) {
                    root.alive = false
                }
            }
        }
    }

    // ---- Daily report: watch JSON cache file written by aw-today-cache.timer ----
    FileView {
        id: reportFile
        path: StandardPaths.writableLocation(StandardPaths.RuntimeLocation) + "/aw-today.json"
        blockLoading: false
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            try {
                var txt = reportFile.text()
                if (!txt || !txt.trim()) return
                var d = JSON.parse(txt)
                root.reportDate = d.date || ""
                root.activeSeconds = d.active_seconds || 0
                root.productiveSeconds = d.productive_seconds || 0
                root.distractionSeconds = d.distraction_seconds || 0
                root.byProject = d.by_project || []
            } catch (e) {
                // leave previous values in place on parse error
            }
        }
    }

    function fmtDuration(seconds) {
        if (seconds < 60) return seconds + "s"
        var m = Math.floor(seconds / 60)
        if (m < 60) return m + "m"
        var h = Math.floor(m / 60)
        var rem = m % 60
        return h + "h" + (rem < 10 ? "0" + rem : rem) + "m"
    }

    horizontalBarPill: Component {
        Row {
            spacing: Theme.spacingXS

            DankIcon {
                name: root.alive ? "schedule" : "error"
                size: Theme.iconSize - 6
                color: root.alive ? Theme.success : Theme.error
                anchors.verticalCenter: parent.verticalCenter
            }

            StyledText {
                text: root.fmtDuration(root.activeSeconds)
                font.pixelSize: Theme.fontSizeSmall
                font.weight: Font.Medium
                color: root.alive ? Theme.surfaceText : Theme.error
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    popoutContent: Component {
        PopoutComponent {
            headerText: "ActivityWatch — " + (root.reportDate || "today")
            detailsText: root.alive
                ? ("active " + root.fmtDuration(root.activeSeconds))
                : ("services down: " + root.dead.join(", "))
            showCloseButton: true

            Column {
                width: parent.width
                spacing: Theme.spacingS

                // Big active-time header
                Row {
                    width: parent.width
                    spacing: Theme.spacingM

                    Column {
                        spacing: 2
                        StyledText {
                            text: "active"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceVariantText
                        }
                        StyledText {
                            text: root.fmtDuration(root.activeSeconds)
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Bold
                            color: Theme.surfaceText
                        }
                    }

                    Column {
                        spacing: 2
                        StyledText {
                            text: "productive"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceVariantText
                        }
                        StyledText {
                            text: root.fmtDuration(root.productiveSeconds)
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Bold
                            color: Theme.success
                        }
                    }

                    Column {
                        spacing: 2
                        StyledText {
                            text: "distraction"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceVariantText
                        }
                        StyledText {
                            text: root.fmtDuration(root.distractionSeconds)
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Bold
                            color: root.distractionSeconds > 0 ? Theme.error : Theme.surfaceVariantText
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: Theme.surfaceVariant
                }

                // Projects
                StyledText {
                    text: "projects"
                    font.pixelSize: Theme.fontSizeSmall
                    font.weight: Font.Bold
                    color: Theme.primary
                }

                Repeater {
                    model: root.byProject
                    Row {
                        width: parent.width
                        spacing: Theme.spacingS
                        StyledText {
                            text: modelData.name
                            font.pixelSize: Theme.fontSizeSmall
                            color: modelData.name === "Other" ? Theme.surfaceVariantText : Theme.surfaceText
                            width: parent.width - 70
                            elide: Text.ElideRight
                        }
                        StyledText {
                            text: root.fmtDuration(modelData.seconds)
                            font.pixelSize: Theme.fontSizeSmall
                            font.weight: Font.Medium
                            color: Theme.surfaceVariantText
                        }
                    }
                }

                StyledText {
                    visible: root.byProject.length === 0
                    text: "no data yet"
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceVariantText
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: Theme.surfaceVariant
                }

                StyledText {
                    text: root.currentApp
                        ? ("now: " + root.currentApp + " — " + root.currentTitle)
                        : "no active window"
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceVariantText
                    width: parent.width
                    elide: Text.ElideRight
                }
            }
        }
    }
}
