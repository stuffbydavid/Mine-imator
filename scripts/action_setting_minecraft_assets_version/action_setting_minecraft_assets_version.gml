/// action_setting_minecraft_assets_version(version)
/// @arg version

function action_setting_minecraft_assets_version(version)
{
	if (setting_minecraft_assets_version != version)
	{
		setting_minecraft_assets_version = version
		toast_new(e_toast.NEGATIVE, text_get("alertrestartprogram"))
	}
}
