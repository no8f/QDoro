import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "./Components"

import QDoro

ScrollView {
    id: pomodoro_parent
    anchors.fill: parent
    contentWidth: availableWidth

    property bool isPomodoroRunning: false

    signal progressChanged(value: real)

    Timer {
        id: time_elapsed
        property int secondsToGo: 100
        property int secondsPassed: 0

        interval: 1000
        repeat: true
        running: pomodoro_parent.isPomodoroRunning && secondsToGo > secondsPassed
        onTriggered: {
            secondsPassed += 1
        }

        onRunningChanged: {
            pomodoro_parent.isPomodoroRunning = time_elapsed.running
            if ( secondsToGo === secondsPassed ) { // Time run out
                QDoroTrayIcon.showNotification(qsTr("Pomodoro Time is up!"), qsTr("Time for a break!"))
                todo_list.pomodoroFinished()
            }
        }

        onSecondsPassedChanged: {
            var percent = ( secondsPassed / secondsToGo ) * 100.0

            pomodoro_parent.progressChanged(percent)
        }

        function formatTime(seconds) {
            var minutes = Math.floor(seconds / 60);
            var secs = seconds % 60;
            return (minutes < 10 ? "0" : "") + minutes + ":" +
                    (secs < 10 ? "0" : "") + secs;
        }
    }

    ColumnLayout {
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 16

        anchors.topMargin: pomodoro_parent.availableHeight / 2 - ( (navi_btns.height + times.height + start_btn.height + (spacing*2) ) / 2 )

        ButtonGroup {
            id: navi_btns_group
            buttons: navi_btns.children
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            id: navi_btns
            Button {
                checkable: true
                checked: true
                text: qsTr("Pomodoro")
            }
            Button {
                checkable: true
                text: qsTr("Short Break")
            }
            Button {
                checkable: true
                text: qsTr("Long Break")
            }
        }

        SwipeView {
            id: times
            Layout.alignment: Qt.AlignHCenter
            currentIndex: navi_btns_group.buttons.indexOf(navi_btns_group.checkedButton)
            clip: true

            onCurrentIndexChanged: {
                navi_btns_group.buttons[currentIndex].checked = true

                switch (times.currentIndex) {
                case 0: time_elapsed.secondsToGo = 1500; break;
                case 1: time_elapsed.secondsToGo = 300; break;
                case 2: time_elapsed.secondsToGo = 900; break;
                }

                time_elapsed.secondsPassed = 0
            }

            Repeater {
                model: 3
                Frame {
                    Layout.preferredWidth: navi_btns.width
                    Label {
                        id: pomodoro_time
                        font.pointSize: 62
                        font.bold: true
                        text: time_elapsed.formatTime(time_elapsed.secondsToGo-time_elapsed.secondsPassed)//"25:00"
                    }
                }
            }
        }

        RoundButton {
            id: start_btn
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredHeight: 60
            Layout.preferredWidth: 180
            highlighted: true

            text: pomodoro_parent.isPomodoroRunning ? qsTr("Pause") : qsTr("Start")
            font.pointSize: 24
            font.bold: true

            Behavior on Layout.preferredWidth {
                NumberAnimation { duration: 50 }
            }

            Behavior on Layout.preferredHeight {
                NumberAnimation { duration: 100 }
            }

            onClicked: {
                pomodoro_parent.isPomodoroRunning = !pomodoro_parent.isPomodoroRunning
                start_btn.Layout.preferredWidth = 180
                start_btn.Layout.preferredHeight = 60

            }
            onPressed: {
                start_btn.Layout.preferredWidth = 175
                start_btn.Layout.preferredHeight = 55
            }

            Button {
                id: skip_pomodoro

                anchors.verticalCenter: start_btn.verticalCenter
                anchors.left: start_btn.right
                anchors.leftMargin: 16
                flat: true
                icon.source: "qrc:/ressources/icons/ic_fluent_next_24_filled.svg"
                icon.width: 36
                icon.height: 36

                ToolTip.visible: hovered && enabled
                ToolTip.text: qsTr("Skip Timer")
                ToolTip.delay: 1000

                opacity: pomodoro_parent.isPomodoroRunning ? 1 : 0.2
                enabled: opacity === 0.2 ? false : true

                Behavior on opacity {
                    NumberAnimation {
                        duration: 500 // Duration of animation in milliseconds
                    }
                }

                onClicked: {
                    time_elapsed.secondsPassed = time_elapsed.secondsToGo
                }
            }

            Button {
                id: reset_pomodoro
                anchors.verticalCenter: start_btn.verticalCenter
                anchors.right: start_btn.left
                anchors.rightMargin: 16
                flat: true
                icon.source: "qrc:/ressources/icons/ic_fluent_arrow_reset_24_filled.svg"
                icon.width: 36
                icon.height: 36

                opacity: time_elapsed.secondsPassed > 0 ? 1 : 0.2
                enabled: opacity === 0.2 ? false : true

                ToolTip.visible: hovered && enabled
                ToolTip.text: qsTr("Reset Timer")
                ToolTip.delay: 1000

                Behavior on opacity {
                    NumberAnimation {
                        duration: 500 // Duration of animation in milliseconds
                    }
                }

                onClicked: {
                    time_elapsed.secondsPassed = 0
                    if ( pomodoro_parent.isPomodoroRunning )
                        start_btn.click()
                }
            }
        }

        Frame {
            id: task_frame
            Layout.preferredWidth: navi_btns.width * 2
            Layout.minimumHeight: 300
            Layout.topMargin: parent.anchors.topMargin

            TodoList{
                id: todo_list
            }
        }

        Rectangle {
            id: spacer
            color: "transparent"
            Layout.preferredHeight: parent.anchors.topMargin * 2
        }
    }
}
