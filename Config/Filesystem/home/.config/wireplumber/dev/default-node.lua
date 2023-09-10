-- default_nodes = Plugin.find("default-nodes-api")

obj_mgr = ObjectManager {
    Interest {
        type = "node"
        Constraint { "media.class", "matches", "*/Sink" }
    },
}

-- function getDefaultNode(target_direction)
--     local target_media_class = "Audio" .. (target_direction == "input" and "/Sink" or "/Source")
--     return default_nodes:call("get-default-node", target_media_class)
-- end

-- function printNode(node)
--     local id = node["bound-id"]
--     local global_props = node["global-properties"]

--     print( tostring(id) .. ": " .. global_props["node.description"] )
--     Debug.dump_table(node.properties)
--     print()
-- end

obj_mgr:connect("installed", function (om)
    -- local default_id = getDefaultNode(properties, "input")
    local interest = Interest { type = "node",
        Constraint { "media.class", "matches", "*/Sink" }
        -- Constraint { "node.id", "=", tostring(default_id) }
    }
    for obj in om:iterate() do
        printNode(obj)
    end

    -- printNode(default_node)

    Core.quit()
end)

obj_mgr:activate()
