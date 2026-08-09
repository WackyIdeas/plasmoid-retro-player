import QtQuick
import QtQuick.Layouts

import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.components as PlasmaComponents

import org.kde.ksvg as KSvg
import org.kde.kirigami as Kirigami
import org.kde.plasma.private.mpris as Mpris

PlasmoidItem {
    id: root

    // BEGIN GADGET STUFF
    readonly property string plasmoidType: "Gadget"
    readonly property bool resizable: false
    signal requestSizeUpdate()
    // END GADGET STUFF

    readonly property bool mediaActive: (mediaController.mediaPlayerOpen && mediaController.playbackStatus > Mpris.PlaybackStatus.Stopped) &&
                                        !(mediaController.playbackStatus === Mpris.PlaybackStatus.Paused && mediaController.track === "" && mediaController.artist === "" && mediaController.album === "" && mediaController.albumArt === "" && !mediaController.canQuit)
    Plasmoid.backgroundHints: "NoBackground";

    property int lastUsedIndex: -1
    property string lastUsedName: ""

    Layout.minimumWidth: 214
    Layout.minimumHeight: 195
    Layout.maximumWidth: 214
    Layout.maximumHeight: 195

    MprisController { id: mediaController }

    Instantiator {
        model: mediaController.mpris2Model
        delegate: PlasmaExtras.MenuItem {
            required property int index
            required property var model

            text: model.identity + "      "
            icon: model.iconName == "emblem-favorite" ? "bookmark_add" : model.iconName
            checkable: true
            checked: mediaController.currentIndex == index
            onClicked: {
                root.lastUsedIndex = index;
                root.lastUsedName = model.identity;
                mediaController.currentIndex = index;
            }
        }
        onObjectAdded: (index, object) => {
            if(object.model.identity == root.lastUsedName) mediaController.currentIndex = root.lastUsedIndex;
            contextMenu.addMenuItem(object);
        }
        onObjectRemoved: (index, object) => contextMenu.removeMenuItem(object)
    }

    PlasmaExtras.Menu {
        id: contextMenu

        visualParent: containerRect
        placement: PlasmaExtras.Menu.FloatingPopup
    }

    /*
     * Supplying ImageColors with the album art directly can cause
     * plasmashell to crash in rare circumstances (for example,
     * Strawberry trying to play a song that got relocated or deleted
     * will cause a crash).
     * As a workaround, supply ImageColors with the Image item
     * displaying the album cover. This requires manually updating
     * the colors as the album art changes.
     */
    property var coverArt: mediaController.albumArt
    onCoverArtChanged: {
        albumArtColor.update();
    }

    Kirigami.ImageColors {
        id: albumArtColor
        source: armPlayer.albumCover
    }
    Item {
        id: containerRect

        width: root.Layout.maximumWidth
        height: root.Layout.maximumHeight
        anchors.centerIn: parent

        Vinyl {
            id: vinyl
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.topMargin: 5
            rotating: mediaController.isPlaying
            canColorize: root.coverArt != "" && discColorization.valid
            discColorization: {
                if (mediaController.albumArt === "") return "";
                var col = albumArtColor.dominant;
                if (col.hsvSaturation < 0.3) return "";
                if (col.hsvValue < 0.3) return "";
                return col;
            }
        }

        ArmPlayer {
            id: armPlayer
            anchors.top: parent.top
            anchors.right: parent.right
            active: root.mediaActive
            mprisController: mediaController
        }
        MouseArea {
            anchors.fill: vinyl
            anchors.rightMargin: vinyl.width / 1.75
            acceptedButtons: Qt.RightButton
            onClicked: mouse => {
                contextMenu.open(mouse.x, mouse.y);
                console.log(vinyl.discColorization.valid && root.coverArt != "");
                console.log(root.coverArt != "")
                console.log(vinyl.discColorization.valid)
            }
        }

    }
    Timer {
        id: refresh
        interval: 20
        onTriggered: {
            var old = mediaController.currentIndex;
            mediaController.currentIndex = -1;
            mediaController.currentIndex = old;
        }
    }
    Component.onCompleted: {
        refresh.start()
    }

}
