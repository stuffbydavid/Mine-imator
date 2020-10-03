/// list_init(name)
/// @arg name
/// @desc Makes a list and returns it based on name

var name, list;
name = argument0
list = list_new()
list_edit = list

// Model state
if (menu_model_current != null)
{
	for (var i = 0; i < menu_model_state.value_amount; i++)
		list_item_add(minecraft_asset_get_name("modelstatevalue", menu_model_state.value_name[i]), menu_model_state.value_name[i])
		
	return 0
}

// Block state
if (menu_block_current != null)
{
	for (var i = 0; i < menu_block_state.value_amount; i++)
		list_item_add(minecraft_asset_get_name("blockstatevalue", menu_block_state.value_name[i]), menu_block_state.value_name[i])
		
	return 0
}

switch (name)
{
	case "startupsortby":
	{
		list_item_add(text_get("recentsortdatenewest"), e_recent_sort.date_newest, "", null, null, null, action_recent_sort)
		list_item_add(text_get("recentsortdateoldest"), e_recent_sort.date_oldest, "", null, null, null, action_recent_sort)
		list_item_add(text_get("recentsortnameaz"), e_recent_sort.name_az, "", null, null, null, action_recent_sort)
		list_item_add(text_get("recentsortnameza"), e_recent_sort.name_za, "", null, null, null, action_recent_sort)
		break;
	}
	
	// Video size
	case "projectvideosize":
	case "exportmovievideosize":
	case "exportimageimagesize":
	case "frameeditorcameravideosize":
	{
		if (menu_name = "frameeditorcameravideosize")
			list_item_add(text_get("frameeditorcameravideosizeuseproject"), null)
			
		for (var i = 0; i < ds_list_size(videotemplate_list); i++)
			with (videotemplate_list[|i])
				list_item_add(text_get("projectvideosizetemplate" + id.name) + " (" + string(width) + "x" + string(height) + ")", id)
				
		list_item_add(text_get("projectvideosizecustom"), 0)
		
		break
	}
}

list_update_width(list)

if (ds_list_size(list.item) > 0 && list.item[|0].divider)
	list.item[|0].divider = false

list_edit = null

return list