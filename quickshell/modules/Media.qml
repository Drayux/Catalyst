// I'm experimenting with this one a bit more. All of the other other
// components I've made separate from each other and used the parent shell
// to handle their position. Here, since the button controls the text in the
// box, I figure it will be easier to handle that relationship if both pieces
// share the same module.

// TODO: Original was a singleton type
// Worth determing if and how to include that

// TODO: Consider a wireplumber integration where the music title text will be
// set to gray if primary output is muted or an output device cannot be found
// ^^ scratch that -- do that with the main music controller button
// (also consider making it into a speaker icon and using it for mute/volume (on scroll))

import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Effects
import QtQuick.VectorImage
import Quickshell.Io // Supplies IpcHandler
import Quickshell.Services.Mpris // Requires mpris USE flag

Rectangle { // media module root container
	id: controller

	// anchors to be set in root (shell.qml)
	color: "transparent"


	// --- HANDLER LOGIC ---

	// Through a chain of git repos, the core was essentially taken from
	// outfoxxed; I've since mutilated it.
	// https://git.outfoxxed.me/outfoxxed/nixnew

	property list<MprisPlayer> players: Mpris.players.values.filter(player => function(p) {
		var exclude = (
			// Exclude anything ending in .mpd except MediaPlayer2.mpd
			(p.dbusName?.endsWith('.mpd') && !p.dbusName.endsWith('MediaPlayer2.mpd'))

			// Players that cannot be controlled (also pause/play even if global control is enabled)
			|| !p.canControl
			|| !p.canPause
			|| !p.canPlay

			// ( other rules can be added here )
		);
		return !exclude;
	});
	property MprisPlayer focusedPlayer;
	property var activeTrack;

	property bool isPlaying: _playerActive(focusedPlayer)
	property bool isMuted: _playerMuted(focusedPlayer)

	// returns true if a given player exists and is playing something
	function _playerActive(_player) {
		return !!_player && ( _player.playbackState === MprisPlaybackState.Playing )
	}

	function _playerMuted(_player) {
		return !!_player && ( _player.volumeSupported && (_player.volume == 0.0))
	}

	// returns true if the given player should be excluded
	function _filterPlayer(_player) {
		return (_player === null)

			// If the player is firefox and there's no artist, it's probably a random tab with audio
			|| (_player.dbusName?.includes(".firefox.") && _player.trackArtist === "")
	}

	// _player should be a ref to the priority player (or null if the fallback should be used)
	function _findBestPlayer(_current, _fallback) {
		const currentExcluded = _filterPlayer(_current)
		if (!currentExcluded && _playerActive(_current)) {
			// Current player is still valid
			return _current
		}

		if (_fallback !== null) {
			if (_filterPlayer(_fallback)) {
				_fallback = null
			}
			else if (_playerActive(_fallback)) {
				// Display the "new" player (usually called if something else starts playing)
				return _fallback
			}
		}
		else {
			// No current or fallback, check if anything is playing
			for (const p of this.players) {
				if (!_filterPlayer(p)) {
					if (_playerActive(p)) {
						return p
					}
					else if (_fallback === null) {
						// while we're looping, find a fallback if necessary
						_fallback = p
					}
				}
			}
		}

		// console.log("Found players:   '" + _current + "   '" + _fallback)
		return (currentExcluded ? null : _current)
			?? _fallback
			?? null
	}

	Component.onCompleted: {
		focusedPlayer = _findBestPlayer(null, null)
	}

	Instantiator {
		model: Mpris.players

		// This logic does two things, it will ignore players based upon certain
		// conditions (for example, firefox likes to consider discord as a song
		// which is really confusing when there's nothing to pause or play.)
		// Thus, this is different than the players property filter above.
		//
		// It also prevents a new player from stomping out one that is already
		// playing. Note that the browser counts as one player depite having
		// support for indefinite "sources." Different tabs on the same browser
		// *do* stomp eachother by the browser's implementation, so this will
		// never be perfect.

		// TODO: I want to add a display for if there exist multiple players
		// just like the expired notifications menu

		Connections {
			required property MprisPlayer modelData
			target: modelData

			// Weird params on the calls to _findBestPlayer() because if
			// focusedPlayer is set, then modelData is the same: no need to
			// filter it twice. Else it's null, and modelData is the only track
			// worth checking, since all the others would *still* be filtered
			// out (they didn't change before this call.)

			function onPlaybackStateChanged() {
				if (focusedPlayer && (modelData !== focusedPlayer)) {
					// TODO: Considering adding a priority system, but that implies
					// that the bar has pause/play logic beyond the mute handling
					// which might not be the right place for this type of thing
					// at the end of the day. (Aka I start watching a movie, so
					// pause any music that's currently playing.)
					return
				}
				// console.log("onPlaybackStateChanged: " + modelData)

				focusedPlayer = _findBestPlayer(focusedPlayer ?? modelData, null)
			}

			// Update track info for the UI component
			function onPostTrackChanged() {
				if (focusedPlayer && (modelData !== focusedPlayer)) {
					return
				}
				// console.log("onPostTrackChanged: " + modelData)

				// Check filter every time the track changes
				controller.focusedPlayer = controller._findBestPlayer(focusedPlayer ?? modelData, null)
				controller.activeTrack = {
					uniqueId: focusedPlayer?.uniqueId ?? 0,
					artUrl: focusedPlayer?.trackArtUrl ?? "",
					title: focusedPlayer?.trackTitle || "Unknown Title",
					artist: focusedPlayer?.trackArtist || "Unknown Artist",
					album: focusedPlayer?.trackAlbum || "Unknown Album",
				};
			}
		}
	}

	function togglePlaying() {
		var pl = this.focusedPlayer;
		if (!pl || !pl.canTogglePlaying) {
			return;
		}
		if (this.isMuted && !this.isPlaying) {
			// don't resume playing if muted
			return;
		}

		pl.togglePlaying();
	}
	function previous() {
		if (this.focusedPlayer?.canGoPrev) {
			this.focusedPlayer.previous();
		}
	}
	function next() {
		if (this.focusedPlayer?.canGoNext) {
			this.focusedPlayer.next();
		}
	}
	function setLoop(_loop: var) {
		if (!this.focusedPlayer) {
			return;
		}

		if (this.focusedPlayer.loopSupported && this.focusedPlayer.canControl) {
			this.focusedPlayer.loopState = _loop;
		}
	}
	function setShuffle(_shuffle: bool) {
		if (!this.focusedPlayer) {
			return;
		}

		if (this.focusedPlayer.shuffleSupported && this.focusedPlayer.canControl) {
			this.focusedPlayer.shuffle = _shuffle;
		}
	}
	// Old version, set volume directly (commented because nothing uses this right now)
	// function setVolume(_volume: real) {
		// if (!this.focusedPlayer) {
			// return;
		// }

		// if (_volume > 1.0 || _volume < 0.0) {
			// console.warn("Player volume " + _volume + " outside of the range [0.0, 1.0]");
			// return;
		// }

		// if (this.focusedPlayer.volumeSupported && this.focusedPlayer.canControl) {
			// console.log("Current volume: " + this.focusedPlayer.volume);
			// this.focusedPlayer.volume = _volume;
		// }
	// }
	function adjustVolume(_offset: real) {
		var pl = this.focusedPlayer;
		if (!pl || !pl.volumeSupported || !pl.canControl) {
			return;
		}

		var _volume = pl.volume + _offset;

		if (_volume > 0.998) {
			_volume = 1.0;
		}
		else if (_volume < 0.001) {
			_volume = 0.0;
		}

		// Pause the player if it's going to be muted
		if (_volume == 0.0 && pl.volume > 0 && pl.canPause) {
			pl.pause();
		}

		console.log("setting volume to: " + _volume);
		pl.volume = _volume;
	}
	// --- //


	Rectangle { // media status toast -- full object (song name, etc.)
		id: media_status

		anchors.bottom: parent.bottom
		anchors.bottomMargin: -root.barBorder
		anchors.left: media_controller.right

		// same as in Toast.qml (roughly) (extra 28 is for artist padding)
		readonly property int totalBarWidth: media_status_name.width + media_status_artist.width
		// width: ((totalBarWidth > 64) ? totalBarWidth : 64) + 12
		width: (totalBarWidth > 0) ? totalBarWidth + 34 + 28 + 14 : 20
		height: parent.height / 1.2
		clip: true

		color: "transparent"

		Behavior on width {
			PropertyAnimation {
				duration: 350
				easing.amplitude: 2.0
				easing.type: Easing.InOutQuart
			}
		}

		Rectangle { // background
			id: media_info_box
			width: parent.width - 12 // 12 is for clipping offset
			height: parent.height + root.barBorder

			antialiasing: true
			transform: Shear {
				xAngle: 24
			}
			// topRightRadius: 10

			color: "#121221"
			// opacity: 0.66667
			opacity: 0.50
		}
		Text { // status text
			id: media_status_name

			anchors.left: media_status_artist_bg.right
			anchors.leftMargin: 20
			anchors.verticalCenter: parent.verticalCenter
			anchors.verticalCenterOffset: root.barBorder / (-2)

			text: controller.focusedPlayer !== null ?
				controller.focusedPlayer.trackTitle : ""
			textFormat: Text.PlainText

			// TODO: This is slightly bugged. The volume value will be whatever
			// we last set it to, even if that was on a different player.
			// Essentially, mute one player, swap to another that isn't muted,
			// play/pause to set it active, and then the title will be gray
			// when it should be pink. Unfortunately this appears to be a bug
			// with the Quickshell Mpris implementation.
			//
			// I think a workaround to force isMuted to false when the player
			// is swapped would then fail to detect if the new player was
			// already muted, but I could stand to test this.
			color: controller.isPlaying ? "#93cee9"
				: (controller.isMuted ? "#3F395D" : "#d4a1e7")
			font {
				family: "JetBrainsMono Nerd Font"
				pixelSize: parent.height / 2
				weight: 400
				letterSpacing: -0.65
			}

			// TODO: attempt at animation (refer to Toast.qml)
			Behavior on color {
				PropertyAnimation {
					duration: 350
					easing.amplitude: 2.0
					easing.type: Easing.InOutQuart
				}
			}
		}

		Rectangle { // artist accent BG slice
			id: media_status_artist_bg
			anchors {
				top: parent.top
				bottom: parent.bottom
				left: parent.left
				leftMargin: 4
			}
			width: media_status_artist.width + 14 * 2 + 1
			antialiasing: true
			transform: Shear {
				xAngle: 24
			}

			color: "#3F395D"
		}
		Text {
			id: media_status_artist
			anchors {
				verticalCenter: parent.verticalCenter
				verticalCenterOffset: root.barBorder / (-2)
				left: media_status_artist_bg.left
				leftMargin: 20
			}

			text: controller.focusedPlayer !== null ?
				controller.focusedPlayer.trackArtists : ""
			textFormat: Text.PlainText

			color: "#d4a1e7"
			font {
				family: "JetBrainsMono Nerd Font"
				pixelSize: parent.height / 2.8
				weight: 300
				letterSpacing: -0.25
			}
		}

		Rectangle { // border
			width: media_info_box.width
			height: media_info_box.height

			color: "transparent"

			antialiasing: true
			transform: Shear {
				xAngle: 24
			}
			border.pixelAligned: false
			border.color: "#3F395D" // Niri is "#393552" try to visually match
			border.width: root.barBorder
			// topRightRadius: 10

			// TODO: Consider moving me! I might want the artist to be a separate button
			MouseArea {
				anchors.fill: parent
				cursorShape: this.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

				onClicked: {
					controller.togglePlaying();
				}
			}
		}
	}

	Rectangle { // available players chip button
		id: players_icon

		readonly property bool active: controller.players.length > 0

		anchors.left: media_status.right
		anchors.leftMargin: -14
		anchors.bottom: media_status.bottom

		height: media_status.height
		width: 37 // hard code for icon for now
		antialiasing: true
		transform: Shear {
			xAngle: 24
		}
		topRightRadius: 10 // needs to match the border above

		color: "#3F395D"

		MouseArea {
			anchors.fill: parent
			enabled: players_icon.active
			cursorShape: this.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

			onClicked: {
				players_list_root.visible = !players_list_root.visible
			}
		}
	}
	VectorImage { // players (speaker) icon itself
		anchors.centerIn: players_icon
		anchors.verticalCenterOffset: -2
		anchors.horizontalCenterOffset: 4

		source: "../icons/sources.svg"
		width: parent.height - 16
		height: parent.height - 16
		preferredRendererType: VectorImage.CurveRenderer

		layer.enabled: true
		layer.effect: MultiEffect {
			brightness: 1.0
			colorization: 1.0
			colorizationColor: players_icon.active ? "#d4a1e7" : "#817c9c"
		}
	}

	Rectangle { // media controller button 
		id: media_controller

		width: parent.height + 19
		height: parent.height

		color: "transparent"

		Rectangle {
			width: parent.width
			height: parent.height + root.barBorder
			y: -root.barBorder
			antialiasing: true
			transform: Shear {
				xAngle: 24
			}

			color: "#121221"

			border.pixelAligned: false
			border.color: "#3F395D" // Niri is "#393552" try to visually match
			border.width: root.barBorder
			topRightRadius: 5
			bottomLeftRadius: 5

			MouseArea {
				anchors.fill: parent
				cursorShape: Qt.PointingHandCursor
				acceptedButtons: Qt.LeftButton | Qt.MiddleButton
				onClicked: (event) => {
					if (event.button == Qt.LeftButton) {
						console.log("todo not sure what to do with this one yet, maybe the output device?");
					}
					else {
						// Middle click action -- "see more" (here, bring the player to attention)
						controller.focusedPlayer?.raise();
					}
				}
				onWheel: (event) => {
					if (event.angleDelta.y > 0) {
						// scroll up
						controller.adjustVolume(0.1);
					}
					else if (event.angleDelta.y < 0) {
						// scroll down
						controller.adjustVolume(-0.1);
					}
				}
			}
		}

		VectorImage {
			// because of the slant, hard coding the center seemed the easier option
			x: 25
			y: 6

			source: "../icons/music.svg"
			width: parent.height - 16
			height: parent.height - 16
			preferredRendererType: VectorImage.CurveRenderer

			layer.enabled: true
			layer.effect: MultiEffect {
				brightness: 1.0
				colorization: 1.0
				colorizationColor: "#93cee9"
			}
		}
	}

	PanelWindow {
        id: players_list_root
        visible: false

		anchors {
			left: true
			top: true
			bottom: true
		}
		
		margins {
			left: root.margins.left
			top: 12
			bottom: 12
		}

		implicitWidth: visible ? 800 : 0

		// TODO: Indifferent if I want this as Auto or Normal
		// It looks really crispy with normal, but the WM gets a bit weird
		// about reserving the space
		exclusionMode: ExclusionMode.Normal
		aboveWindows: WlrLayer.Overlay
		// keyboardFocus: WlrKeyboardFocus.Exclusive

        color: "transparent"
		surfaceFormat.opaque: false

        Rectangle {
            id: players_list
            radius: 16

			width: parent.width
			// width: 500
			height: 300
			Behavior on width {
				PropertyAnimation {
					duration: 350
					easing.amplitude: 2.0
					easing.type: Easing.InOutQuart
				}
			}

            color: "#CC1e1e"

            // implicitHeight bubbles up from the Column's content
            // implicitHeight: column.implicitHeight + 24

            // Column {
                // id: column
                // anchors {
                    // top: parent.top
                    // left: parent.left
                    // right: parent.right
                    // margins: 12
                // }
                // spacing: 8

                // Repeater {
                    // mprisState.players is your pre-filtered list
                    // model: mprisState.players

                    // delegate: Rectangle {
                        // modelData is the MprisPlayer instance for this entry
                        // required property var modelData

                        // width: parent.width
                        // height: 48
                        // color: modelData === mprisState.activePlayer
                            // ? "#44cdd6f4"   // highlight the active player
                            // : "#331e1e2e"
                        // radius: 6

                        // Text {
                            // anchors.centerIn: parent
                            // text: modelData.identity   // the player's app name
                            // color: "#cdd6f4"
                            // font.pixelSize: 14
                            // textFormat: Text.PlainText
                        // }
                    // }
                // }
            // }
        }
	}
}
