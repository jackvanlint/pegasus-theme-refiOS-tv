// Pegasus Frontend — refiOS-tv (forked from refiOS / Flixnet by Mátyás Mustoha, eleo95)
// Customised for a CachyOS mini PC TV launcher: hero + single unlabelled row + pinnable app.
//
// Layout:
//   ┌─────────────────────────────────────┐
//   │                                     │
//   │            HERO (pinned)            │   ~55% of screen height
//   │                                     │
//   ├─────────────────────────────────────┤
//   │ ▣  ▣  ▣  ▣  ▣  ▣  +                │   single unlabelled row
//   └─────────────────────────────────────┘
//
// Pin state lives in pegasus-frontend.conf (Qt.labs.settings), category "tvLauncher".
// Long-press the hero (≥600 ms) to open the pin picker.
// The "+" tile is a synthetic entry in metadata.pegasus.txt called "Add app";
// its launch command runs the yad picker that adds detected apps.

import QtQuick 2.7
import QtGraphicalEffects 1.12
import Qt.labs.settings 1.0


FocusScope {
    focus: true
    FontLoader { id: roboto_light; source: "assets/fonts/Roboto-Light.ttf" }
    FontLoader { id: roboto_thin; source: "assets/fonts/Roboto-Thin.ttf" }

    // ── persistent state ─────────────────────────────────────────────────
    Settings {
        id: tvSettings
        category: "tvLauncher"
        property string pinnedAppTitle: ""
    }

    // ── layout constants ─────────────────────────────────────────────────
    readonly property real cellRatio: 16 / 9
    readonly property int cellHeight: vpx(130)
    readonly property int cellWidth: cellHeight * cellRatio
    readonly property int cellSpacing: vpx(10)
    readonly property int cellPaddedWidth: cellWidth + cellSpacing
    readonly property int leftGuideline: vpx(100)

    // ── pinned-app lookup ───────────────────────────────────────────────
    // Source of truth: api.collections.get(0).games (the only collection: "Apps").
    // Falls back to the first non-"Add app" entry when no pin is set or the pinned title is gone.
    readonly property var appsCollection: api.collections.count > 0 ? api.collections.get(0) : null
    readonly property var pinnedGame: {
        if (!appsCollection) return null
        var games = appsCollection.games
        for (var i = 0; i < games.count; ++i) {
            var g = games.get(i)
            if (g.title === tvSettings.pinnedAppTitle && g.title !== "Add app") return g
        }
        // fallback: first real app
        for (var j = 0; j < games.count; ++j) {
            var g2 = games.get(j)
            if (g2.title !== "Add app") return g2
        }
        return null
    }

    // ── background ──────────────────────────────────────────────────────
    Rectangle {
        id: bg
        anchors.fill: parent

        // ────────────────────────────────────────────────────────────────
        // BACKGROUND IMAGE — to use a wallpaper instead of the gradient:
        //   1. Drop your image into themes/refiOS-tv/assets/background.jpg
        //   2. Uncomment the Image + Rectangle block below
        //   3. Comment out the RadialGradient below
        //
        // Image {
        //     anchors.fill: parent
        //     source: "assets/background.jpg"
        //     fillMode: Image.PreserveAspectCrop
        //     asynchronous: true
        // }
        // Rectangle {
        //     anchors.fill: parent
        //     color: "#000"
        //     opacity: 0.55
        // }
        // ────────────────────────────────────────────────────────────────

        RadialGradient {
            anchors.fill: parent
            horizontalOffset: vpx(-450)
            verticalOffset: vpx(-250)
            gradient: Gradient {
                GradientStop { position: 0.1; color: "#051720" }
                GradientStop { position: 0.5; color: "#07131d" }
                GradientStop { position: 1; color: "#00050f" }
            }
        }

        // ── hero ────────────────────────────────────────────────────────
        HeroSection {
            id: hero
            game: pinnedGame
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }
            height: parent.height * 0.55
            onLongPress: appPicker.visible = true
            onActivated: if (game) game.launch()
        }

        // ── single horizontal row of apps ───────────────────────────────
        PathView {
            id: appAxis
            width: parent.width
            height: cellHeight * 1.4
            anchors.bottom: parent.bottom
            anchors.bottomMargin: vpx(40)

            model: appsCollection ? appsCollection.games : null
            delegate: GameAxisCell {
                game: modelData
                width: cellWidth * 0.98
                height: cellHeight * 0.78
                selected: PathView.isCurrentItem
                selectedRow: row.activeFocus
            }

            readonly property int maxItemCount: 2 + Math.ceil(width / cellPaddedWidth)
            pathItemCount: model ? Math.min(maxItemCount, model.count) : 0

            property int fullPathWidth: pathItemCount * cellPaddedWidth
            path: Path {
                startX: (appAxis.model && appAxis.model.count >= appAxis.maxItemCount)
                    ? leftGuideline - cellPaddedWidth * 1.5
                    : leftGuideline + (cellPaddedWidth * 0.5 - cellSpacing * 0.5)
                startY: cellHeight * 0.5
                PathLine {
                    x: appAxis.path.startX + appAxis.fullPathWidth
                    y: appAxis.path.startY
                }
            }

            snapMode: PathView.SnapOneItem
            highlightRangeMode: PathView.StrictlyEnforceRange
            clip: true

            preferredHighlightBegin: (model && model.count >= maxItemCount)
                ? (2 * cellPaddedWidth - cellSpacing / 2) / fullPathWidth
                : 0
            preferredHighlightEnd: preferredHighlightBegin
        }

        // ── focus router ────────────────────────────────────────────────
        // Up arrow / hover top: hero focus. Down / hover bottom: row focus.
        // Default focus: hero (so a fresh boot highlights the pinned app).
        Item {
            id: row
            anchors.fill: appAxis
            focus: !hero.activeFocus
            Keys.onLeftPressed: appAxis.decrementCurrentIndex()
            Keys.onRightPressed: appAxis.incrementCurrentIndex()
            Keys.onUpPressed: hero.focus = true
            Keys.onPressed: {
                if (!event.isAutoRepeat && api.keys.isAccept(event)) {
                    if (appAxis.model && appAxis.currentIndex >= 0) {
                        var g = appAxis.model.get(appAxis.currentIndex)
                        if (g) g.launch()
                    }
                }
            }
        }

        Keys.onDownPressed: row.focus = true
    }

    // ── pin picker overlay ──────────────────────────────────────────────
    AppPickerOverlay {
        id: appPicker
        anchors.fill: parent
        visible: false
        model: appsCollection ? appsCollection.games : null
        onPicked: {
            tvSettings.pinnedAppTitle = title
            visible = false
        }
        onDismissed: visible = false
    }
}
