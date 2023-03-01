/// error(name)
/// @arg name

function error(name)
{
	window_set_caption(text_get(name + "caption"))
	show_message(text_get(name))
	window_set_caption("")
	
	return null
}
