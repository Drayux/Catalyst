-- Handle routing of various applications to their respective output channels

-- <Default> -> AUX0 / AUX1 : (Primarily games)
-- System Audio [system.lua] -> (1) AUX2 / AUX3 : (Includes web browsers)
-- Music Players [music.lua] -> (2) AUX4 / AUX5 : (Cider, Spotify, etc.)
-- Communication [voice.lua] -> (3) AUX6 / AUX7 : (Discord, Teams, etc.)
-- Stream Audio [stream.lua] -> (4) AUX8 / AUX9 : (OBS <- Browser sources)

-----------------------------------------------------------------------------

-- Channel name for mic input (i.e. input 3 on the interface is AUX2 internally)
local mic_input = "AUX2"

local route_map  = {
	-- System Audio
	[1] = {
		"firefox",
	},

	-- Music Players
	[2] = {
		"cider",
	},

	-- Communication Applications
	[3] = {
		"Discord",
	},

	-- Stream Audio
	[4] = {
		"obs",
	},
}

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------

-- Object manager for the 18i20 (this OM should have a maximum of one entry)
-- (Available constraints are any entries in object["global-properties"])
-- Use this to retrieve the desired sink ports (link input side)
dev = ObjectManager {
	Interest {
		type = "node",
		Constraint { "node.name", "matches", "*Focusrite_Scarlett_18i20_USB*" },
		Constraint { "media.class", "matches", "Audio/Sink" },
	}
}

-- Object manager for the virtual mic
-- If I can find a "global object manager" I should be able to replace this and dev with a simple GLOBOM:lookup(interest)
virt = ObjectManager {
	Interest {
		type = "port",
		Constraint { "object.path", "matches", "virtual-source:input*" },
	}
}

-- All output stream nodes
streams = ObjectManager {
	Interest {
		type = "node",
		Constraint { "media.class", "matches", "Stream/Output/Audio" },
	}
}

-- All output ports
-- New objects here will attempt to be connected to the 18i20 via the executable table
ports = ObjectManager {
	Interest {
		type = "port",
		Constraint { "port.direction", "equals", "out" },
		Constraint { "port.physical", "not-equals", "true" },
		Constraint { "port.monitor", "not-equals", "true" },
	}	
}

-- Microphone port
-- This should only contain one object
mic = ObjectManager {
	Interest {
		type = "port",
		Constraint { "port.alias", "matches", "Scarlett 18i20 USB:capture_" .. mic_input }
	}
}

-- Function to create a link
-- NOTE: Links are automatically cleaned up by the factory if either end is disconnected
local function create_link (sink_port, source_port)
	if ( not sink_port or not source_port ) then
		Log.warning("routing.lua: Attempted to create link with null port")
		return
	end

	id_in = tonumber (sink_port["bound-id"])
	id_out = tonumber (source_port["bound-id"])

	-- print (id_in .. " <- " .. id_out)

	-- This needs to be referenced or it will be garbage-collected by the interpreter
	local link = Link ("link-factory", {
		["link.input.port"] = id_in,
		["link.output.port"] = id_out,
		["object.linger"] = true,
	})

	link:activate(Features.ALL)
end

-- Connect the specified mic input port to the virtual output
-- Special conditions apply for the microphone as there is a finite (1) number of canidates
-- NOTE: We will assume that the virtual source is always available before the audio interface
local function connect_mic (om, m)
	if ( virt:get_n_objects () == 0 ) then
		Log.warning (om, "routing.lua: No virtual source ports found")
		return
	end

	-- NOTE: I probably should add a check here that a link doesn't already exist, but I wager this is already handled by the link factory
	for p in virt:iterate() do
		create_link(p, m)
	end
end

-- Callback whenever a new stream is detected
-- Determine the input and output IDs (object.id) of the ports and create the link
local function port_added (om, p)
	-- Get a reference to our 18i20 sink node
	local device = dev:lookup ()
	if ( not device ) then
		-- If no device, nothing left to do
		-- print ("No device")
		return
	elseif ( dev:get_n_objects () > 1 ) then
		Log.warning (dev, "routing.lua: More than one 18i20 device detected by the object manager")
	end

	-- Attempt to find an executable name attached to our port
	local streamID = tonumber (p["properties"]["node.id"])
	local stream = streams:lookup { Constraint { "object.id", "equals", streamID } }
	if ( not stream ) then
		-- NOTE: Dead streams will raise this warning (like firefox after you pause a video for example)
		Log.warning (streams, "routing.lua: No stream found with ID " .. streamID)
		return
	end

	local bin = stream["properties"]["application.process.binary"]
	if ( not bin ) then
		bin = stream["properties"]["node.name"]
	end

	-- Determine to which channels our node should connect
	local channel = -1
	for i, arr in pairs (route_map) do
		for _, program in ipairs (arr) do
			if ( bin == program ) then
				channel = i
				break
			end
		end
	end

	if channel < 0 then
		Log.debug ("routing.lua: No rule found for application '" .. tostring (bin) .. "' (default to 0)")
		channel = 0
	end
	
	-- print ("Application '" .. tostring (bin) .. "' should map to virtual output: " .. tostring (channel))

	-- Obtain target sink ports from our audio interface
	-- NOTE: Currently assuming that the ports are indexed 'in order' (i.e. if idx 3 goes to AUX5, then idx 4 goes to AUX6)
	-- NOTE: Also assuming all node ports are zero-indexed and ascending
	local offset = tonumber (p["properties"]["port.id"])
	if ( offset > 1 ) then
		return
	end

	-- NOTE: The 18i20 sink node has both sink and monitor ports
	local p_in = device:lookup_port { 
		Constraint { "port.direction", "equals", "in" },
		Constraint { "port.id", "equals", channel * 2 + offset },
	}
	
	create_link(p_in, p)

	-- DEBUGGING STUFF --
	-- print ("Connecting new port")
	-- Debug.dump_table(p["properties"])
	-- print()

	-- print ("SINK PORT")
	-- print ("Bound ID: " .. sink_port["bound-id"])
	-- Debug.dump_table (sink_port["properties"])
	-- print ()

	-- print ("SOURCE PORT")
	-- print ("Bound ID: " .. p["bound-id"])
	-- Debug.dump_table (p["properties"])
	-- print ()
	---------------------
end

-- Attempt to regenerate links for any streams which have none
-- This is called anytime a node is added to the dev OM (as it would indicate the device has been replugged)
-- (This should work fine because the generate link function from a new port will exit if it cannot find the device)
local function restore_links (om, dev_node)
	if ( om:get_n_objects () > 1 ) then
		-- Do nothing if there is already a device connected
		Log.warning(om, "routing.lua: More than one 18i20 device detected by the object manager")
		return
	end

	-- TODO: Currently running into issue where device node is generated before its ports become available
	-- This means that the streams attempt to "link a null port"
	-- A solution that waits for these to become available is necessary
	-- Consider checking the state of the node: https://gitlab.freedesktop.org/pipewire/wireplumber/-/blob/master/tests/examples/bt-pinephone.lua#L100

	-- NOTE: A hacky solution if I'm desperate and need to fix this amidst a stream schedule
	-- Create an additional object manager for ports, and specifically seek the final playback port (playback_AUX19)
	-- 		of the interface. When this object is added, use this to trigger the regen links function as we
	-- 		can now assume that the rest of the ports are available.
	for p in ports:iterate () do
		port_added(nil, p)
	end
end

-- dev:connect ("object-added", restore_links)
dev:activate ()
virt:activate ()

streams:activate ()

ports:connect ("object-added", port_added)
ports:activate ()

mic:connect ("object-added", connect_mic)
mic:activate ()