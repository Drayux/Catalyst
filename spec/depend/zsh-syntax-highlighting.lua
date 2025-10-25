-- > Package: `zsh-syntax-highlighting` (both pacman and portage)

local spec = {
	installed = function(self)
		-- TODO: all of this
		return exists("/usr/share/zsh/site-functions/zsh-syntax-highlighting.zsh")
			or exists("/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh")
	end

	-- TODO: Consider recommending package manager packages for the relatively
	-- trivial dependencies
}

return spec
