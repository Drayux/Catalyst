om = ObjectManager {
	Interest {
		type = "node",
		Constraint { "media.class", "matches", "Stream/Output/Audio" },
	}
}

om:connect("installed", function (manager)
	for node in manager:iterate () do
		local bin = node["properties"]["application.process.binary"]
		if ( not bin ) then
			bin = node["properties"]["node.name"]
		end
		print ("Stream '" .. bin .. "' (" .. node["bound-id"] .. ")")
	end

	Core.quit()
end)

om:activate ()
