import QtQuick 2.15

FocusScope {
    id: overlay

    property var   availColl
    property color clrBg:    "#0B0810"
    property color clrCard:  "#1A1120"
    property color clrRose:  "#C48BAA"
    property color clrMauve: "#9D6E8A"
    property color clrText:  "#EDD6E8"
    property color clrMuted: "#9A7A92"

    signal closed()

    Rectangle {
        anchors.fill: parent
        color:   overlay.clrBg
        opacity: 0.97
    }

    // Header
    Column {
        id: header
        anchors {
            top: parent.top; topMargin: vpx(48)
            horizontalCenter: parent.horizontalCenter
        }
        spacing: vpx(10)

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text:  hasApps ? "Add App" : "Nothing to Add"
            color: overlay.clrText
            font { pixelSize: vpx(34) }
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text:    "←→↑↓  navigate     ●  add     ○  back"
            color:   overlay.clrMuted
            font { pixelSize: vpx(15) }
            visible: hasApps
        }
    }

    readonly property bool hasApps: availColl && availColl.games && availColl.games.count > 0

    // Empty state
    Text {
        anchors.centerIn: parent
        visible:          !overlay.hasApps
        text:             "All installed apps are already in your launcher."
        color:            overlay.clrMuted
        font.pixelSize:   vpx(20)
    }

    // App grid
    GridView {
        id: grid
        anchors {
            top:    header.bottom;  topMargin:    vpx(50)
            bottom: parent.bottom;  bottomMargin: vpx(44)
            left:   parent.left;    leftMargin:   vpx(80)
            right:  parent.right;   rightMargin:  vpx(80)
        }
        cellWidth:  vpx(210)
        cellHeight: vpx(195)
        clip:       true
        focus:      true
        visible:    overlay.hasApps
        model:      overlay.availColl ? overlay.availColl.games : null

        Keys.onLeftPressed:  moveCurrentIndexLeft()
        Keys.onRightPressed: moveCurrentIndexRight()
        Keys.onUpPressed:    moveCurrentIndexUp()
        Keys.onDownPressed:  moveCurrentIndexDown()
        Keys.onPressed: {
            if (event.isAutoRepeat) return
            if (api.keys.isAccept(event)) {
                var g = model.get(currentIndex)
                if (g) g.launch()
                overlay.closed()
                event.accepted = true
            }
            if (api.keys.isCancel(event)) {
                overlay.closed()
                event.accepted = true
            }
        }

        delegate: Item {
            width:  grid.cellWidth
            height: grid.cellHeight

            readonly property bool sel: GridView.isCurrentItem

            Rectangle {
                id: card
                anchors { fill: parent; margins: vpx(8) }
                color:        overlay.clrCard
                radius:       vpx(8)
                border.color: parent.sel ? overlay.clrRose : "transparent"
                border.width: vpx(2)

                scale: parent.sel ? 1.06 : 1.0
                Behavior on scale { NumberAnimation { duration: 110 } }

                Image {
                    anchors { fill: parent; margins: vpx(12) }
                    fillMode:     Image.PreserveAspectFit
                    smooth:       true
                    asynchronous: true
                    source:       modelData.assets.logo ? modelData.assets.logo : ""
                    visible:      source !== ""
                    sourceSize { width: 256; height: 256 }
                }

                Text {
                    anchors.centerIn: parent
                    visible:          !modelData.assets.logo
                    text:             modelData.title
                    color:            overlay.clrText
                    font.pixelSize:   vpx(15)
                    width:            parent.width - vpx(20)
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                }

                // Bottom label strip
                Rectangle {
                    anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                    height: vpx(34)
                    color:  Qt.rgba(0, 0, 0, 0.55)
                    radius: vpx(8)

                    Text {
                        anchors.centerIn: parent
                        text:  modelData.title
                        color: overlay.clrText
                        font.pixelSize: vpx(12)
                    }
                }
            }
        }
    }
}
