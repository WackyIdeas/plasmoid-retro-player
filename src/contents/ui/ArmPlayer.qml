import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.components as PlasmaComponents

import org.kde.ksvg as KSvg
import org.kde.kirigami as Kirigami
import org.kde.coreaddons as KCoreAddons

Item {
    id: armPlayer

    width: 211
    height: 195

    property bool active: false
    property var mprisController: null
    property alias albumCover: cover

    readonly property int durationFormattingOptions: mprisController?.length >= 60*60*1000*1000 ? 0 : KCoreAddons.FormatTypes.FoldHours

    Image {
        id: cover
        width: 146
        height: 146
        anchors {
            top: parent.top
            right: parent.right
            topMargin: 6
            rightMargin: 5
        }
        source: mprisController?.albumArt == "" ? Qt.resolvedUrl("img/missing.png") : mprisController?.albumArt
        smooth: true
        mipmap: true

        HoverHandler {
            id: hoverHandler
        }

        component ControlButton: QQC2.Button {
            id: ctlBtn
            property var iconSrc: ""
            Layout.preferredWidth: Kirigami.Units.iconSizes.small
            Layout.preferredHeight: Kirigami.Units.iconSizes.small
            background: Rectangle {
                implicitWidth: 16
                implicitHeight: 16
                color: ctlBtn.down ? "#88ffffff" : "transparent"
                border.width: 1
                border.pixelAligned: true
                radius: 4
                border.color: (ctlBtn.hovered && ctlBtn.enabled) ? "white" : "transparent"
                opacity: ctlBtn.enabled ? 1.0 : 0.5
                Image {
                    anchors.centerIn: parent
                    source: ctlBtn.iconSrc
                }
            }
        }
        Image {
            id: controls
            source: Qt.resolvedUrl("img/controlbg.png")
            width: 128
            height: 95
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: Math.ceil(parent.anchors.rightMargin / 2)
            visible: hoverHandler.hovered
            ColumnLayout {
                id: container
                anchors.fill: parent
                anchors.margins: Kirigami.Units.largeSpacing
                spacing: 3
                ColumnLayout {
                    spacing: 0
                    Text {
                        Layout.fillWidth: true
                        color: "white"
                        text: mprisController?.track
                        elide: Text.ElideRight
                        font.pointSize: 8
                    }
                    Text {
                        Layout.fillWidth: true
                        color: "white"
                        text: mprisController?.album
                        elide: Text.ElideRight
                        font.pointSize: 8
                    }
                    Text {
                        Layout.fillWidth: true
                        color: "white"
                        text: mprisController?.artist
                        elide: Text.ElideRight
                        font.pointSize: 8
                    }
                }
                Image {
                    id: volumeBg
                    property int imgWidth: 102
                    property int imgHeight: 10
                    Layout.preferredHeight: imgHeight
                    Layout.preferredWidth: imgWidth
                    Layout.alignment: Qt.AlignHCenter
                    source: Qt.resolvedUrl("img/volumebg.png")
                    QQC2.Slider {
                        id: volumeSlider
                        anchors.fill: parent
                        to: 1.0
                        value: mprisController?.mpris2Model.currentPlayer.volume
                        background: Image {
                            sourceClipRect: Qt.rect(0, 0, Math.ceil(volumeSlider.value * volumeBg.imgWidth), volumeBg.imgHeight)
                            width: Math.ceil(volumeSlider.value * volumeBg.imgWidth)
                            height: volumeBg.imgHeight
                            source: Qt.resolvedUrl("img/volume.png")
                        }
                        onValueChanged: {
                            // only change when it actually changes
                            var mpris = mprisController?.mpris2Model.currentPlayer;
                            if(value != mpris.volume) {
                                mpris.volume = value;
                            }
                        }
                    }
                }
                RowLayout {
                    spacing: 0
                    Layout.alignment: Qt.AlignHCenter
                    ControlButton {
                        id: previousButton
                        iconSrc: Qt.resolvedUrl("img/prev.png")
                        onClicked: mprisController?.previous();
                        enabled: mprisController?.canGoPrevious
                    }
                    ControlButton {
                        id: pauseButton
                        iconSrc: mprisController?.isPlaying ? Qt.resolvedUrl("img/pause.png") : Qt.resolvedUrl("img/play.png")
                        onClicked: mprisController?.togglePlaying();
                        enabled: mprisController?.isPlaying ? mprisController?.canPause : mprisController?.canPlay
                    }
                    ControlButton {
                        id: nextButton
                        iconSrc: Qt.resolvedUrl("img/next.png")
                        onClicked: mprisController?.next();
                        enabled: mprisController?.canGoNext
                    }
                }

                Item {
                    Layout.fillHeight: true
                }
            }
        }

    }

    Image {
        id: frame
        anchors.fill: parent
        source: active ? Qt.resolvedUrl("img/cover_on.png") : Qt.resolvedUrl("img/cover_off.png")
    }

}
