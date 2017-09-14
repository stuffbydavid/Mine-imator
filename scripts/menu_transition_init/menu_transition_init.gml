/// menu_transition_init()

menu_item_w = 60
menu_item_h = 60

for (var t = 0; t < ds_list_size(transition_list); t++)
	menu_add_transition(transition_list[|t])
