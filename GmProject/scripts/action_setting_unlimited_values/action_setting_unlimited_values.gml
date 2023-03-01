/// action_setting_unlimited_values(unlimited_values)
/// @arg unlimited_values

function action_setting_unlimited_values(unlimited_values)
{
	if (unlimited_values)
	{
		if (!question(text_get("questionunlimitedvalues")))
			return 0
	}
	
	setting_unlimited_values = unlimited_values
}
