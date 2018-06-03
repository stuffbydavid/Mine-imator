/// action_setting_render_watermark_open([filename])
/// @arg [filename]

var fn;

if (argument_count > 0)
	fn = argument[0]
else
	fn = file_dialog_open_image();

if (!file_exists_lib(fn))
	return 0

if (setting_render_watermark_filename != "")
	sprite_delete(setting_render_watermark_image)

// We have to add twice, first to get the width/height, second to have it added centered
var img_temp, img_width, img_height;
img_temp = sprite_add_lib(fn)
img_width = sprite_get_width(img_temp)
img_height = sprite_get_height(img_temp)
sprite_delete(img_temp)

setting_render_watermark_image = sprite_add_lib(fn, round(img_width/2), round(img_height/2))
setting_render_watermark_filename = fn