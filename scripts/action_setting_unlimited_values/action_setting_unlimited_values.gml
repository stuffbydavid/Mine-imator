/// action_setting_unlimited_values(unlimited_values)
/// @arg unlimited_values

if (argument0 = true)
{
	if (!question(text_get("questionunlimitedvalues")))
		return 0
	else
		alert_show(text_get("alertrestartprogramtitle"), text_get("alertrestartprogramtext"), null, "", "", 5000)
}

setting_unlimited_values = argument0
