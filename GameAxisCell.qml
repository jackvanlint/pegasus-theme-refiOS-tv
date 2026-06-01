// Pegasus Frontend — refiOS-tv tile cell.
// Renders one app tile in the row. Special case: the synthetic "Add app" entry
// is rendered as a centred "+" glyph instead of a logo/screenshot, signalling
// that activating it opens the add-app picker.

import QtQuick 2.7
import QtGraphicalEffects 1.0

Item {
    property var game
    property bool selected: false
    property var selectedRow: false

    readonly property bool isAddTile: game && game.title === "Add app"

    scale: selected && selectedRow ? 1.20 : 1.0
    z: selected && selectedRow ? 3 : 1

    // selected border
    Rectangle {
        id: selec
        width: selected && selectedRow ? parent.width + parent.width * 0.03 : 0
        height: parent.height + parent.height * 0.08
        color: "white"
        opacity: 0.2
        anchors.centerIn: parent
        z: 0
    }
    Rectangle {
        id: shadow
        width: selec.width * 0.95
        height: selec.height * 0.65
        anchors.centerIn: selec
        visible: false
    }
    RectangularGlow {
        id: effect
        anchors.fill: shadow
        glowRadius: 30
        spread: 0.2
        visible: selectedRow && selected
        color: "black"
        opacity: 0.4
        anchors.centerIn: parent
        cornerRadius: glowRadius
        z: -1
    }

    Behavior on scale { PropertyAnimation { duration: 150 } }

    // ── "+" add-app tile ────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        visible: isAddTile
        color: "transparent"
        border.color: "white"
        border.width: vpx(2)
        radius: vpx(6)
        opacity: 0.6

        Text {
            anchors.centerIn: parent
            text: "+"
            color: "white"
            font {
                pixelSize: parent.height * 0.7
                family: globalFonts.sans
                weight: Font.Light
            }
        }
    }

    // ── regular app tile (fallback + logo over screenshot) ──────────────
    Rectangle {
        anchors.fill: parent
        color: "#333"
        visible: !isAddTile && image.status !== Image.Ready

        Image {
            anchors.centerIn: parent
            visible: image.status === Image.Loading
            source: "assets/loading-spinner.png"
            RotationAnimator on rotation {
                loops: Animator.Infinite
                from: 0; to: 360
                duration: 500
            }
        }

        Text {
            text: model.title
            width: parent.width * 0.8
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            anchors.centerIn: parent
            visible: !model.assets.gridicon
            color: "#eee"
            font {
                pixelSize: vpx(16)
                family: globalFonts.sans
            }
        }
    }

    Item {
        id: delegateContainer
        anchors.fill: parent
        visible: !isAddTile

        Image {
            id: screenshot
            width: parent.width
            height: parent.height
            asynchronous: true
            smooth: true
            source: modelData.assets.screenshots[0] ? modelData.assets.screenshots[0] : ""
            sourceSize { width: 256; height: 256 }
            fillMode: Image.PreserveAspectCrop
        }

        Rectangle {
            width: parent.width
            height: parent.height
            color: "black"
            opacity: 0.5
            visible: screenshot.source != ""
        }

        Image {
            id: image
            width: screenshot.width
            height: screenshot.height
            anchors {
                fill: parent
                margins: vpx(6)
            }
            asynchronous: true
            source: modelData.assets.logo ? modelData.assets.logo : ""
            sourceSize { width: 256; height: 256 }
            fillMode: Image.PreserveAspectFit
            smooth: true
            visible: modelData.assets.logo ? modelData.assets.logo : ""
            z: 8
        }
    }
}
