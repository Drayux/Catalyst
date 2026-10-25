# Allows me to hotkey-ify a CTRL-Z / fg workflow
function fg_toggle
	if jobs -q
		fg 2>/dev/null
		printf '\e[1A\e[2K' # "erase" escape sequence
	end
	commandline -f repaint
end
