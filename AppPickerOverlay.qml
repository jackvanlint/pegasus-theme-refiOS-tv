// Pin picker overlay — grid of all apps; click selects the new pinned app.

import QtQuick 2.7

Rectangle {
    id: root
    color: "#000"
    opacity: 0.92

    property var model
    signal picked(string title)
    signal dismissed()

    MouseArea {
        anchors.fill: parent
        onClicked: root.dismissed()
    }

    Text {
        id: header
        anchors {
            top: parent.top
            topMargin: vpx(40)
            horizontalCenter: parent.horizontalCenter
        }
        text: "Pin an app to the hero"
        color: "white"
        font {
            pixelSize: vpx(28)
            family: globalFonts.sans
        }
    }

    Text {
        anchors {
            top: header.bottom
            topMargin: vpx(8)
            horizontalCenter: parent.horizontalCenter
        }
        text: "Tap outside to cancel"
        color: "#888"
        font {
            pixelSize: vpx(14)
            family: globalFonts.sans
        }
    }

    GridView {
        id: grid
        anchors {
            top: header.bottom
            topMargin: vpx(80)
            bottom: parent.bottom
            bottomMargin: vpx(40)
            left: parent.left
            right: parent.right
            leftMargin: vpx(80)
            rightMargin: vpx(80)
        }

        cellWidth: vpx(220)
        cellHeight: vpx(180)
        model: root.model
        clip: true

        delegate: Item {
            width: grid.cellWidth
            height: grid.cellHeight
            visible: modelData.title !== "Add app"

            Rectangle {
                id: tile
                anchors.fill: parent
                anchors.margins: vpx(8)
                color: "#222"
                radius: vpx(6)
                border.color: tileHover.containsMouse ? "white" : "#444"
                border.width: vpx(1)

                Image {
                    anchors.fill: parent
                    anchors.margins: vpx(12)
                    fillMode: Image.PreserveAspectFit
                    source: modelData.assets.logo ? modelData.assets.logo : ""
                    visible: source != ""
                    smooth: true
                    sourceSize { width: 256; height: 256 }
                }
                Text {
                    anchors.centerIn: parent
                    visible: !modelData.assets.logo
                    text: modelData.title
                    color: "white"
                    font {
                        pixelSize: vpx(16)
                        family: globalFonts.sans
                    }
                }

                MouseArea {
                    id: tileHover
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: root.picked(modelData.title)
                }
            }
        }
    }
}
