/// menu_transition_init()

//menu_item_w = 60
//menu_item_h = 60

list_init_start()

for (var t = 0; t < ds_list_size(transition_list); t++)
{
	var name = transition_list[|t];
	list_item_add(text_get("transition" + name), name, "", transition_texture_map[?name], null, null, null)
	list_item_last.thumbnail_blend = c_text_main
	list_item_last.thumbnail_alpha = a_text_main
}

return list_init_end()

/*
for (var t = 0; t < ds_list_size(transition_list); t++)
	menu_add_transition(transition_list[|t])
*/