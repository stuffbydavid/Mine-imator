/// action_setting_minecraft_assets_version(version)
/// @arg version

if (setting_minecraft_assets_version != argument0)
{
	setting_minecraft_assets_version = argument0
	toast_new(e_toast.NEGATIVE, text_get("alertrestartprogram"))
}