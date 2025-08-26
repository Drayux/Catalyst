-- Creates an event that watches for the certain devices to be created on the graph
-- When a matching device is found, create links between it and virtual devices according to
-- rules specified in the custom configuration section: routing.device-routes

-- NOTE: This script will only work for physical (ALSA) device nodes!
-- 		 In it's current form, it relies upon the ALSA monitor for device rules
-- 		 as well as specifies an event which only matches devices.
--		 Retrofitting this for other node types should be relatively trivial

-- Reference files
--	.../scripts/node/create-virtual-item.lua : log / config

lutils = require ("linking-utils")
log = Log.open_topic ("routing")

config = {}
config.device_routes = Conf.get_section_as_object ("routing.devices")

-- Takes a device node and resolves the routing configuration
-- Returns nil if not present

-- Configuration example:
-- 		routing.devices = {
-- 			scarlett-18i20 = {
-- 				capture = {
-- 					sterling		= [ AUX2 AUX2 ]
-- 				}
-- 				playback = {
-- 					applications 	= [ AUX0 AUX1 ]
-- 					media 			= [ AUX2 AUX3 ]
-- 					voice 			= [ AUX4 AUX5 ]
-- 					stream 			= [ AUX6 AUX7 ]
-- 					system 			= [ AUX8 AUX9 ]
-- 				}
-- 			}
-- 		}
-- (Note that `scarlett-18i20` refers to the `routing.name` parameter set with `monitor.alsa.rules = [ ... ]`)

-- TODO: Could use a better way to check if the configuration exists (and is formatted correctly)
function getRouteConf(si_props, source)
	local devices_om = source:call ("get-object-manager", "device")
	local device_id = si_props["device.id"]
	
	local device = devices_om:lookup({ Constraint { "object.id", "=", device_id }})
	if not device then
		return nil
	end

	local conf_entry = device.properties["routing.name"]
	if not conf_entry then
		return nil
	end
	
	local conf_routes = config.device_routes[conf_entry]
	if not conf_routes then
		return nil
	end

	return conf_routes[si_props["api.alsa.pcm.stream"]]
end

-- target_port belongs to the virtual device
-- device_port belongs to the device requesting the connection (as configured in routing.device-routes)
-- device_dir is either "in" or "out" and specifies if the device node is a sink or source, respectively
function createLink (target_port, device_port, device_dir)
	if not target_port or not device_port then
		Log.warning("attempt to create link with null port")
		return
	end

	-- TODO: lutils:lookup_link (check that this link does not already exist)

	-- We will create Pipewire `link-factory` links directly
	-- The si-standard-link factory requires that our in/out items are SiLinkables
	-- and we further have no (apparent) control over which ports are linked
	-- (The score-ports function tries to match names, so we could potentially modify our virtual sinks, but this is much more practical)
	-- This is explained in further detail in the configuration overview (Audio.md)
	if device_dir == "in" then
		log:debug("linking " .. device_port.properties["port.alias"] .. " (" .. device_port["bound-id"] .. ") to " .. target_port.properties["port.alias"] .. " (" .. target_port["bound-id"] .. ")")
		Link ("link-factory", {
			["link.output.port"] = tonumber(target_port["bound-id"]),
			["link.input.port"] = tonumber(device_port["bound-id"]),
			["object.linger"] = true,
		}):activate(Features.ALL)
	else
		log:debug("linking " .. target_port.properties["port.alias"] .. " (" .. target_port["bound-id"] .. ") to " .. device_port.properties["port.alias"] .. " (" .. device_port["bound-id"] .. ")")
		Link ("link-factory", {
			["link.output.port"] = tonumber(device_port["bound-id"]),
			["link.input.port"] = tonumber(target_port["bound-id"]),
			["object.linger"] = true,
		}):activate(Features.ALL)
	end
end

-- TODO: This appears to occasaionlly fail to connect, I presume because it runs before the device node is ready
-- 		 Try referring to the script that handles moving streams if the default device is connected?
SimpleEventHook {
	name = "routing/link-device-routes",
	interests = {
		EventInterest {
			-- event:get_propertes() returns all props
			-- 	^^ https://gitlab.freedesktop.org/pipewire/wireplumber/-/blob/master/lib/wp/event.h
			-- Interests: https://pipewire.pages.freedesktop.org/wireplumber/scripting/lua_api/lua_object_interest_api.html
			Constraint { "event.type", "=", "node-added" },
			Constraint { "device.class", "=", "sound" },
		},
	},
	execute = function (event)
		local source, om, si, si_props, si_flags, _ = lutils:unwrap_select_target_event (event)
		local route_conf = getRouteConf(si_props, source)

		-- If no configuration, then we have nothing to do
		if not route_conf then
			return
		end

		-- Debugging output
		-- log:warning( si:get_n_ports() )
		-- log:warning( nodes_om:get_n_objects() )
		-- log:warning( dumpstr(route_conf) )
		
		local nodes_om = source:call ("get-object-manager", "node")
		local target_port_dir = "out"
		local device_port_dir = "in"

		-- Source device nodes will connect to the input ports of the virtual device
		-- (Device stream is "capture")
		if si_props["api.alsa.pcm.stream"] ~= "playback" then
			target_port_dir = "in"
			device_port_dir = "out"
		end

		for name, ports in pairs(route_conf) do
			-- Handle if configuration does not provide array of ports
			if not ports then
				log:warning("no ports specified for target " .. name .. ", skipping")
				goto continue_node
			end
		
			-- Attempt to find the requested virtual node
			local target = nodes_om:lookup({ Constraint { "node.name", "=", "routing." .. name }})
			if not target then
				log:warning("could not find node routing." .. name .. ", skipping")
				goto continue_node
			end
			-- log:warning( dumpstr(target.properties) )

			local port_idx = 1
			for port in target:iterate_ports({ Constraint { "port.direction", "=", target_port_dir }}) do
				-- log:warning( dumpstr(port.properties) )
				
				-- Handle when the virtual device has more ports than specified in the config
				local target_port_name = ports[port_idx]
				if not target_port_name then
					goto continue_node
				end

				-- Find the matching port on the device node
				local device_port = si:lookup_port({
					Constraint { "port.direction", "=", device_port_dir },
					Constraint { "port.name", "#", "*" .. target_port_name },
				})
				if not device_port then
					log:warning("requested device port could not be found")
					goto continue_port
				end

				-- Create the link between the found ports
				createLink (port, device_port, device_port_dir)

				::continue_port::
				port_idx = port_idx + 1
			end
			
			::continue_node::
		end
	end
}:register()
