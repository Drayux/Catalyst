# Quickshell Configuration

### >>> TODO LIST <<<

- Lock screen! (I found some particularly inspiring ones here: https://github.com/Darkkal44/qylock)
- Status tiles! (Core structure is in place, but lots of functionality yet to add)
    - _Considering what to do with the border color, maybe it changes with the indicator of the icon._
    - _Considering solutions for status icons changing size when I'm going to click on one._
    - Media: Monitor the audio server for volume changes, present a temporary speaker display (OSD equivalent.)
    - Media: Change the volume adjust the server volume, not the stream (which isn't observable or persistent.)
    - Battery: Make sure this only shows up on my laptop lmao.
    - Network: Status at least, not sure what other info I might want to display, yet.
    - Network: Bluetooth as well! Not sure if this should be merged into network or separate just yet.
    - Keyboard: Notably, becomes active if caps lock is on (though might also be handy for input mode switching, for japanese input.)
    - Window Title: Might be nice to have in some capacity! Though it may be best merged when implementing the app menu, noted below.
    - _Stream stats_: Super 'extra' but it might be a cool thing to include for funsies
    - _Overlay mode_: For my rootfs overlay system, I could have an icon pop up depending on what mode I'm in, or how old any given overlay instance is.
- Panels! (These pair with the status buttons)
    - Notifications panel -- let's me view expired notifications (something else appeared before I cleared it)
    - Media panel -- let's me view detailed info about the current stream, as well as all of the available streams. I'd be able to promote an arbitrary one to the top, even if both are playing. Ideally also would include output selection, as this would pair nicely with my wireplumber configuration.
    - _Control panel_ -- These always look so cool on rice showcases, but I don't know what I'd actually put here that couldn't be reflected in a status button directly. (I hate excess multiplicity.)
    - _Calendar_ -- Not as huge on this one, but it would be helpful if, at least, the date and its visual representation popped up when clicking the clock.
- _Global App Menu_ (Would be awesome, but also a ton of work to recreate from KDE, I don't plan on adding this for quite some time, but wanted to write it down.)
- _Other monitors?_ (Still indifferent if I want something on the secondary monitors, but I set up the config during my refactor (mostly, somewhat incomplete) to support all number of configurable display modes, so any handy subset could be displayed on a given monitor. One idea that comes to mind is showing it on my left monitor if my main monitor displaying a full screen window..)

### Definitions
#### Panel

A `panel` is an independent visual shell element. These can be considered the "root" element for any given interface. A `panel` is composed of one or many `components`.

#### Component

A `component` describes an interactive visual element within a panel.

#### Tile

A `tile` is a reusable parameterized building block for `component` layouts.

#### Service

A `service` is a non-visual internal interface for resolving a components interactive state.

### Directory structure
#### <root>

`shell.qml` -- This is the main file of this configuration
`Settings.qml` -- Contains shared style settings for easy tweaking

#### components/

These are completed fragments of the shell, each providing the complete visual and functional elements of any given "section" of the shell. This is accomplished by aggregating sub-components defined within `icons/`, `services/`, and `tiles/` alongside any unique behavior implementation.

#### icons/

Static SVGs used by panel components.

#### services/

Non-visual objects used to encapsulate shell functionality.

#### tiles/

Wrapper for recurring shapes used by panel components.
