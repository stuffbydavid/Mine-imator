function action_setting_backup_time(value, add)
{
	setting_backup_time = setting_backup_time * add + value
	project_reset_backup()
}
