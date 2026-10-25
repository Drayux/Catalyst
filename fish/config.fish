set -g snapshot_mode_active 0
test -f /run/snapshot/.timestamp; and set -g snapshot_mode_active 1

if status is-interactive
	bind \cz fg_toggle
end
