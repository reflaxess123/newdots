import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    property string variantId: ""
    property var variantData: null

    property string displayIcon: "terminal"
    property string displayText: ""
    property string displayCommand: ""
    property string clickCommand: ""
    property string middleClickCommand: ""
    property string rightClickCommand: ""
    property int updateInterval: 0
    property bool showIcon: true
    property bool showText: true
    property string iconColor: ""
    property string textColor: ""

    property string currentOutput: ""
    property bool isLoading: false

    // Catppuccin Mocha colors
    readonly property var catppuccin: ({
        "rosewater": "#f5e0dc",
        "flamingo": "#f2cdcd",
        "pink": "#f5c2e7",
        "mauve": "#cba6f7",
        "red": "#f38ba8",
        "maroon": "#eba0ac",
        "peach": "#fab387",
        "yellow": "#f9e2af",
        "green": "#a6e3a1",
        "teal": "#94e2d5",
        "sky": "#89dceb",
        "sapphire": "#74c7ec",
        "blue": "#89b4fa",
        "lavender": "#b4befe",
        "text": "#cdd6f4"
    })

    function getColor(colorName) {
        if (!colorName || colorName === "") return Theme.surfaceText
        if (colorName.startsWith("#")) return colorName
        return catppuccin[colorName] || Theme.surfaceText
    }

    onVariantDataChanged: {
        updatePropertiesFromVariantData()
    }

    Connections {
        target: PluginService
        function onPluginDataChanged(changedPluginId) {
            if (changedPluginId === "dankActions" && variantId) {
                const newData = PluginService.getPluginVariantData("dankActions", variantId)
                if (newData) {
                    variantData = newData
                }
            }
        }
    }

    function updatePropertiesFromVariantData() {
        if (!variantData) {
            displayIcon = "terminal"
            displayText = ""
            displayCommand = ""
            clickCommand = ""
            middleClickCommand = ""
            rightClickCommand = ""
            updateInterval = 0
            showIcon = true
            showText = true
            iconColor = ""
            textColor = ""
            currentOutput = ""
            return
        }

        displayIcon = variantData.icon || "terminal"
        displayText = variantData.displayText || ""
        displayCommand = variantData.displayCommand || ""
        clickCommand = variantData.clickCommand || ""
        middleClickCommand = variantData.middleClickCommand || ""
        rightClickCommand = variantData.rightClickCommand || ""
        updateInterval = variantData.updateInterval || 0
        showIcon = variantData.showIcon !== undefined ? variantData.showIcon : true
        showText = variantData.showText !== undefined ? variantData.showText : true
        iconColor = variantData.iconColor || ""
        textColor = variantData.textColor || ""

        if (displayCommand) {
            Qt.callLater(refreshOutput)
        } else {
            currentOutput = displayText
        }
        if (updateInterval > 0) {
            updateTimer.restart()
        }
    }

    onDisplayCommandChanged: {
        if (displayCommand) {
            Qt.callLater(refreshOutput)
        } else {
            currentOutput = displayText
        }
    }

    onDisplayTextChanged: {
        if (!displayCommand) {
            currentOutput = displayText
        }
    }

    onUpdateIntervalChanged: {
        if (updateInterval > 0) {
            updateTimer.restart()
        } else {
            updateTimer.stop()
        }
    }

    Component.onCompleted: {
        if (displayCommand) {
            Qt.callLater(refreshOutput)
        } else {
            currentOutput = displayText
        }
        if (updateInterval > 0) {
            updateTimer.start()
        }
    }

    Timer {
        id: updateTimer
        interval: root.updateInterval * 1000
        repeat: true
        running: false
        onTriggered: {
            if (root.displayCommand) {
                root.refreshOutput()
            }
        }
    }

    function refreshOutput() {
        if (!displayCommand) {
            currentOutput = displayText
            return
        }

        isLoading = true
        displayProcess.running = true
    }

    function executeCommand(command) {
        if (!command) return

        isLoading = true
        actionProcess.command = ["sh", "-c", command]
        actionProcess.running = true
    }

    Process {
        id: displayProcess
        command: ["sh", "-c", root.displayCommand]
        running: false

        stdout: SplitParser {
            onRead: data => {
                root.currentOutput = data.trim()
            }
        }

        onExited: (exitCode, exitStatus) => {
            root.isLoading = false
            if (exitCode !== 0) {
                console.warn("CustomActions: Display command failed with code", exitCode)
            }
        }
    }

    Process {
        id: actionProcess
        command: ["sh", "-c", ""]
        running: false

        onExited: (exitCode, exitStatus) => {
            root.isLoading = false
            if (exitCode === 0) {
                if (root.displayCommand) {
                    root.refreshOutput()
                }
            } else {
                console.warn("CustomActions: Action command failed with code", exitCode)
            }
        }
    }

    pillClickAction: () => {
        if (root.clickCommand) {
            root.executeCommand(root.clickCommand)
        }
    }

    horizontalBarPill: Component {
        MouseArea {
            implicitWidth: contentRow.implicitWidth
            implicitHeight: contentRow.implicitHeight
            acceptedButtons: Qt.MiddleButton | Qt.RightButton
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: (mouse) => {
                if (mouse.button === Qt.MiddleButton && root.middleClickCommand) {
                    root.executeCommand(root.middleClickCommand)
                } else if (mouse.button === Qt.RightButton && root.rightClickCommand) {
                    root.executeCommand(root.rightClickCommand)
                }
            }

            Row {
                id: contentRow
                spacing: Theme.spacingXS

                DankIcon {
                    name: root.displayIcon
                    size: Math.round(root.iconSize * (root.barConfig?.fontScale ?? 1.0))
                    color: root.getColor(root.iconColor)
                    anchors.verticalCenter: parent.verticalCenter
                    visible: root.showIcon
                }

                StyledText {
                    text: root.currentOutput || ""
                    font.pixelSize: Theme.barTextSize(root.barThickness, root.barConfig?.fontScale)
                    font.weight: Font.Medium
                    color: root.getColor(root.textColor)
                    anchors.verticalCenter: parent.verticalCenter
                    visible: root.showText && root.currentOutput
                }
            }
        }
    }

    verticalBarPill: Component {
        MouseArea {
            implicitWidth: contentColumn.implicitWidth
            implicitHeight: contentColumn.implicitHeight
            acceptedButtons: Qt.MiddleButton | Qt.RightButton
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: (mouse) => {
                if (mouse.button === Qt.MiddleButton && root.middleClickCommand) {
                    root.executeCommand(root.middleClickCommand)
                } else if (mouse.button === Qt.RightButton && root.rightClickCommand) {
                    root.executeCommand(root.rightClickCommand)
                }
            }

            Column {
                id: contentColumn
                spacing: Theme.spacingXS

                DankIcon {
                    name: root.displayIcon
                    size: Math.round(root.iconSize * (root.barConfig?.fontScale ?? 1.0))
                    color: root.getColor(root.iconColor)
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: root.showIcon
                }

                StyledText {
                    text: root.currentOutput || ""
                    font.pixelSize: Theme.barTextSize(root.barThickness, root.barConfig?.fontScale)
                    font.weight: Font.Medium
                    color: root.getColor(root.textColor)
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: root.showText && root.currentOutput
                }
            }
        }
    }
}
