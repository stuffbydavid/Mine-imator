/// action_setting_minecraft_assets_version(version)
/// @arg version

if (setting_minecraft_assets_version != argument0)
{
	setting_minecraft_assets_version = argument0
	alert_show(text_get("alertrestartprogramtitle"), text_get("alertrestartprogramtext"), null, "", "", 5000)
}