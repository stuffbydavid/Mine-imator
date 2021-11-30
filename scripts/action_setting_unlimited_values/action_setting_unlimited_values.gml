/// action_setting_unlimited_values(unlimited_values)
/// @arg unlimited_values

function action_setting_unlimited_values(unlimited_values)
{
	if (unlimited_values)
	{
		if (!question(text_get("questionunlimitedvalues")))
			return 0
		
		toast_new(e_toast.NEGATIVE, text_get("alertrestartprogram"))
	}
	
	setting_unlimited_values = unlimited_values
}
