/// action_setting_backup_amount(value, add)
/// @arg value
/// @arg add

function action_setting_backup_amount(val, add)
{
	setting_backup_amount = setting_backup_amount * add + val
}
