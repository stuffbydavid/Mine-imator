function action_setting_unlimited_values(enabled)
{
	if (enabled)
	{
		if (!question(text_get("questionunlimitedvalues")))
			return 0
	}
	
	setting_unlimited_values = enabled
}
