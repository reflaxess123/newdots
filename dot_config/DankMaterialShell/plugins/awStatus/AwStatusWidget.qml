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
    property string errorMsg: ""

    popoutWidth: 380
    popoutHeight: 340

    Component.onCompleted: {
        refresh()
        refreshTimer.start()
    }

    Timer {
        id: refreshTimer
        interval: 10000
        repeat: true
        running: true
        onTriggered: refresh()
    }

    function refresh() {
        statusProcess.running = true
    }

    function fmtDuration(seconds) {
        if (seconds < 60) return seconds + "s"
        var m = Math.floor(seconds / 60)
        if (m < 60) return m + "m"
        var h = Math.floor(m / 60)
        var rem = m % 60
        return h + "h" + (rem < 10 ? "0" + rem : rem) + "m"
    }

    function truncate(s, n) {
        if (!s || s.length <= n) return s || ""
        return s.substring(0, n - 1) + "…"
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
                    if (parsed.current) {
                        root.currentApp = parsed.current.app || ""
                        root.currentTitle = parsed.current.title || ""
                    } else {
                        root.currentApp = ""
                        root.currentTitle = ""
                    }
                    root.topApps = parsed.top || []
                    root.errorMsg = parsed.error || ""
                } catch (e) {
                    root.errorMsg = "parse error: " + e
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

    verticalBarPill: Component {
        Column {
            spacing: Theme.spacingXS

            DankIcon {
                name: root.alive ? "monitoring" : "error"
                size: Theme.iconSize - 6
                color: root.alive ? Theme.success : Theme.error
                anchors.horizontalCenter: parent.horizontalCenter
            }

            StyledText {
                text: root.eventsToday
                font.pixelSize: Theme.fontSizeSmall
                font.weight: Font.Medium
                color: root.alive ? Theme.surfaceText : Theme.error
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    popoutContent: Component {
        PopoutComponent {
            id: popout
            headerText: "ActivityWatch"
            detailsText: root.alive ? "all services alive" : ("DEAD: " + root.dead.join(", "))
            showCloseButton: true

            Column {
                width: parent.width
                spacing: Theme.spacingM

                Rectangle {
                    width: parent.width
                    height: 60
                    radius: Theme.cornerRadius
                    color: root.alive ? Qt.rgba(Theme.success.r, Theme.success.g, Theme.success.b, 0.15) : Qt.rgba(Theme.error.r, Theme.error.g, Theme.error.b, 0.2)

                    Row {
                        anchors.centerIn: parent
                        spacing: Theme.spacingM

                        DankIcon {
                            name: root.alive ? "check_circle" : "error"
                            size: 28
                            color: root.alive ? Theme.success : Theme.error
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            StyledText {
                                text: root.eventsToday + " events today"
                                font.pixelSize: Theme.fontSizeLarge
                                font.weight: Font.Bold
                                color: Theme.surfaceText
                            }

                            StyledText {
                                text: root.alive ? "aw-server, awatcher, watcher-git" : ("failed: " + root.dead.join(", "))
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                            }
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    height: currentCol.implicitHeight + Theme.spacingM * 2
                    radius: Theme.cornerRadius
                    color: Theme.surfaceVariant
                    visible: root.currentApp !== ""

                    Column {
                        id: currentCol
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: Theme.spacingM
                        anchors.rightMargin: Theme.spacingM
                        spacing: 2

                        StyledText {
                            text: "CURRENT WINDOW"
                            font.pixelSize: Theme.fontSizeSmall - 1
                            font.weight: Font.Bold
                            color: Theme.primary
                        }

                        StyledText {
                            text: root.currentApp
                            font.pixelSize: Theme.fontSizeMedium
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            width: parent.width
                            elide: Text.ElideRight
                        }

                        StyledText {
                            text: root.truncate(root.currentTitle, 60)
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceVariantText
                            width: parent.width
                            elide: Text.ElideRight
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 36
                    radius: Theme.cornerRadius
                    color: Theme.surfaceContainerHigh

                    StyledText {
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.spacingM
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Top apps — last 30 min"
                        font.pixelSize: Theme.fontSizeSmall
                        font.weight: Font.Bold
                        color: Theme.primary
                    }

                    Rectangle {
                        width: 60
                        height: 22
                        radius: 11
                        color: Theme.surfaceVariant
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.spacingS
                        anchors.verticalCenter: parent.verticalCenter

                        Row {
                            anchors.centerIn: parent
                            spacing: 4

                            DankIcon {
                                name: "refresh"
                                size: 12
                                color: Theme.surfaceText
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            StyledText {
                                text: "Now"
                                font.pixelSize: 10
                                color: Theme.surfaceText
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.refresh()
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 160
                    radius: Theme.cornerRadius
                    color: Theme.surfaceVariant

                    ListView {
                        id: topList
                        anchors.fill: parent
                        anchors.margins: Theme.spacingXS
                        model: root.topApps
                        clip: true
                        spacing: 2

                        delegate: Rectangle {
                            width: topList.width
                            height: 26
                            radius: 4
                            color: index % 2 === 0 ? "transparent" : Qt.rgba(255, 255, 255, 0.03)

                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: Theme.spacingS
                                anchors.rightMargin: Theme.spacingS
                                spacing: Theme.spacingS

                                StyledText {
                                    text: modelData.app
                                    font.pixelSize: 12
                                    color: Theme.surfaceText
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: topList.width - 80
                                    elide: Text.ElideRight
                                }

                                Rectangle {
                                    width: 50
                                    height: 18
                                    radius: 9
                                    color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.2)
                                    anchors.verticalCenter: parent.verticalCenter

                                    StyledText {
                                        anchors.centerIn: parent
                                        text: root.fmtDuration(modelData.seconds)
                                        font.pixelSize: 10
                                        font.weight: Font.Medium
                                        color: Theme.surfaceText
                                    }
                                }
                            }
                        }

                        ScrollBar.vertical: ScrollBar {
                            active: true
                        }
                    }

                    StyledText {
                        anchors.centerIn: parent
                        text: "no activity in last 30 min"
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceVariantText
                        visible: root.topApps.length === 0
                    }
                }
            }
        }
    }
}
