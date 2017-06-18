/// new_popup(name, script, width, height, block)
/// @arg name
/// @arg script
/// @arg width
/// @arg height
/// @arg block

var popup = new(obj_popup);

popup.name = argument0
popup.script = argument1
popup.width = argument2
popup.height = argument3
popup.block = argument4
popup.caption = text_get(popup.name + "caption")
popup.offset_x = 0
popup.offset_y = 0

return popup
