import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Qt5Compat.GraphicalEffects

ColumnLayout {
    id: todoList_parent
    anchors.fill: parent

    property int currentPomos: 0

    function pomodoroFinished() {
        for (var i = 0; i < task_model_view.count; i++) {
            if (task_model_view.itemAtIndex(i) && task_model_view.itemAtIndex(i).checked === false) {
                task_model_view.itemAtIndex(i).currentPomos = task_model_view.itemAtIndex(i).currentPomos + 1
                break;
            }
        }
    }

    ListModel {
        id: task_model
    }

    ListView {
        id: task_model_view
        model: task_model
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.preferredHeight: contentHeight

        clip: true

        delegate: Frame {
            id: task_parent
            property bool checked: task_check_box.checked
            property int currentPomos: 0
            width: task_model_view.width

            RowLayout {
                id: task_row
                //uniformCellSizes: true
                anchors.fill: parent

                CheckBox {
                    id: task_check_box
                    onCheckedChanged: {
                        todoList_parent.currentPomos = 0
                    }
                }

                TextArea {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    horizontalAlignment: TextEdit.AlignHCenter
                    Layout.preferredWidth: 800
                    text: model.taskDesc
                    background: Item{}
                }

                Pane {
                    Layout.preferredWidth: task_check_box.implicitWidth
                    background: Item{}
                    enabled: false
                    Label {
                        enabled: true
                        anchors.right: parent.right
                        text: task_parent.currentPomos + "/" + model.pomos
                    }
                }
            }

            Menu {
                id: task_context_menu

                // background: Frame {
                //     implicitWidth: 200
                //     implicitHeight: 40
                // }

                // delegate: MenuItem {
                //     id: menuItem
                //     implicitWidth: 200
                //     implicitHeight: 40

                //     contentItem: Label {
                //         text: menuItem.text
                //         font: menuItem.font
                //     }
                // }

                MenuItem {
                    text: qsTr("Delete")
                    icon.source: "qrc:/ressources/icons/ic_fluent_delete_24_filled.svg"
                    onClicked: {
                        task_model.remove(index)
                    }
                }
            }

            TapHandler {
                id: tab_handler
                acceptedButtons: Qt.RightButton
                onTapped:  {
                    console.log("Clicked")
                    task_context_menu.popup(tab_handler.point.position.x, tab_handler.point.position.y)
                }
            }
        }
    }

    Frame {
        visible: false
        id: new_task_field
        Layout.alignment: Qt.AlignHCenter
        //Layout.preferredWidth: 300

        ColumnLayout {
            anchors.fill: parent
            spacing: 16

            TextArea {
                Layout.fillWidth: true

                id: task_desc
                placeholderText: qsTr("What are you working on?")
            }

            RowLayout {
                Label {
                    text: qsTr("Est Pomodoros")
                }

                SpinBox {
                    id: est_pomos
                }

                ToolButton {
                    id: cancel_new_task
                    icon.source: "qrc:/ressources/icons/ic_fluent_dismiss_24_filled(1).svg"
                    onClicked: {
                        new_task_field.visible = false
                    }
                }

                ToolButton {
                    Layout.alignment: Qt.AlignRight
                    id: append_new_task
                    icon.source: "qrc:/ressources/icons/ic_fluent_send_24_filled.svg"
                    highlighted: true
                    onClicked: {
                        new_task_field.visible = false
                        task_model.append({"taskDesc" : task_desc.text, "pomos" : est_pomos.value})
                    }
                }
            }
        }
    }

    Button {
        Layout.alignment: Qt.AlignHCenter
        text: qsTr("New Task")
        visible: !new_task_field.visible
        highlighted: true
        onClicked: {
            new_task_field.visible = true
        }

        icon.source: "qrc:/ressources/icons/ic_fluent_task_list_add_24_filled.svg"
    }

}
