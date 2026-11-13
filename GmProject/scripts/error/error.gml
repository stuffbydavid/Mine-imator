function error(name)
{
	var text = text_get(name);
	
	log("ERROR", text)
	
	message_set_caption(text_get(name + "_caption"))
	show_message(text)
	
	return null
}
