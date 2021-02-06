/// action_setting_unlimited_values(unlimited_values)
/// @arg unlimited_values

if (argument0 = true)
{
	if (!question(text_get("questionunlimitedvalues")))
		return 0
	
	toast_new(e_toast.NEGATIVE, text_get("alertrestartprogram"))
}

setting_unlimited_values = argument0
