/// action_restore_controls()

function action_restore_controls()
{
	if (!question(text_get("questionrestorecontrols")))
		return 0
	
	keybinds_reset_default()
	
	setting_move_speed = 1
	setting_look_sensitivity = 1
	setting_fast_modifier = 3
	setting_slow_modifier = 0.25
}