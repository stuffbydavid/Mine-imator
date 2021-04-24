/// action_setting_backup_time(value, add)
/// @arg value
/// @arg add

function action_setting_backup_time(val, add)
{
	setting_backup_time = setting_backup_time * add + val
	project_reset_backup()
}
