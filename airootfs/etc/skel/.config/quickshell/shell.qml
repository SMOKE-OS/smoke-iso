import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Widgets

ShellRoot {
    id: root

    property bool launcherOpen: false
    property string searchQuery: ""

    function toggleLauncher(): void {
        root.launcherOpen = !root.launcherOpen;
        if (root.launcherOpen) {
            root.searchQuery = "";
            searchInput.text = "";
            searchInput.forceActiveFocus();
        }
    }

    // --- IPC endpoint for toggling via keyboard shortcut ---
    // Triggered with: quickshell ipc call launcher toggle
    IpcHandler {
        target: "launcher"

        function toggle(): void {
            root.toggleLauncher();
        }

        function open(): void {
            root.launcherOpen = true;
            root.searchQuery = "";
            searchInput.text = "";
            searchInput.forceActiveFocus();
        }

        function close(): void {
            root.launcherOpen = false;
        }
    }

    // --- Filtered Applications Model ---
    property var filteredApps: {
        let list = [];
        if (DesktopEntries && DesktopEntries.applications) {
            let raw = DesktopEntries.applications.values || DesktopEntries.applications;
            let count = raw.length !== undefined ? raw.length : (raw.count !== undefined ? raw.count : 0);
            for (let i = 0; i < count; i++) {
                let app = raw[i];
                if (app && app.name) list.push(app);
            }
        }
        let query = root.searchQuery.trim().toLowerCase();
        if (!query) return list;
        return list.filter(function(app) {
            let name = (app.name || "").toLowerCase();
            let comment = (app.comment || "").toLowerCase();
            let generic = (app.genericName || "").toLowerCase();
            return name.indexOf(query) !== -1 || comment.indexOf(query) !== -1 || generic.indexOf(query) !== -1;
        });
    }

    // =========================================================
    // 1. TOP STATUS BAR
    // =========================================================
    PanelWindow {
        id: bar
        anchors {
            top: true
            left: true
            right: true
        }
        height: 40
        color: "#11111b"

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 16
            spacing: 12

            // Launcher Button in Bar
            Rectangle {
                id: launcherBtn
                Layout.preferredHeight: 30
                Layout.preferredWidth: logoText.implicitWidth + 20
                radius: 6
                color: btnMouse.containsMouse ? "#1e1e2e" : "transparent"

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 6

                    Text {
                        id: logoText
                        text: "🌫️ SMOKE OS"
                        color: "#cdd6f4"
                        font.bold: true
                        font.pixelSize: 13
                        font.family: "JetBrainsMono Nerd Font"
                    }
                }

                MouseArea {
                    id: btnMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.toggleLauncher()
                }
            }

            Item {
                Layout.fillWidth: true
            }

            // Clock & Date
            Text {
                id: clock
                text: Qt.formatDateTime(new Date(), "hh:mm  ddd, dd MMM")
                color: "#89b4fa"
                font.pixelSize: 13
                font.bold: true
                font.family: "JetBrainsMono Nerd Font"
            }
        }

        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: {
                clock.text = Qt.formatDateTime(new Date(), "hh:mm  ddd, dd MMM");
            }
        }
    }

    // =========================================================
    // 2. NATIVE QUICKSHELL APPLICATION LAUNCHER OVERLAY
    // =========================================================
    PanelWindow {
        id: launcherWindow
        visible: root.launcherOpen

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "smoke-launcher"
        WlrLayershell.keyboardFocus: root.launcherOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        // Dim background backdrop
        color: "#990a0a10"

        // Click on dim backdrop to close launcher
        MouseArea {
            anchors.fill: parent
            onClicked: root.launcherOpen = false
        }

        // Main Dialog Card
        Rectangle {
            id: modal
            width: 540
            height: 480
            anchors.centerIn: parent
            color: "#11111b"
            radius: 12
            border.color: "#313244"
            border.width: 1

            // Prevent backdrop click when clicking inside card
            MouseArea {
                anchors.fill: parent
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                // Search Input Box
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    radius: 8
                    color: "#181825"
                    border.color: searchInput.activeFocus ? "#89b4fa" : "#313244"
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 10

                        Text {
                            text: "🔍"
                            font.pixelSize: 14
                        }

                        TextInput {
                            id: searchInput
                            Layout.fillWidth: true
                            color: "#cdd6f4"
                            font.pixelSize: 14
                            font.family: "JetBrainsMono Nerd Font"
                            clip: true

                            Text {
                                text: "Search applications..."
                                color: "#6c7086"
                                font.pixelSize: 14
                                font.family: "JetBrainsMono Nerd Font"
                                visible: !searchInput.text && !searchInput.inputMethodComposing
                            }

                            onTextChanged: {
                                root.searchQuery = text;
                            }

                            Keys.onEscapePressed: {
                                root.launcherOpen = false;
                            }

                            Keys.onReturnPressed: {
                                if (root.filteredApps.length > 0) {
                                    root.filteredApps[0].execute();
                                    root.launcherOpen = false;
                                }
                            }
                        }
                    }
                }

                // Application List View
                ListView {
                    id: appListView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: root.filteredApps

                    delegate: Rectangle {
                        width: appListView.width
                        height: 44
                        radius: 6
                        color: delegateMouse.containsMouse ? "#1e1e2e" : "transparent"

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 12

                            Rectangle {
                                width: 28
                                height: 28
                                radius: 4
                                color: "#181825"

                                IconImage {
                                    anchors.centerIn: parent
                                    width: 22
                                    height: 22
                                    source: Quickshell.iconPath(modelData.icon || "application-x-executable")
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Text {
                                    text: modelData.name || ""
                                    color: "#cdd6f4"
                                    font.bold: true
                                    font.pixelSize: 13
                                    font.family: "JetBrainsMono Nerd Font"
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: modelData.genericName || modelData.comment || ""
                                    color: "#6c7086"
                                    font.pixelSize: 11
                                    font.family: "JetBrainsMono Nerd Font"
                                    elide: Text.ElideRight
                                    visible: text !== ""
                                    Layout.fillWidth: true
                                }
                            }
                        }

                        MouseArea {
                            id: delegateMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                modelData.execute();
                                root.launcherOpen = false;
                            }
                        }
                    }
                }

                // Footer Hints
                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "Press [Enter] to run  •  [Esc] to close"
                        color: "#585b70"
                        font.pixelSize: 11
                        font.family: "JetBrainsMono Nerd Font"
                    }
                }
            }
        }
    }
}
