/// new_popup(name, script, width, height, block, [custom])
/// @arg name
/// @arg script
/// @arg width
/// @arg height
/// @arg block
/// @arg [custom]

var popup = new(obj_popup);

popup.name = argument[0]
popup.script = argument[1]
popup.width = argument[2]
popup.height = argument[3]
popup.block = argument[4]
popup.caption = text_get(popup.name + "caption")
popup.offset_x = 0
popup.offset_y = 0

if (argument_count > 5)
	popup.custom = argument[5]
else
	popup.custom = false

return popup
