/// action_toolbar_importimage_type(type)
/// @arg type

function action_toolbar_importimage_type(type)
{
	popup_importimage.type = type
	
	if (type = e_res_type.ITEM_SHEET)
	{
		with (popup_importimage)
		{
			is_sheet = true
			sheet_size = vec2(minecraft_item_sheet_size[0], minecraft_item_sheet_size[1])
			
			if (texture_width(texture) < item_size * 8 || texture_height(texture) < item_size * 8) // Probably too small to be a sheet
				is_sheet = false
			else if (texture_width(texture) = texture_height(texture)) // Square, probably old sheet
				sheet_size = vec2(16, 16)
			
			sheet_size_def = array_copy_1d(sheet_size)
		}	
	}
}
