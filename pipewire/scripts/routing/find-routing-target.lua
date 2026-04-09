-- There are a couple components to this hook
-- This is meant to be the almost first linking hook ran, hence "before = linking/find-default-target"
-- That said, we are still after find-defined-target as we want the node.target property to be respected
-- (The sister of this hook is `linking/find-virtual-target.lua` to which `find-defined-target` has it listed as an "after = ...")
-- 	^^ https://pipewire.pages.freedesktop.org/wireplumber/scripting/existing_scripts/linking.html

-- This hook seeks to take any given stream, check for the property `media.route` (custom to us)
-- and if it exists, link to the corresponding virtual node

-- This policy will be handled only if the current default device has an entry in `routing.devices = { ... }`
-- in the wireplumber configuration files (i.e. wireplumber.conf.d/...)

-- Reference files:
-- 	scripts/linking/find-defined-target.lua
-- 	scripts/linking/find-virtual-target.lua

lutils = require ("linking-utils")
log = Log.open_topic ("routing")

config = {}
config.device_routes = Conf.get_section_as_object ("routing.devices")

-- For debugging, recursively converts dict/list values to a string
function dumpstr (o)
   if type (o) == 'table' then
      local s = ''
      for k, v in pairs(o) do
         if type (k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dumpstr (v) .. '\n'
      end
      return s .. '\n'
   else
      return tostring (o)
   end
end

-- Check if a device is a routing device (aka if routing mode is active or not)
function routingActive (device_id, source)
	if not device_id then
		return false
	end

	-- Get the device object from its ID
	local devices_om = source:call ("get-object-manager", "device")
	local device = devices_om:lookup({ Constraint { "object.id", "=", device_id }})
	if not device then
		return false
	end

	-- Find the routing name
	local routing_name = device.properties["routing.name"]
	if not routing_name then
		return false
	end

	-- Search for the name in the table
	for name, _ in pairs (config.device_routes) do
		if name == routing_name then
			return true
		end
	end

	return false
end

SimpleEventHook {
	name = "routing/find-routing-target",
	before = "linking/find-filter-target",
	after = "linking/find-defined-target",
	interests = {
		EventInterest {
			Constraint { "event.type", "=", "select-target" },
		},
	},
	execute = function (event)
		-- log:warning("find-routing-target was ran")
		local source, om, si, si_props, si_flags, event_target = lutils:unwrap_select_target_event (event)

		-- If the node had node.target set, then the event result is already known
		if event_target ~= nil then
			return
		end

		-- Check that the stream connects to a sink
		if si_props["item.node.direction"] ~= "output" then
			-- By simply returning, we pass the routine down to the subsequent hook
			return
		end

		-- TODO: It may be a bit excessive to call this every time
		-- 	but I struggle to keep the solution quite as tidy otherwise
		local target = lutils.findDefaultLinkable (si)
		if not routingActive(target.properties["device.id"], source) then
			return
		end
		
		-- Get the routing rule (`media.route`)
		-- TODO: For configurability, I want to be able to specify a "default" routing node
		-- (Currently it's just hard-coded to `system`)
		local route = si_props["media.route"]
		if not route then
			route = "system"
		end

		target = om:lookup({ Constraint { "node.name", "=", "routing." .. route }})
		if target ~= nil then
			event:set_data ("target", target)
		end
	end
}:register()
