-- Route all music sources through channels 5/6 (aka AUX4 and AUX5)
-- Binaries include: Cider, Spotify, Tidal, etc.

-- Log.warning("TODO: Routing for music.lua")


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


om = ObjectManager {
	-- Interest {
		-- type = "port",
      -- Constraint { "node.id", "equals", 123 },
      -- Constraint { "port.alias", "matches", "Firefox*" },
	-- },
--    Interest {
    --   type = "client",
	--   Constraint { "application.process.binary", "!", "wpexec" },
	--   Constraint { "application.process.binary", "!", "pipewire" },
   --    Constraint { "application.name", "matches", "Chromium*" },
   --    Constraint { "media.class", "matches", "Stream/Output/Audio" },
--    },
   Interest {
		type = "node",
		-- Constraint { "client.api", "=", "jack" },
    	-- Constraint { "active-features", "!", 0, type = "gobject" },
		Constraint { "node.name", "matches", "*Focusrite_Scarlett_18i20_USB*" },
		Constraint { "media.class", "matches", "Audio/Sink" },
	},
   -- Interest {
   --    type = "link",
   -- },
}

-- local default_nodes = Plugin.find("default-nodes-api")

om:connect("object-added", function (manager, object)
	-- local props = object["properties"]
	local props = object["global-properties"]
	-- print("Object ID: " .. props["object.id"])
	print("Bound ID: " .. object["bound-id"])
	-- print(dumpTable(props))
	Debug.dump_table(props)
	print()
end)

-- om:connect("object-added", function (manager, object)
-- 	local props = object["properties"]
-- 	local bin = props["application.process.binary"]
-- 	if ( bin == "pipewire" or bin == "wpexec" or bin == "wireplumber" ) then
-- 		return
-- 	end

-- 	print("Binary: '" .. bin .. "'")
-- 	-- local node = object:get_associated_proxy("node")
-- 	print(dumpTable(props))
-- 	print()
-- end)

-- om:connect("object-added", function (manager, object)
-- 	for port in object:iterate_ports() do
-- 		local props = port.properties
-- 		print(dumpTable(props))
-- 		print()
-- 	end
-- end)

-- om:connect("object-removed", function (manager, object)
	-- print("link removed: " .. link["bound-id"])
-- end)

om:activate()

-- local link = Link("link-factory", {
--    ["link.input.port"] = 67,
--    ["link.output.port"] = 131,
-- })
-- link:activate(Features.ALL)

	-- If no device, nothing left to do
	-- local n = om.get_n_objects()
	-- if n == 0 then
	-- 	return nil
	-- elseif n > 1 then
	-- 	Log.warning(om, "routing.lua: More than one 18i20 device detected by the object manager.")
	-- end

	-- local device = om:lookup()



	-- local ports = ObjectManager {
	-- 	Interest {
	-- 		type = "port",
	-- 	}
	-- }

	-- ports:connect("installed", function (om)
	-- 	print ("connected!")
	-- 	-- NOTE: Currently assuming that the ports are indexed 'in order' (i.e. if idx 3 goes to AUX5, then idx 4 goes to AUX6)
	-- 	local sink_interest = Interest {
	-- 		type = "port",
	-- 		Constraint { "node.id", "equals", tostring (device["bound-id"]) },
	-- 		Constraint { "port.id", "equals", tostring (channel * 2) },
	-- 	}

	-- 	-- NOTE: Also assuming all node ports are zero-indexed and ascending
	-- 	local source_interest = Interest {
	-- 		type = "port",
	-- 		Constraint { "node.id", "equals", tostring (node["bound-id"]) },
	-- 		Constraint { "port.id", "equals", "0" },
	-- 	}

	-- 	local port_in = ports:lookup (sink_interest) ["properties"]["object.id"]
	-- 	local port_out = ports:lookup (source_interest) ["properties"]["object.id"]

		
	-- end)

	-- -- We must wait for the ports OM to be ready to find the entries we want
	-- ports:activate()

	-- -- Attempt to generate the link
	-- -- NOTE: Links are automatically cleaned up by the factory if either end is disconnected
	-- local link_L = Link ("link-factory", {
	-- 	["link.input.port"] = port_L_sink["properties"]["object.id"],
	-- 	["link.output.port"] = port_L_source["properties"]["object.id"],
	-- })

	-- local link_R = Link ("link-factory", {
	-- 	["link.input.port"] = port_R_sink["properties"]["object.id"],
	-- 	["link.output.port"] = port_R_source["properties"]["object.id"],
	-- })

	-- link_L:activate(Features.ALL)
	-- link_R:activate(Features.ALL)


-- linkstest = ObjectManager {
-- 	Interest {
-- 		type = "link",
-- 	}
-- }
-- linkstest:connect("object-added", function(om, l)
-- 	print ("new link added: " .. tostring(l))
-- 	-- print ("global link var: " .. tostring(link))
-- 	Debug.dump_table(l["properties"])
-- 	print()
-- end)
-- linkstest:connect("object-removed", function(om, l)
-- 	print ("link removed: " .. tostring(l))
-- 	Debug.dump_table(l["properties"])
-- 	print()

-- 	-- print ("global link var: " .. tostring(link))
-- 	-- Debug.dump_table(link["properties"])
-- 	-- print()
-- end)
-- linkstest:activate ()