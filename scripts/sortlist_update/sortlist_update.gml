/// sortlist_update(sortlist)
/// @arg sortlist
/// @desc Updates the sortlist when sorting or filtering.

var slist = argument0;
ds_list_clear(slist.display_list)

if (slist.column_sort != null)
{
	var sortedlist, valuelist;
	sortedlist = ds_list_create()
	valuelist = ds_list_create()
	ds_list_copy(valuelist, slist.list)
	
	// Store values in column and sort
	for (var p = 0; p < ds_list_size(valuelist); p++)
		ds_list_add(sortedlist, string_lower(sortlist_column_get(slist, valuelist[|p], slist.column_sort)))
	ds_list_sort(sortedlist, !slist.sort_asc)
	
	// Find which values belong to what items
	while (ds_list_size(sortedlist) > 0)
	{
		for (var p = 0; p < ds_list_size(valuelist); p++)
		{
			var val, colval;
			val = valuelist[|p]
			colval = string_lower(sortlist_column_get(slist, val, slist.column_sort))
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
if (slist.search && check != "" && (slist != bench_settings.block_list && slist != template_editor.block_list))
{
	for (var p = 0; p < ds_list_size(slist.display_list); p++)
	{
		var val, match;
		val = slist.display_list[|p]
		match = false
		for (var c = 0; c < slist.columns; c++)
		{
			if (string_count(check, string_lower(string(sortlist_column_get(slist, val, c)))) > 0)
			{
				match = true
				break
			}
		}
		
		if (!match)
		{
			ds_list_delete(slist.display_list, p)
			p--
		}
	}
}
else if (slist.search && check != "" && (slist = bench_settings.block_list || slist = template_editor.block_list)) // If variant types contain name, include base block(Block list)
{
	for (var p = 0; p < ds_list_size(slist.display_list); p++)
	{
		var baseblock, match;
		baseblock = slist.display_list[|p]
		match = false
		
		// Variant search
		if (setting_search_variants)
		{
			var blockobj = mc_assets.block_name_map[?baseblock];
			var variantmatch = false;
		
			var statearr = array_copy_1d(blockobj.default_state);
			var statelen = array_length_1d(statearr);
		
			// Search for matching variants
			for (var i = 0; i < statelen; i += 2)
			{
				var state = statearr[i];
				var statename = text_get("blockstate" + state);
			
				var statecurrent = blockobj.states_map[?state];
			
				for (var s = 0; s < statecurrent.value_amount; s++)
				{
					if (string_count(check, string_lower(minecraft_asset_get_name("blockstatevalue", statecurrent.value_name[s]))) > 0)
					{
						variantmatch = true
						break
					}
				}
			
				if (string_count(check, string_lower(statename)) > 0)
					variantmatch = true
			
				if (variantmatch)
					break
			}
			
			match = variantmatch
		}
		
		if (!match && string_count(check, string_lower(minecraft_asset_get_name("block", baseblock))) > 0)
			match = true
		
		if (!match)
		{
			ds_list_delete(slist.display_list, p)
			p--
		}
	}
}

// Filter results
if (!ds_list_empty(slist.filter_list))
{
	for (var p = 0; p < ds_list_size(slist.display_list); p++)
	{
		var item = slist.display_list[|p];
		
		// Library filter (type)
		if (settings_menu_sortlist = app.properties.library.list)
		{
			if (ds_list_find_index(slist.filter_list, temp_type_name_list[|item.type]) = -1)
			{
				ds_list_delete(slist.display_list, p)
				p--
			}
		}
		
		// Resource filter (type)
		if (settings_menu_sortlist = app.properties.resources.list)
		{
			if (ds_list_find_index(slist.filter_list, res_type_name_list[|item.type]) = -1)
			{
				ds_list_delete(slist.display_list, p)
				p--
			}
		}
	}
}
