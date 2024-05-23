#!/bin/wpexec

-- This script handles virtual routing nodes
-- In my personal configuration, there are 5 such routes (nodes):
-- 	> applications, media, voice, stream, system

-- There is also a 6th "monitor" node provided
-- The role of this node is to be a composite virtual sink that accepts
-- 	any number of the routing nodes to merge into one
-- The benefit of this, is convenient linking to secondary devices, such as
-- 	output to speakers (aka audio monitors) or devices such as VR headsets

-- The role of this script is to arbitrarily link or unlink any number
-- 	of the virtual nodes to the monitoring node, so that various stream
-- 	routes can be toggled on and off from the "monitoring" devices

-- This does not appear to have any effect on wpexec scripts
-- log = Log.open_topic ("routing")
-- log:warning("this is a sample warning")

-- Get the arguments to the script
-- (Not sure I understand this syntax; I pulled it from `WIREPLUMBER_CONF/scripts/metadata.lua`)
-- Script should be called as <script> "{target = <target node>}" or <script> "{target = [ <target nodes> ]}"
local target = "all"
local mode = "toggle"
local args = ...
if args ~= nil then
	-- Args is a GBoxed
	-- This function calls parse on the referenced object, and returns a WpSpaJson (2 is the depth of the parse)
	-- This is a result of using wpexec
	args = args:parse(2)
	
	local tmptarget = args["target"]
	if tmptarget ~= nil then
		target = tmptarget
	end
	
	local tmpmode = args["mode"]
	if tmpmode ~= nil then
		mode = tmpmode
	end
end

-- Check the mode state
if not (mode == "connect" or mode == "disconnect" or mode == "toggle") then
	target = nil
end

if not target then
	print ("No targets specified/invalid mode")
	print ('Usage: <script> "{target = <target node/all> }" or <script> "{target = [ <target nodes> ]}"')
	print ('       Optionally mode can be also specified as "connect", "disconnect", or "toggle"')
	Core.quit()
elseif ( type (target) == type ("")) and target ~= "all" then
	target = { target }
end

-- Remove links if present
-- Returns true if links were removed, else false
function disconnect (om, monitor_node, target_node)
	local ret = false
	for link in om:iterate ({
		type = "link",
		-- The monitor only receives data, so it is always the input node
		Constraint { "link.output.node", "=", target_node.properties["object.id"] },
		Constraint { "link.input.node", "=", monitor_node.properties["object.id"] },
	}) do
		if not ret then
			print ("[TODO] Unlinking from " .. target_node.properties["node.description"] .. " (" .. target_node.properties["node.name"] .. ")")
			ret = true
		end
		-- link:remove ()
	end
	return ret
end

function connect (om, monitor_node, target_node)
	-- IMPORTANT TODO: If a node is already linked, we don't want create additional links
	print ("[TODO] Linking to " .. target_node.properties["node.description"] .. " (" .. target_node.properties["node.name"] .. ")")
end

-- Core linking logic
-- Run linking logic for each requested node, based upon the mode
function main (om)
	-- print (om:get_n_objects())

	-- Routing nodes are ready, begin linking
	local monitor = om:lookup ({
		type = "node",
		Constraint { "node.name", "=", "routing.monitor" },
	})
	if not monitor then
		print ("Could not find monitor node, quitting")
		return
	end

	local linkPresent = false
	if target == "all" then
		-- Loop through everything if target is "all"
		-- Try to disconnect if in "disconnect" or "toggle" mode
		if mode ~= "connect" then
			for node in om:iterate ({
				type = "node",
				Constraint { "node.name", "!", "routing.monitor" },
			}) do
				linkPresent = linkPresent or disconnect (om, monitor, node)
			end
			if mode == "disconnect" or linkPresent then
				-- Toggle mode will serve as a disconnect action
				-- if any links are found (else everything is connected)
				return
			end
		end

		-- Connect everything now
		for node in om:iterate ({
			type = "node",
			Constraint { "node.name", "!", "routing.monitor" },
		}) do connect (om, monitor, node) end
	else
		-- Loop through the listed targets otherwise (single targets are placed into a table)
		-- Not quite the same logic as above:
		-- 	Since routes are explicitly listed, flip their link states
		for _, t in pairs(target) do
			local node = om:lookup ({
				type = "node",
				Constraint { "node.name", "=", "routing." .. t },
			})
			if not node then
				print ("Could not find node: routing." .. t)
				goto continue_node
			end

			-- Check the "toggle" mode
			linkPresent = false
			if mode ~= "connect" then
				linkPresent = disconnect (om, monitor, node)
			end

			-- Connect should try to connect always
			-- Toggle should only connect if disconnection "failed"
			-- linkPresent will be false in either scenario
			if mode ~= "disconnect" and not linkPresent then
				connect (om, monitor, node)
			end

			::continue_node::
		end
	end
end

-- Object manager handles all objects
local routes_om = ObjectManager {
	Interest {
		type = "node",
		Constraint { "media.class", "=", "Audio/Sink" },
		Constraint { "node.name", "#", "routing.*" },
	},
	-- Another benefit of using a Duplex for the monitor is that it
	-- 	makes object manager filtering much more convenient
	Interest {
		type = "node",
		Constraint { "media.class", "=", "Audio/Duplex" },
		Constraint { "node.name", "=", "routing.monitor" },
	},
	-- Finally the links as well so that we do not need a second OM
	Interest { type = "link" },
}

-- Only try to connect the monitor node *after* the routing nodes are available
routes_om:connect ("objects-changed", function (om)
	main (om)
	
	-- This is a "one-shot" type of script
	Core.quit ()
	return false
end)
routes_om:activate()

-- Exit if it becomes apparent that the routing/monitor nodes do not exist
Core.timeout_add (3000, function ()
	print ("No routing/monitor nodes found, quitting")
	Core.quit ()
	
	return false
end)
