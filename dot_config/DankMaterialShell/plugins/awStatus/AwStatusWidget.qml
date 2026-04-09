import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    property bool alive: false
    property var dead: []
    property int eventsToday: 0
    property string currentApp: ""
    property string currentTitle: ""
    property var topApps: []

    popoutWidth: 360
    popoutHeight: 300

    Component.onCompleted: refreshTimer.start()

    Timer {
        id: refreshTimer
        interval: 10000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: statusProcess.running = true
    }

    function fmtDuration(seconds) {
        if (seconds < 60) return seconds + "s"
        var m = Math.floor(seconds / 60)
        if (m < 60) return m + "m"
        var h = Math.floor(m / 60)
        var rem = m % 60
        return h + "h" + (rem < 10 ? "0" + rem : rem) + "m"
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
                    root.eventsToday = parsed.events_today || 0
                    root.currentApp = parsed.current ? (parsed.current.app || "") : ""
                    root.currentTitle = parsed.current ? (parsed.current.title || "") : ""
                    root.topApps = parsed.top || []
                } catch (e) {
                    root.alive = false
                }
            }
        }
    }

    horizontalBarPill: Component {
        Row {
            spacing: Theme.spacingXS

            DankIcon {
                name: root.alive ? "monitoring" : "error"
                size: Theme.iconSize - 6
                color: root.alive ? Theme.success : Theme.error
                anchors.verticalCenter: parent.verticalCenter
            }

            StyledText {
                text: root.eventsToday + "ev"
                font.pixelSize: Theme.fontSizeSmall
                font.weight: Font.Medium
                color: root.alive ? Theme.surfaceText : Theme.error
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    popoutContent: Component {
        PopoutComponent {
            headerText: "ActivityWatch"
            detailsText: root.alive ? "all services alive" : ("dead: " + root.dead.join(", "))
            showCloseButton: true

            Column {
                width: parent.width
                spacing: Theme.spacingS

                StyledText {
                    text: root.eventsToday + " events today"
                    font.pixelSize: Theme.fontSizeLarge
                    font.weight: Font.Bold
                    color: Theme.surfaceText
                }

                StyledText {
                    text: root.currentApp ? (root.currentApp + " — " + root.currentTitle) : "no active window"
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceVariantText
                    width: parent.width
                    elide: Text.ElideRight
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: Theme.surfaceVariant
                }

                StyledText {
                    text: "Top apps (last 30 min)"
                    font.pixelSize: Theme.fontSizeSmall
                    font.weight: Font.Bold
                    color: Theme.primary
                }

                Repeater {
                    model: root.topApps
                    Row {
                        width: parent.width
                        spacing: Theme.spacingS

                        StyledText {
                            text: modelData.app
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceText
                            width: parent.width - 60
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
                    visible: root.topApps.length === 0
                    text: "no activity"
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceVariantText
                }
            }
        }
    }
}
