// Hero section — large logo of the pinned app, long-press to open the pin picker.

import QtQuick 2.7
import QtGraphicalEffects 1.12

FocusScope {
    id: root
    property var game
    property int longPressMs: 600

    signal longPress()
    signal activated()

    focus: true

    // selected-row outline (subtle)
    Rectangle {
        anchors.centerIn: logo
        width: logo.paintedWidth + vpx(40)
        height: logo.paintedHeight + vpx(40)
        color: "white"
        opacity: root.activeFocus ? 0.08 : 0
        radius: vpx(8)
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: 150 } }
    }

    Image {
        id: logo
        anchors.centerIn: parent
        width: parent.width * 0.55
        height: parent.height * 0.65
        fillMode: Image.PreserveAspectFit
        smooth: true
        asynchronous: true
        source: root.game && root.game.assets && root.game.assets.logo ? root.game.assets.logo : ""
        visible: source != ""
        sourceSize { width: 1024; height: 1024 }
    }

    // fallback when no logo exists
    Text {
        anchors.centerIn: parent
        visible: !logo.visible && root.game
        text: root.game ? root.game.title : ""
        color: "white"
        font {
            pixelSize: vpx(72)
            family: globalFonts.sans
        }
    }

    Text {
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: vpx(20)
        }
        visible: !root.game
        text: "No apps yet — use + to add"
        color: "#888"
        font {
            pixelSize: vpx(20)
            family: globalFonts.sans
        }
    }

    Timer {
        id: pressTimer
        interval: root.longPressMs
        repeat: false
        onTriggered: root.longPress()
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        onPressed: pressTimer.start()
        onReleased: {
            var wasLong = !pressTimer.running
            pressTimer.stop()
            if (!wasLong) root.activated()
        }
        onCanceled: pressTimer.stop()
        onExited: pressTimer.stop()
        hoverEnabled: true
        onEntered: root.focus = true
    }

    Keys.onPressed: {
        if (!event.isAutoRepeat && api.keys.isAccept(event)) {
            root.activated()
            event.accepted = true
        }
    }
}
