/// list_init(name)
/// @arg name
/// @desc Makes a list and returns it based on name

var name, list;
name = argument0
list = list_new()
list_edit = list

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
}

list_update_width(list)

if (ds_list_size(list.item) > 0 && list.item[|0].divider)
	list.item[|0].divider = false

list_edit = null

return list