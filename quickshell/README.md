# Quickshell Configuration

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
