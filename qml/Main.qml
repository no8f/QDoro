import QtQuick
import QtQuick.Controls

import "./Dashboard"

ApplicationWindow {
    width: 640
    height: 480
    visible: true
    title: " "
    color: "transparent"

    PomodoroTimer {
        anchors.fill: parent
        onProgressChanged: (value) => {
                               progress.value = value
                           }
    }

    ProgressBar {
        id: progress
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.left: parent.left
        from: 0
        to: 100
        value: 0

        background: Item{}

        Behavior on value {
            PropertyAnimation {
                duration: 1000 // Dauer der Animation in Millisekunden
            }
        }
    }
}
