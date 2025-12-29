import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    property bool vpnActive: false
    property var proxyDomains: []
    property var directDomains: []
    property bool isLoading: false

    // Catppuccin Mocha colors
    readonly property color catGreen: "#a6e3a1"
    readonly property color catRed: "#f38ba8"
    readonly property color catSubtext: "#a6adc8"

    popoutWidth: 500
    popoutHeight: 450

    Component.onCompleted: {
        checkVpnStatus()
        statusTimer.start()
    }

    Timer {
        id: statusTimer
        interval: 3000
        repeat: true
        running: true
        onTriggered: checkVpnStatus()
    }

    function checkVpnStatus() {
        statusProcess.running = true
    }

    function toggleVpn() {
        isLoading = true
        toggleProcess.running = true
    }

    function loadDomains() {
        domainsProcess.running = true
    }

    Process {
        id: statusProcess
        command: ["sh", "-c", "pgrep -x sing-box > /dev/null && echo 'on' || echo 'off'"]
        running: false

        stdout: SplitParser {
            onRead: data => {
                root.vpnActive = data.trim() === "on"
            }
        }
    }

    Process {
        id: toggleProcess
        command: ["sh", "-c", "~/.config/hypr/scripts/singbox-toggle.sh"]
        running: false

        onExited: (exitCode, exitStatus) => {
            root.isLoading = false
            Qt.callLater(checkVpnStatus)
        }
    }

    Process {
        id: domainsProcess
        command: ["python3", "/home/vasya/.config/hypr/scripts/vpn-domains.py", "20"]
        running: false

        stdout: SplitParser {
            onRead: data => {
                try {
                    const parsed = JSON.parse(data)
                    root.proxyDomains = parsed.proxy || []
                    root.directDomains = parsed.direct || []
                } catch (e) {
                    console.warn("VPN Status: Failed to parse domains:", e)
                }
            }
        }
    }

    horizontalBarPill: Component {
        Row {
            spacing: Theme.spacingXS

            DankIcon {
                name: root.vpnActive ? "vpn_lock" : "vpn_lock_off"
                size: Math.round(root.iconSize * (root.barConfig?.fontScale ?? 1.0))
                color: root.vpnActive ? root.catGreen : root.catSubtext
                anchors.verticalCenter: parent.verticalCenter
            }

            StyledText {
                text: root.vpnActive ? "VPN" : "VPN"
                font.pixelSize: Theme.barTextSize(root.barThickness, root.barConfig?.fontScale)
                font.weight: Font.Medium
                color: root.vpnActive ? root.catGreen : root.catSubtext
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    verticalBarPill: Component {
        Column {
            spacing: Theme.spacingXS

            DankIcon {
                name: root.vpnActive ? "vpn_lock" : "vpn_lock_off"
                size: Math.round(root.iconSize * (root.barConfig?.fontScale ?? 1.0))
                color: root.vpnActive ? root.catGreen : root.catSubtext
                anchors.horizontalCenter: parent.horizontalCenter
            }

            StyledText {
                text: root.vpnActive ? "ON" : "OFF"
                font.pixelSize: Theme.barTextSize(root.barThickness, root.barConfig?.fontScale)
                font.weight: Font.Medium
                color: root.vpnActive ? root.catGreen : root.catSubtext
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    popoutContent: Component {
        PopoutComponent {
            id: popout
            headerText: "VPN Status"
            detailsText: root.vpnActive ? "sing-box is running" : "sing-box is stopped"
            showCloseButton: true

            Component.onCompleted: {
                root.loadDomains()
            }

            Column {
                width: parent.width
                spacing: Theme.spacingM

                // Toggle button
                Rectangle {
                    width: parent.width
                    height: 50
                    radius: Theme.cornerRadius
                    color: root.vpnActive ? Qt.rgba(Theme.success.r, Theme.success.g, Theme.success.b, 0.3) : Theme.surfaceVariant

                    Row {
                        anchors.centerIn: parent
                        spacing: Theme.spacingS

                        DankIcon {
                            name: root.vpnActive ? "power_settings_new" : "power_off"
                            size: 24
                            color: root.vpnActive ? Theme.success : Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: root.isLoading ? "Switching..." : (root.vpnActive ? "Disable VPN" : "Enable VPN")
                            font.pixelSize: Theme.fontSizeMedium
                            font.weight: Font.Bold
                            color: root.vpnActive ? Theme.success : Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        enabled: !root.isLoading
                        onClicked: root.toggleVpn()
                    }
                }

                // Domain columns header
                Row {
                    width: parent.width
                    spacing: Theme.spacingS

                    Rectangle {
                        width: (parent.width - Theme.spacingS) / 2
                        height: 30
                        radius: Theme.cornerRadius / 2
                        color: Theme.surfaceContainerHigh

                        StyledText {
                            anchors.centerIn: parent
                            text: "Proxy (" + root.proxyDomains.length + ")"
                            font.pixelSize: Theme.fontSizeSmall
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                        }
                    }

                    Rectangle {
                        width: (parent.width - Theme.spacingS) / 2
                        height: 30
                        radius: Theme.cornerRadius / 2
                        color: Theme.surfaceContainerHigh

                        StyledText {
                            anchors.centerIn: parent
                            text: "Direct (" + root.directDomains.length + ")"
                            font.pixelSize: Theme.fontSizeSmall
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                        }
                    }
                }

                // Domain lists
                Row {
                    width: parent.width
                    height: 280
                    spacing: Theme.spacingS

                    // Proxy domains column
                    Rectangle {
                        width: (parent.width - Theme.spacingS) / 2
                        height: parent.height
                        radius: Theme.cornerRadius
                        color: Theme.surfaceVariant

                        ListView {
                            id: proxyList
                            anchors.fill: parent
                            anchors.margins: Theme.spacingXS
                            model: root.proxyDomains
                            clip: true
                            spacing: 2

                            delegate: Rectangle {
                                width: proxyList.width
                                height: 22
                                radius: 4
                                color: index % 2 === 0 ? "transparent" : Qt.rgba(255, 255, 255, 0.03)

                                StyledText {
                                    anchors.left: parent.left
                                    anchors.leftMargin: 4
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: modelData
                                    font.pixelSize: 11
                                    color: Theme.surfaceText
                                    elide: Text.ElideMiddle
                                    width: parent.width - 8
                                }
                            }

                            ScrollBar.vertical: ScrollBar {
                                active: true
                            }
                        }
                    }

                    // Direct domains column
                    Rectangle {
                        width: (parent.width - Theme.spacingS) / 2
                        height: parent.height
                        radius: Theme.cornerRadius
                        color: Theme.surfaceVariant

                        ListView {
                            id: directList
                            anchors.fill: parent
                            anchors.margins: Theme.spacingXS
                            model: root.directDomains
                            clip: true
                            spacing: 2

                            delegate: Rectangle {
                                width: directList.width
                                height: 22
                                radius: 4
                                color: index % 2 === 0 ? "transparent" : Qt.rgba(255, 255, 255, 0.03)

                                StyledText {
                                    anchors.left: parent.left
                                    anchors.leftMargin: 4
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: modelData
                                    font.pixelSize: 11
                                    color: Theme.surfaceText
                                    elide: Text.ElideMiddle
                                    width: parent.width - 8
                                }
                            }

                            ScrollBar.vertical: ScrollBar {
                                active: true
                            }
                        }
                    }
                }

                // Refresh button
                Rectangle {
                    width: parent.width
                    height: 36
                    radius: Theme.cornerRadius
                    color: Theme.surfaceVariant

                    Row {
                        anchors.centerIn: parent
                        spacing: Theme.spacingXS

                        DankIcon {
                            name: "refresh"
                            size: 18
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Refresh Domains"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.loadDomains()
                    }
                }
            }
        }
    }
}
