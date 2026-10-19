pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io // IpcHandler component
import Quickshell.Services.Mpris // Requires mpris USE flag

Singleton {
	id: service_Media

	// Through a chain of git repos, this was essentially taken from
	// https://git.outfoxxed.me/outfoxxed/nixnew; I've since mutilated it.

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
				service_Media.focusedPlayer = service_Media._findBestPlayer(focusedPlayer ?? modelData, null)
				service_Media.activeTrack = {
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
}
