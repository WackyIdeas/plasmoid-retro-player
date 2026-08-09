/*
    SPDX-FileCopyrightText: 2013 Eike Hein <hein@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami

import org.kde.plasma.plasmoid

KCM.SimpleKCM {
    id: root

    property alias cfg_colorizeVinyl: colorizeVinyl.checked
    property alias cfg_rotationSpeed: rotationSpeed.currentIndex
    property alias cfg_rotateWhenMaximized: rotateWhenMaximized.checked

    component CustomGroupBox: GroupBox {
        id: gbox
        label: Label {
            id: lbl
            x: gbox.leftPadding + 2
            y: lbl.implicitHeight/2-gbox.bottomPadding-1
            width: lbl.implicitWidth
            text: gbox.title
            elide: Text.ElideRight
            Rectangle {
                anchors.fill: parent
                anchors.leftMargin: -2
                anchors.rightMargin: -2
                color: Kirigami.Theme.backgroundColor
                z: -1
            }
        }
        background: Rectangle {
            y: gbox.topPadding - gbox.bottomPadding*2
            width: parent.width
            height: parent.height - gbox.topPadding + gbox.bottomPadding*2
            color: "transparent"
            border.color: "#d5dfe5"
            radius: 3
        }
    }

    ColumnLayout {
        anchors.right: parent.right
        anchors.left: parent.left

        CustomGroupBox {
            Layout.fillWidth: true

            title: i18n("Appearance")

            ColumnLayout {
                CheckBox {
                    id: colorizeVinyl
                    text: i18n("Apply accent color to the vinyl record based on album art")
                }
                RowLayout {
                    Text {
                        text: i18n("Rotation speed:")
                    }
                    ComboBox {
                        id: rotationSpeed
                        model: [
                            i18n("16⅔ rpm"),
                            i18n("33⅓ rpm"),
                            i18n("45 rpm")
                        ]
                        currentIndex: Plasmoid.configuration.rotationSpeed
                    }
                }
                CheckBox {
                    id: rotateWhenMaximized
                    text: i18n("Rotate record even when maximized windows are shown")
                }
            }


        }
    }
}
