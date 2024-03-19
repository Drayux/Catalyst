-- OVERRIDE OF /usr/share/wireplumber/main.lua.d/50-alsa-config.lua
-- Modified functionality: 
--    Disable MIDI functionality (No reason other than it not currently being in use)
--    Add specific configuration rules for the Focusrite 18i20

alsa_monitor.enabled = true

alsa_monitor.properties = {
  -- Create a JACK device. This is not enabled by default because
  -- it requires that the PipeWire JACK replacement libraries are
  -- not used by the session manager, in order to be able to
  -- connect to the real JACK server.
  --["alsa.jack-device"] = false,

  -- Reserve devices via org.freedesktop.ReserveDevice1 on D-Bus
  -- Disable if you are running a system-wide instance, which
  -- doesn't have access to the D-Bus user session
  ["alsa.reserve"] = true,
  --["alsa.reserve.priority"] = -20,
  --["alsa.reserve.application-name"] = "WirePlumber",

  -- Enables MIDI functionality
  ["alsa.midi"] = false,

  -- Enables monitoring of alsa MIDI devices
  ["alsa.midi.monitoring"] = true,

  -- MIDI bridge node properties
  ["alsa.midi.node-properties"] = {
    -- Name set for the node with ALSA MIDI ports
    ["node.name"] = "Midi-Bridge",
    -- Removes longname/number from MIDI port names
    --["api.alsa.disable-longname"] = true,
  },

  -- These properties override node defaults when running in a virtual machine.
  -- The rules below still override those.
  ["vm.node.defaults"] = {
    ["api.alsa.period-size"] = 256,
    ["api.alsa.headroom"] = 8192,
  },
}

alsa_monitor.rules = {
  --{
  --  matches = {
  --    {
  --      { "device.name", "matches", "name_of_some_disabled_card" },
  --    },
  --  },
  --  apply_properties = {
  --    ["device.disabled"] = true,
  --  },
  --}
  {
    matches = {
      {
        { "device.name", "matches", "alsa_card.*" },
      },
    },
    apply_properties = {
      -- Use ALSA-Card-Profile devices. They use UCM or the profile
      -- configuration to configure the device and mixer settings.
      ["api.alsa.use-acp"] = true,

      -- Use UCM instead of profile when available. Can be
      -- disabled to skip trying to use the UCM profile.
      --["api.alsa.use-ucm"] = true,

      -- Don't use the hardware mixer for volume control. It
      -- will only use software volume. The mixer is still used
      -- to mute unused paths based on the selected port.
      --["api.alsa.soft-mixer"] = false,

      -- Ignore decibel settings of the driver. Can be used to
      -- work around buggy drivers that report wrong values.
      --["api.alsa.ignore-dB"] = false,

      -- The profile set to use for the device. Usually this is
      -- "default.conf" but can be changed with a udev rule or here.
      --["device.profile-set"] = "profileset-name",

      -- The default active profile. Is by default set to "Off".
      --["device.profile"] = "default profile name",

      -- Automatically select the best profile. This is the
      -- highest priority available profile. This is disabled
      -- here and instead implemented in the session manager
      -- where it can save and load previous preferences.
      ["api.acp.auto-profile"] = false,

      -- Automatically switch to the highest priority available port.
      -- This is disabled here and implemented in the session manager instead.
      ["api.acp.auto-port"] = false,

      -- Other properties can be set here.
      --["device.nick"] = "My Device",
    },
  },
  {
    matches = {
      {
        { "device.name", "matches", "*Focusrite_Scarlett_18i20*" },
      },
    },
    apply_properties = {
      ["node.nick"]              = "Scarlett 18i20",
      --["node.description"]       = "My Node Description",
      --["priority.driver"]        = 100,
      --["priority.session"]       = 100,
      --["node.pause-on-idle"]     = false,
      --["monitor.channel-volumes"] = false
      --["resample.quality"]       = 4,
      --["resample.disable"]       = false,
      --["channelmix.normalize"]   = false,
      --["channelmix.mix-lfe"]     = false,
      --["channelmix.upmix"]       = true,
      --["channelmix.upmix-method"] = "psd",  -- "none" or "simple"
      --["channelmix.lfe-cutoff"]  = 150,
      --["channelmix.fc-cutoff"]   = 12000,
      --["channelmix.rear-delay"]  = 12.0,
      --["channelmix.stereo-widen"] = 0.0,
      --["channelmix.hilbert-taps"] = 0,
      --["channelmix.disable"]     = false,
      --["dither.noise"]           = 0,
      --["dither.method"]          = "none",  -- "rectangular", "triangular" or "shaped5"
      ["audio.channels"]         = 10,
      --["audio.format"]           = "S16LE",
      ["audio.rate"]             = 192000,
      ["audio.allowed-rates"]    = "44100,48000,88200,96000,176400,192000",
      --["audio.position"]         = "FL,FR",
      --["api.alsa.period-size"]   = 1024,
      --["api.alsa.period-num"]    = 2,
      --["api.alsa.headroom"]      = 0,
      --["api.alsa.start-delay"]   = 0,
      --["api.alsa.disable-mmap"]  = false,
      --["api.alsa.disable-batch"] = false,
      --["api.alsa.use-chmap"]     = false,
      --["api.alsa.multirate"]     = true,
      --["latency.internal.rate"]  = 0
      --["latency.internal.ns"]    = 0
      --["clock.name"]             = "api.alsa.0"
      --["session.suspend-timeout-seconds"] = 5,  -- 0 disables suspend
    },
  },
  -- {
  --   matches = {
  --     {
  --       -- Matches all sources.
  --       { "node.name", "matches", "alsa_input.*" },
  --     },
  --     {
  --       -- Matches all sinks.
  --       { "node.name", "matches", "alsa_output.*" },
  --     },
  --   },
  -- },
}
