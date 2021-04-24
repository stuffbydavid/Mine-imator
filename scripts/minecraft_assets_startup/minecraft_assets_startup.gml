/// minecraft_assets_startup()
/// @desc Checks for new Minecraft assets.

function minecraft_assets_startup()
{
	// New assets found
	if (setting_minecraft_assets_new_version != "")
	{
		new_assets_version = setting_minecraft_assets_new_version
		new_assets_format = setting_minecraft_assets_new_format
		new_assets_changes = setting_minecraft_assets_new_changes
		new_assets_changes_lines = string_split(new_assets_changes, "\n")
		new_assets_image = setting_minecraft_assets_new_image
		new_assets_scroll = new_obj(obj_scrollbar)
		
		if (new_assets_image != "" && file_exists_lib(new_assets_image))
			new_assets_image_texture = texture_create(new_assets_image)
		else
			new_assets_image_texture = null
		
		window_state = "new_assets"
		new_assets_stage = ""
		new_assets_download_progress = 0
		window_set_size(540, 480)
		window_set_caption("Mine-imator")
		alarm[0] = 1
	}
	
	// Load current
	else if (!minecraft_assets_load_startup())
	{
		error("errorloadassets")
		return false
	}
	
	return true
}
