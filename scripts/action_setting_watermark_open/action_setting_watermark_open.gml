/// action_setting_watermark_open([filename])
/// @arg [filename]

function action_setting_watermark_open()
{
	if (argument_count = 0)
		fn = file_dialog_open_image()
	else
		fn = argument[0]
	
	if (!file_exists_lib(fn))
		return 0
	
	if (setting_watermark_filename != "")
		sprite_delete(setting_watermark_image)
	
	// We have to add twice, first to get the width/height, second to have it added centered
	var img_temp, img_width, img_height;
	img_temp = sprite_add_lib(fn)
	img_width = sprite_get_width(img_temp)
	img_height = sprite_get_height(img_temp)
	sprite_delete(img_temp)
	
	setting_watermark_image = sprite_add_lib(fn, round(img_width/2), round(img_height/2))
	setting_watermark_filename = fn
}
