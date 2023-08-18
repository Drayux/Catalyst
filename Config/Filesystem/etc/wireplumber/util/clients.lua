-- List binary names of most* pipewire clients
-- Tool for finding table entries for '/etc/wireplumber/scripts/policy-node.lua'

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


nodes_om = ObjectManager { Interest { type = "node" }}
clients_om = ObjectManager { Interest { type = "client" }}

clients_om:connect("object-added", function (manager, client)
	local props = client.properties
	local bin = props["application.process.binary"]
	if ( bin == "pipewire" or bin == "wpexec" or bin == "wireplumber" ) then
		return
	end

	local node = nil
	nodes_om:connect("installed", function (om)
		-- Find an associated node
		-- node = om:lookup {
		-- 	Constraint { "client.id", "=", client["bound-id"] },
		-- 	Constraint { "media.class", "matches", "*Output/Audio" },
		-- }

		-- if ( node == nil ) then
		-- 	return
		-- end

		-- print(om:get_n_objects())
		print("Binary: '" .. bin .. "'")
		-- print(dumpTable(node.properties))
	end)
end)

nodes_om:activate()
clients_om:activate()