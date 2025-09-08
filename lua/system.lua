local dirload = require("lua.dirload")

return function(initial_target)
	local systems = dirload("spec/system")
	local target_system = nil

	if initial_target == "AUTO" then
		-- Figure out what system we're installing to
		-- NOTE: Relatively lazy heuristic, score better than a 4 for a system to
		-- be a valid candidate
		local best_score = 4
		for sys, spec in pairs(systems) do
			if type(spec.score) == "function" then
				local score = spec.score()
				if score > best_score then
					best_score = score
					target_system = sys
				end
			end
		end

		if target_system then
			print("Detected " .. target_system:upper() .. " as the target system")
		else
			print("Target system could not be determined")
			-- TODO: Consider prompting the user if they want to quit
		end
		print() -- Useless formatting

	elseif initial_target ~= "NONE" then
		-- TODO: This lower() is a side effect of the current options parsing
		target_system = initial_target:lower()
	end

	if target_system then
		return target_system, systems[target_system]
	end
end
