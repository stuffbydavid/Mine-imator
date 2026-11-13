function action_setting_unlimited_values(enabled)
{
	if (enabled)
	{
		if (!question(text_get("question/unlimited_values")))
			return 0
	}
	
	setting_unlimited_values = enabled
}
