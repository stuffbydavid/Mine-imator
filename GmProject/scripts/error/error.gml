/// error(name)
/// @arg name

function error(name)
{
	var text = text_get(name);
	window_set_caption(text_get(name + "caption"))
	show_message(text)
	log("ERROR", text)
	window_set_caption("")
	
	return null
}
