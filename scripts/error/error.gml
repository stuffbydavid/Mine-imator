/// error(name)
/// @arg name

var name = argument0;

window_set_caption(text_get(name + "caption"))
show_message(text_get(name))
window_set_caption("")

return null