#!/bin/wpexec

local objmgr = ObjectManager {
	Interest { type = "proxy" }
}

objmgr:connect ("objects-changed", function (om)
	print( om:get_n_objects() )
	Core.quit ()
end)
objmgr:connect ("object-added", function (om, obj)
	print (obj.properties["object.id"])
end)
objmgr:activate ()

print("testing!")
