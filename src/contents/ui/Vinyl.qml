import QtQuick
import QtQuick.Layouts

import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.components as PlasmaComponents

import org.kde.ksvg as KSvg
import org.kde.kirigami as Kirigami

import QtQuick.Effects

Item {

    id: vinyl
    property bool rotating: false
    property var discColorization: ""

    property bool canColorize: false

    width: disc.implicitWidth
    height: disc.implicitHeight

    property double rotationDegrees: {
        switch(Plasmoid.configuration.rotationSpeed) {
            case 1:
                return 3.4; // 33 rpm
            case 2:
                return 4.59; // 45 rpm
            default:
                return 1.7; // 16.6 rpm
        }
    }
    Timer {
        id: rotationTimer
        interval: 17
        repeat: true
        running: vinyl.rotating
        onTriggered: {
            disc.rotation = disc.rotation + rotationDegrees //3.4
            if (disc.rotation >= 360) disc.rotation = 0;
            //disclabel.rotation = (disclabel.rotation + 1) % 360
        }

    }
    Image {
        id: disc
        source: (vinyl.canColorize && Plasmoid.configuration.colorizeVinyl) ? Qt.resolvedUrl("img/vinyl_colorized.png") : Qt.resolvedUrl("img/vinyl.png")
        layer.enabled: (vinyl.canColorize && Plasmoid.configuration.colorizeVinyl)
        layer.effect: MultiEffect {
            colorization: discColorization === "" ? 0.0 : 1.0
            colorizationColor: discColorization === "" ? "transparent" : discColorization
            brightness: discColorization === "" ? 0.0 : 0.25
            //saturation: discColorization.hsvSaturation
        }
        layer.smooth: true
        antialiasing: true
    }

}
