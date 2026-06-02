import QtQuick 2.15

Item {
    id: tile

    property var   game
    property bool  isCurrent: false
    property int   tileW: 200
    property int   tileH: 120
    property color clrCard: "#1A1120"
    property color clrRose: "#C48BAA"
    property color clrText: "#EDD6E8"

    width:  tileW
    height: tileH
    z:      isCurrent ? 3 : 1

    scale: isCurrent ? 1.10 : 1.0
    Behavior on scale { NumberAnimation { duration: 130; easing.type: Easing.OutQuad } }

    readonly property bool isAdd: game && game.title === "Add app"

    // Card background
    Rectangle {
        anchors.fill: parent
        radius: vpx(8)
        color:        tile.isAdd ? "transparent" : tile.clrCard
        border.color: tile.isCurrent ? tile.clrRose : (tile.isAdd ? "#3A2340" : "transparent")
        border.width: vpx(2)
    }

    // App logo
    Image {
        anchors { fill: parent; margins: vpx(10) }
        fillMode:     Image.PreserveAspectFit
        smooth:       true
        asynchronous: true
        source:       (!tile.isAdd && tile.game && tile.game.assets.logo) ? tile.game.assets.logo : ""
        visible:      !tile.isAdd && source !== ""
        sourceSize { width: 256; height: 256 }
    }

    // Text fallback when no logo
    Text {
        anchors.centerIn: parent
        visible:          !tile.isAdd && !(tile.game && tile.game.assets.logo)
        text:             tile.game ? tile.game.title : ""
        color:            tile.clrText
        font.pixelSize:   vpx(13)
        horizontalAlignment: Text.AlignHCenter
        width: parent.width - vpx(16)
        wrapMode: Text.WordWrap
    }

    // "+" symbol for Add tile
    Text {
        anchors.centerIn: parent
        visible:          tile.isAdd
        text:             "+"
        color:            tile.isCurrent ? tile.clrRose : "#44334A"
        font.pixelSize:   tile.tileH * 0.5
    }
}
