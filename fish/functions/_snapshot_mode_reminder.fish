function _snapshot_mode_reminder
	if test "$snapshot_mode_active" = 1
        set_color --bold bryellow
        printf '[ SNAPSHOT ] '
        set_color normal
    end
end
