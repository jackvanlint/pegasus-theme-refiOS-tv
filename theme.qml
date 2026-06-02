import QtQuick 2.15
import QtGraphicalEffects 1.12

FocusScope {
    id: root
    focus: true

    FontLoader { id: fontLight; source: "assets/fonts/Roboto-Light.ttf" }

    // ── Palette ───────────────────────────────────────────────────────
    readonly property color clrBg:    "#0B0810"
    readonly property color clrCard:  "#1A1120"
    readonly property color clrRose:  "#C48BAA"
    readonly property color clrMauve: "#9D6E8A"
    readonly property color clrText:  "#EDD6E8"
    readonly property color clrMuted: "#9A7A92"

    // ── Tile geometry ─────────────────────────────────────────────────
    readonly property int tileW:   vpx(200)
    readonly property int tileH:   vpx(120)
    readonly property int tileGap: vpx(14)

    // ── Collections ───────────────────────────────────────────────────
    readonly property var mainColl: {
        for (var i = 0; i < api.collections.count; i++)
            if (api.collections.get(i).name === "Apps") return api.collections.get(i)
        return api.collections.count > 0 ? api.collections.get(0) : null
    }
    readonly property var availColl: {
        for (var i = 0; i < api.collections.count; i++)
            if (api.collections.get(i).name === "Available") return api.collections.get(i)
        return null
    }

    // ── Background ────────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        color: root.clrBg
    }

    // ── Banner area ───────────────────────────────────────────────────
    Item {
        id: bannerArea
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: parent.height - vpx(190)
        clip: true

        // Previous banner (stays visible while next loads)
        Image {
            id: bannerPrev
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            smooth: true
            cache: true
        }
        // Next banner fades in when ready
        Image {
            id: bannerNext
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            smooth: true
            asynchronous: true
            opacity: 0
            cache: true

            onStatusChanged: {
                if (status === Image.Ready) {
                    opacityAnim.running = true
                } else if (status === Image.Error) {
                    opacity = 0
                }
            }

            NumberAnimation on opacity {
                id: opacityAnim
                to: 1; duration: 380
                easing.type: Easing.OutCubic
                running: false
                onStopped: {
                    bannerPrev.source = bannerNext.source
                    bannerNext.opacity = 0
                }
            }
        }

        // Solid fallback behind banners
        Rectangle {
            anchors.fill: parent
            color: root.clrCard
            z: -1
        }

        // Bottom gradient into bg colour
        Rectangle {
            anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
            height: vpx(300)
            z: 2
            gradient: Gradient {
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 1.0; color: root.clrBg }
            }
        }

        // App name
        Text {
            id: titleText
            anchors {
                left: parent.left; leftMargin: vpx(80)
                bottom: parent.bottom; bottomMargin: vpx(40)
            }
            z: 3
            color: root.clrText
            font { family: fontLight.name; pixelSize: vpx(42) }
        }
    }

    // ── App row ───────────────────────────────────────────────────────
    PathView {
        id: appRow
        anchors {
            bottom: parent.bottom; bottomMargin: vpx(36)
            left: parent.left; right: parent.right
        }
        height: root.tileH + vpx(36)
        clip: false
        focus: true

        model: mainColl ? mainColl.games : null

        readonly property int stepW: root.tileW + root.tileGap
        readonly property int numVisible: 16
        pathItemCount: model ? Math.min(numVisible, model.count) : 0

        readonly property real trackW: pathItemCount * stepW
        readonly property real px0: vpx(80) - stepW * 2.5

        path: Path {
            startX: appRow.px0
            startY: root.tileH * 0.5 + vpx(18)
            PathLine { x: appRow.px0 + appRow.trackW; y: appRow.path.startY }
        }

        snapMode:           PathView.SnapOneItem
        highlightRangeMode: PathView.StrictlyEnforceRange

        preferredHighlightBegin: {
            if (!model || model.count < numVisible || trackW === 0) return 0
            return (stepW * 2.5) / trackW
        }
        preferredHighlightEnd: preferredHighlightBegin

        onCurrentIndexChanged: {
            if (!model || currentIndex < 0 || currentIndex >= model.count) return
            var g = model.get(currentIndex)
            if (!g) return
            if (g.title === "Add app") {
                titleText.text = "Add App"
                bannerNext.source = ""
                bannerPrev.source = ""
            } else {
                titleText.text = g.title
                var slug = g.title.toLowerCase().replace(/ /g, "-")
                bannerNext.source = "assets/banners/" + slug + ".jpg"
            }
        }

        Keys.onLeftPressed:  decrementCurrentIndex()
        Keys.onRightPressed: incrementCurrentIndex()
        Keys.onPressed: {
            if (event.isAutoRepeat) return
            if (api.keys.isAccept(event)) {
                var g = model.get(currentIndex)
                if (!g) return
                if (g.title === "Add app") {
                    browser.visible = true
                    browser.forceActiveFocus()
                } else {
                    g.launch()
                }
                event.accepted = true
            }
        }

        delegate: AppTile {
            game:      modelData
            isCurrent: PathView.isCurrentItem
            tileW:     root.tileW
            tileH:     root.tileH
            clrCard:   root.clrCard
            clrRose:   root.clrRose
            clrText:   root.clrText
        }
    }

    // ── App browser overlay ───────────────────────────────────────────
    AppBrowserOverlay {
        id: browser
        anchors.fill: parent
        visible: false
        availColl: root.availColl
        clrBg:    root.clrBg
        clrCard:  root.clrCard
        clrRose:  root.clrRose
        clrMauve: root.clrMauve
        clrText:  root.clrText
        clrMuted: root.clrMuted
        onClosed: {
            visible = false
            appRow.forceActiveFocus()
        }
    }
}
