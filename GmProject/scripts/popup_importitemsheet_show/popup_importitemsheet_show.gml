/// popup_importitemsheet_show(filename, script)
/// @arg filename
/// @arg script

function popup_importitemsheet_show(fn, script)
{
	with (popup_importitemsheet)
	{
		if (texture != null)
			texture_free(texture)
		
		filename = fn
		value_script = script
		
		texture = texture_create(filename)
		is_sheet = true
		sheet_size = vec2(minecraft_item_sheet_size[0], minecraft_item_sheet_size[1])
		if (texture_width(texture) < item_size * 8 || texture_height(texture) < item_size * 8) // Probably too small to be a sheet
			is_sheet = false
		else if (texture_width(texture) = texture_height(texture)) // Square, probably old sheet
			sheet_size = vec2(16, 16)
		sheet_size_def = array_copy_1d(sheet_size)
	}
	
	if (popup != null)
		popup_switch(popup_importitemsheet)
	else
		popup_show(popup_importitemsheet)
}
