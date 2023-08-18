-- Attempts to connect the Scarlett 18i20 to the virtual output devices
-- (Also implements a workaround for jack clients ignoring the default device)

-- Audio channel to which microphone is connected (ex. Analogue 3 --> AUX2)
local mic_input = "AUX2"
local default_nodes = Plugin.find("default-nodes-api")

-- TODO: Ensure a link does not already exist
-- function lookupLink (node1, node2) end

-- Function to create a link
-- NOTE: Links are automatically cleaned up by the factory if either end is disconnected
-- NOTE: We do not connect the same way as policy-node.lua here
-- 		 That method generates and activates a "si-standard-link" type which
-- 		 does not give us control over which ports connect, only which nodes
-- 		 Further, it appears that this saves us from worrying about handling
-- 		 session items versus..."basic pipewire objects" (?)
function createLink (sink_port, source_port)
	if ( not sink_port or not source_port ) then
		Log.warning("routing.lua: Attempted to create link with null port")
		return
	end

	-- TODO: lookupLink()

	id_in = tonumber (sink_port["bound-id"])
	id_out = tonumber (source_port["bound-id"])

	-- print (id_in .. " <- " .. id_out)

	local link = Link ("link-factory", {
		["link.input.port"] = id_in,
		["link.output.port"] = id_out,
		["object.linger"] = true,
	})

	link:activate(Features.ALL)
end

-- Helper function to handle the multiude of playback ports to link
function tryConnectPlayback (device_node)
	local num_ports = device_node:get_n_ports()
	if ( num_ports == 0 ) then
		Log.warning("Scarlett 18i20 node is not ready to link")
		return
	end
	
	-- device_node:lookup_port {}
	for p in device_node:iterate_ports {
		Constraint { "port.direction", "=", "in" },
	} do
		local id = p.properties["port.id"]
		local channel = math.floor(id / 2)
		local target_name = nil

		-- Coming from C, this looks really gross not being a switch but alas
		-- TODO: Consider swapping this to a table, which can be fed as an argument to this script for easy config
		if ( channel == 0 ) then
			target_name = "virtual-games"
		elseif ( channel == 1 ) then
			target_name = "virtual-system"
		elseif ( channel == 2 ) then
			target_name = "virtual-music"
		elseif ( channel == 3 ) then
			target_name = "virtual-voice"
		elseif ( channel == 4 ) then
			target_name = "virtual-stream"
		end

		-- Port should not be linked (ex: AUX17 would hit this)
		if ( target_name == nil ) then
			goto continue
		end

		local target_si = linkables_om:lookup {Constraint { "node.name", "=", target_name }}
		local target_node = target_si:get_associated_proxy("node")
		if ( target_node == nil ) then
			Log.warning("No node found with the name of '" .. target_name .. "', skipping")
			goto continue
		end

		local target_port = target_node:lookup_port {
			Constraint { "port.direction", "=", "out" },
			Constraint { "port.id", "=", math.fmod(id, 2) },
		}
		if ( target_port == nil ) then
			Log.warning("Node '" .. target_name .. "' does not have a suitable port to link")
			goto continue
		end

		createLink(p, target_port)
		::continue::
	end
end

-- links_om = ObjectManager { Interest { type = "SiLink", }}

linkables_om = ObjectManager {
	Interest {
		type = "SiLinkable",
		-- Constraint { "factory.name", "=", "support.null-audio-sink", type = "pw-global" },
		-- Constraint { "node.name", "#", "virtual*" },
		Constraint { "active-features", "!", 0, type = "gobject" },
	}
}

-- linkables_om:connect("object-added", function (om, si)
-- 	Log.warning(dumpTable(si.properties))
-- end)

micport_om = ObjectManager {
	Interest {
		type = "port",
		Constraint { "port.alias", "#", "Scarlett 18i20 USB:capture_" .. mic_input },
	}
}
micport_om:connect("object-added", function (om, micport)
	local target_si = linkables_om:lookup {Constraint { "node.name", "=", "virtual-mic" }}
	local target_node = target_si:get_associated_proxy("node")
	if ( target_node == nil ) then
		Log.warning("Failed to find virtual mic node, skipping")
		return
	end

	for p in target_node:iterate_ports {
		Constraint { "port.direction", "=", "in" },
	} do
		-- Log.warning (p.properties["port.name"])
		createLink(p, micport)
	end
end)

scarlett_om = ObjectManager {
  Interest {
    type = "SiLinkable",
    Constraint { "item.factory.name", "=", "si-audio-adapter", type = "pw-global" },
    Constraint { "item.node.type", "=", "device", type = "pw-global" },
	Constraint { "media.class", "=", "Audio/Sink" },
	Constraint { "node.name", "#", "*Focusrite_Scarlett_18i20_USB*" },
	-- This constraint is what ensures the node's ports are ready
	-- Use 'local node = si:get_associated_proxy ("node")' to get the node object
    Constraint { "active-features", "!", 0, type = "gobject" },
  }
}

scarlett_om:connect("object-added", function (om, si)
	local device_node = si:get_associated_proxy("node")
	tryConnectPlayback(device_node)
end)

jack_om = ObjectManager {
  Interest {
    type = "port",
	-- This appears to be a unique feature to jack devices
	Constraint { "port.name", "#", "channel_*" },
	Constraint { "port.direction", "=", "out" },
  }
}

jack_om:connect("object-added", function (om, port)
	local target_id = default_nodes:call("get-default-node", "Audio/Sink")
	local target_si = linkables_om:lookup {Constraint { "node.id", "=", tostring(target_id) }}
	if ( target_si == nil ) then return end

	local target_node = target_si:get_associated_proxy("node")
	if ( target_node == nil ) then return end

	local target_port = target_node:lookup_port {
		Constraint { "port.direction", "=", "in" },
		Constraint { "port.id", "=", port.properties["port.id"] },
	}
	if ( target_port == nil ) then return end

	createLink(target_port, port)
end)

------------ Helper debugging function ------------
function dumpTable(o)
   if type(o) == 'table' then
      local s = ''
      for k, v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dumpTable(v) .. '\n'
      end
      return s .. '\n'
   else
      return tostring(o)
   end
end
---------------------------------------------------

-- links_om:activate()
linkables_om:activate()
micport_om:activate()
scarlett_om:activate()
jack_om:activate()