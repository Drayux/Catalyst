-- https://gitlab.freedesktop.org/pipewire/pipewire/-/wikis/Config-Devices
-- https://pipewire.pages.freedesktop.org/wireplumber/configuration/alsa.html


local rule = {
	matches = {
		{
			{ "device.name", "matches", "alsa_card.usb-Focusrite_Scarlett_18i20_USB_*" },
		},
	},
	apply_properties = {
		["api.acp.probe-rate"] = 96000,

		-- THE FOLLOWING PARAMETERS ARE PROVIDED AS AN EXAMPLE, SEE:
		-- https://gitlab.freedesktop.org/pipewire/wireplumber/-/blob/master/src/config/main.lua.d/50-alsa-config.lua

		["node.nick"]              = "Scarlett 18i20",
		-- ["node.description"]       = "My Node Description",
		-- ["priority.driver"]        = 100,
		-- ["priority.session"]       = 100,
		-- ["node.pause-on-idle"]     = false,
		-- ["monitor.channel-volumes"] = false
		-- ["resample.quality"]       = 4,
		-- ["resample.disable"]       = false,
		-- ["channelmix.normalize"]   = false,
		-- ["channelmix.mix-lfe"]     = false,
		-- ["channelmix.upmix"]       = true,
		-- ["channelmix.upmix-method"] = "psd",  -- "none" or "simple"
		-- ["channelmix.lfe-cutoff"]  = 150,
		-- ["channelmix.fc-cutoff"]   = 12000,
		-- ["channelmix.rear-delay"]  = 12.0,
		-- ["channelmix.stereo-widen"] = 0.0,
		-- ["channelmix.hilbert-taps"] = 0,
		-- ["channelmix.disable"]     = false,
		-- ["dither.noise"]           = 0,
		-- ["dither.method"]          = "none",  -- "rectangular", "triangular" or "shaped5"
		-- ["audio.channels"]         = 10,
		-- ["audio.format"]           = "S16LE",
		-- ["audio.rate"]             = 96000,
		-- ["audio.allowed-rates"]    = "44100,48000,88200,96000,176400,192000",
		-- ["audio.allowed-rates"]		 = "192000",
		-- ["audio.position"]         = "AUX0,AUX1,AUX2,AUX3,AUX4,AUX5,AUX6,AUX7,AUX8,AUX9",
		-- ["api.alsa.period-size"]   = 1024,
		-- ["api.alsa.period-num"]    = 2,
		-- ["api.alsa.headroom"]      = 0,
		-- ["api.alsa.start-delay"]   = 0,
		-- ["api.alsa.disable-mmap"]  = false,
		-- ["api.alsa.disable-batch"] = false,
		-- ["api.alsa.use-chmap"]     = false,
		-- ["api.alsa.multirate"]     = true,
		-- ["latency.internal.rate"]  = 0
		-- ["latency.internal.ns"]    = 0
		-- ["clock.name"]             = "api.alsa.0"
		-- ["session.suspend-timeout-seconds"] = 5,  -- 0 disables suspend
	},
}

table.insert(alsa_monitor.rules, rule)
