import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

ShellRoot {
    PanelWindow {
        anchors {
            top: true
            left: true
            right: true
        }
        height: 40
        color: "#11111b"

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            spacing: 12

            Text {
                text: "🌫️ SMOKE OS"
                color: "#cdd6f4"
                font.bold: true
                font.pixelSize: 14
                font.family: "JetBrainsMono Nerd Font"
            }

            Item {
                Layout.fillWidth: true
            }

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
                clock.text = Qt.formatDateTime(new Date(), "hh:mm  ddd, dd MMM")
            }
        }
    }
}
