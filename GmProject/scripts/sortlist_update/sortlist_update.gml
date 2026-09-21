/// sortlist_update(sortlist)
/// @arg sortlist
/// @desc Updates the sortlist when sorting or filtering.

function sortlist_update(slist)
{
	ds_list_clear(slist.display_list)
	
	if (slist.column_sort != null)
	{
		var sortedlist, valuelist, naturaldigits;
		sortedlist = ds_list_create()
		valuelist = ds_list_create()
		ds_list_copy(valuelist, slist.list)
		naturaldigits = 0

		// Find the longest number
		for (var p = 0; p < ds_list_size(valuelist); p++)
		{
			var value, valuedigits;
			value = sortlist_column_get(slist, valuelist[|p], slist.column_sort)
			valuedigits = string_natural_digits(string_lower(string(value)))
			naturaldigits = max(naturaldigits, valuedigits)
		}
		
		// Create sortable values
		for (var p = 0; p < ds_list_size(valuelist); p++)
		{
			var value, naturalvalue;
			value = sortlist_column_get(slist, valuelist[|p], slist.column_sort)
			naturalvalue = string_natural_value(string_lower(string(value)), naturaldigits)
			ds_list_add(sortedlist, naturalvalue)
		}
		ds_list_sort(sortedlist, !slist.sort_asc)
		
		// Find which values belong to what items
		while (ds_list_size(sortedlist) > 0)
		{
			for (var p = 0; p < ds_list_size(valuelist); p++)
			{
				var val, value, colval;
				val = valuelist[|p]
				value = sortlist_column_get(slist, val, slist.column_sort)
				colval = string_natural_value(string_lower(string(value)), naturaldigits)
				if (sortedlist[|0] = colval)
				{
					ds_list_add(slist.display_list, val)
					ds_list_delete(valuelist, p)
					ds_list_delete(sortedlist, 0)
					break
				}
			}
		}
		
		ds_list_destroy(sortedlist)
		ds_list_destroy(valuelist)
	}
	else
		ds_list_copy(slist.display_list, slist.list)
	
	// Remove non-matched items from list
	var check = string_lower(slist.search_tbx.text);
	if (slist.search && check != "")
	{
		var namelist, variantlist;
		namelist = []
		variantlist = []
		for (var p = 0; p < ds_list_size(slist.display_list); p++)
		{
			var value, match;
			value = slist.display_list[|p]
			match = script_execute(slist.script_search, slist, value, check)
			if (match = 0)
			{
				ds_list_delete(slist.display_list, p)
				p--
			}
			else if (slist.column_sort = null)
			{
				if (match >= 2)
					array_add(namelist, value, false)
				else
					array_add(variantlist, value, false)
			}
		}
		
		// Put direct name matches before variant matches when unsorted
		if (slist.column_sort = null)
		{
			ds_list_clear(slist.display_list)
			for (var i = 0; i < array_length(namelist); i++)
				ds_list_add(slist.display_list, namelist[i])
			for (var i = 0; i < array_length(variantlist); i++)
				ds_list_add(slist.display_list, variantlist[i])
		}
	}
	
	// Filter results
	if (!ds_list_empty(slist.filter_list))
	{
		for (var p = 0; p < ds_list_size(slist.display_list); p++)
		{
			var item, typename;
			item = slist.display_list[|p]
			typename = null
			if (item.object_index = obj_template)
				typename = temp_type_name_list[|item.type]
			else if (item.object_index = obj_resource)
				typename = res_type_name_list[|item.type]

			if (typename != null && ds_list_find_index(slist.filter_list, typename) = -1)
			{
				ds_list_delete(slist.display_list, p)
				p--
			}
		}
	}
}
