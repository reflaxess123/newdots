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
    property bool isAfk: false
    property string gitRepo: ""
    property string gitBranch: ""

    // Timeline per hour from daily report
    property var timeline: []

    // Daily-report state (from aw-today.json)
    property int activeSeconds: 0
    property int productiveSeconds: 0
    property int distractionSeconds: 0
    property var byProject: []
    property var intentByProject: ({})
    property string reportDate: ""

    popoutWidth: 480
    popoutHeight: 640

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
                    root.isAfk = parsed.afk || false
                    root.gitRepo = parsed.git ? (parsed.git.repo || "") : ""
                    root.gitBranch = parsed.git ? (parsed.git.branch || "") : ""
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
                root.intentByProject = d.intent_by_project || ({})
                root.timeline = d.timeline || []
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

    // Extract up to N most recent intent events for a project.
    // intent_by_project is already sorted newest-first by daily.py.
    function intentFor(projectName, limit) {
        if (!root.intentByProject) return []
        var evs = root.intentByProject[projectName]
        if (!evs || evs.length === 0) return []
        return evs.slice(0, limit)
    }

    // Convert an ISO-UTC timestamp ("2026-04-09T20:45:00Z") into "HH:MM" in
    // local time. Pure JS so it works in the QML JS engine.
    function fmtHourMin(isoUtc) {
        if (!isoUtc) return ""
        var d = new Date(isoUtc)
        if (isNaN(d.getTime())) return ""
        var h = d.getHours()
        var m = d.getMinutes()
        return (h < 10 ? "0" + h : h) + ":" + (m < 10 ? "0" + m : m)
    }

    horizontalBarPill: Component {
        Row {
            spacing: Theme.spacingXS

            DankIcon {
                name: root.alive ? (root.isAfk ? "pause_circle" : "schedule") : "error"
                size: Theme.iconSize - 6
                color: root.alive ? (root.isAfk ? Theme.surfaceVariantText : Theme.success) : Theme.error
                anchors.verticalCenter: parent.verticalCenter
            }

            StyledText {
                text: root.fmtDuration(root.activeSeconds)
                font.pixelSize: Theme.fontSizeSmall
                font.weight: Font.Medium
                color: root.alive ? (root.isAfk ? Theme.surfaceVariantText : Theme.surfaceText) : Theme.error
                anchors.verticalCenter: parent.verticalCenter
            }

            StyledText {
                visible: root.gitRepo !== "" && !root.isAfk
                text: root.gitRepo
                font.pixelSize: Theme.fontSizeSmall - 2
                font.weight: Font.Normal
                color: Theme.surfaceVariantText
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
                    Column {
                        width: parent.width
                        spacing: 2

                        Row {
                            width: parent.width
                            spacing: Theme.spacingS
                            StyledText {
                                text: modelData.name
                                font.pixelSize: Theme.fontSizeSmall
                                font.weight: Font.Medium
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

                        // Intent events for this project (newest first, up to 2)
                        Repeater {
                            model: root.intentFor(modelData.name, 2)
                            Row {
                                width: parent.width
                                spacing: Theme.spacingXS
                                leftPadding: Theme.spacingM

                                StyledText {
                                    text: root.fmtHourMin(modelData.ts)
                                    font.pixelSize: Theme.fontSizeSmall - 2
                                    color: Theme.surfaceVariantText
                                    width: 36
                                }
                                StyledText {
                                    text: modelData.kind === "git" ? "git" : "cc"
                                    font.pixelSize: Theme.fontSizeSmall - 2
                                    font.weight: Font.Bold
                                    color: modelData.kind === "git" ? Theme.warning : Theme.primary
                                    width: 22
                                }
                                StyledText {
                                    text: modelData.text
                                    font.pixelSize: Theme.fontSizeSmall - 2
                                    color: Theme.surfaceVariantText
                                    width: parent.width - 70
                                    elide: Text.ElideRight
                                }
                            }
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

                // Timeline
                StyledText {
                    visible: root.timeline.length > 0
                    text: "timeline"
                    font.pixelSize: Theme.fontSizeSmall
                    font.weight: Font.Bold
                    color: Theme.primary
                }

                Repeater {
                    model: root.timeline
                    Row {
                        width: parent.width
                        spacing: Theme.spacingXS

                        StyledText {
                            text: (modelData.hour < 10 ? "0" : "") + modelData.hour + ":00"
                            font.pixelSize: Theme.fontSizeSmall - 2
                            font.family: "monospace"
                            color: Theme.surfaceVariantText
                            width: 38
                        }

                        StyledText {
                            text: {
                                var parts = []
                                var projs = modelData.projects || []
                                for (var i = 0; i < projs.length; i++) {
                                    parts.push(projs[i].name + " " + root.fmtDuration(projs[i].seconds))
                                }
                                return parts.join(", ")
                            }
                            font.pixelSize: Theme.fontSizeSmall - 2
                            color: Theme.surfaceText
                            width: parent.width - 46
                            elide: Text.ElideRight
                        }
                    }
                }

                Rectangle {
                    visible: root.timeline.length > 0
                    width: parent.width
                    height: 1
                    color: Theme.surfaceVariant
                }

                // Current state footer
                Column {
                    width: parent.width
                    spacing: 2

                    StyledText {
                        text: root.isAfk ? "status: AFK" : (root.currentApp
                            ? ("now: " + root.currentApp + " — " + root.currentTitle)
                            : "no active window")
                        font.pixelSize: Theme.fontSizeSmall
                        color: root.isAfk ? Theme.warning : Theme.surfaceVariantText
                        width: parent.width
                        elide: Text.ElideRight
                    }

                    StyledText {
                        visible: root.gitRepo !== ""
                        text: "git: " + root.gitRepo + "@" + root.gitBranch
                        font.pixelSize: Theme.fontSizeSmall - 2
                        color: Theme.surfaceVariantText
                        width: parent.width
                        elide: Text.ElideRight
                    }
                }
            }
        }
    }
}
