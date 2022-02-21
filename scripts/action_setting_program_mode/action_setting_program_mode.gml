/// action_setting_program_mode(advanced)
/// @arg advanced

function action_setting_program_mode(advanced)
{
	if (advanced && trial_version)
	{
		popup_show(popup_upgrade)
		popup_upgrade.page = 1
		return 0
	}
	
	setting_advanced_mode = advanced
}
