/// list_value_filter(list)
/// @arg list
/// @desc Filters ou duplicate values and executable items

function list_value_filter(list)
{
	var valuelist = ds_list_create();
	
	for (var i = 0; i < ds_list_size(list.item); i++)
	{
		var item = list.item[|i];
		
		if (ds_list_find_index(valuelist, item.value) = -1)
			ds_list_add(valuelist, item.value)
		else
		{
			instance_destroy(item)
			ds_list_delete(list.item, i)
			i--
			continue
		}
		
		if (	item.script != null ||
				item.value = e_option.BROWSE ||
				item.value = e_option.IMPORT_WORLD ||
				item.value = e_option.DOWNLOAD_SKIN ||
				item.value = e_option.DOWNLOAD_SKIN_DONE ||
				item.value = e_option.IMPORT_ITEM_SHEET_DONE)
		{
			instance_destroy(item)
			ds_list_delete(list.item, i)
			i--
		}
	}
	
	ds_list_destroy(valuelist)
}