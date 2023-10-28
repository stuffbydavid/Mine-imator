/// sortlist_update(sortlist)
/// @arg sortlist
/// @desc Updates the sortlist when sorting or filtering.

function sortlist_update(slist)
{
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
	var modellist = (slist = bench_settings.char_list || slist = bench_settings.special_block_list || slist = bench_settings.bodypart_model_list ||
					slist = template_editor.char_list || slist = template_editor.special_block_list || slist = template_editor.bodypart_model_list);
	var blocklist = (slist = bench_settings.block_list || slist = template_editor.block_list);
	if (slist.search && check != "" && !blocklist && !modellist)
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
	else if (slist.search && check != "" && blocklist) // Check block variants
	{
		for (var p = 0; p < ds_list_size(slist.display_list); p++)
		{
			var name, match;
			name = slist.display_list[|p]
			match = false
			
			// Variant search
			var block = mc_assets.block_name_map[?name];
		
			// Search for matching variants
			for (var i = 0; i < array_length(block.default_state) && !match; i += 2)
			{
				var state = block.default_state[i];
				var statecurrent = block.states_map[?state];
				
				for (var s = 0; s < statecurrent.value_amount && !match; s++)
					if (string_count(check, string_lower(minecraft_asset_get_name("blockstatevalue", statecurrent.value_name[s]))) > 0)
						match = true
				
				if (string_count(check, string_lower(text_get("blockstate" + state))) > 0)
					match = true
			}
			
			
			if (!match && string_count(check, string_lower(minecraft_asset_get_name("block", name))) > 0)
				match = true
			
			if (!match)
			{
				ds_list_delete(slist.display_list, p)
				p--
			}
		}
	}
	else if (slist.search && check != "" && modellist) // Check model variants
	{
		for (var p = 0; p < ds_list_size(slist.display_list); p++)
		{
			var name, match;
			name = slist.display_list[|p]
			match = false
			
			// Variant search
			var model = mc_assets.model_name_map[?name];
			
			// Search for matching variants
			for (var i = 0; i < array_length(model.default_state) && !match; i += 2)
			{
				var state = model.default_state[i];
				var statecurrent = model.states_map[?state];
				
				for (var s = 0; s < statecurrent.value_amount && !match; s++)
					if (string_count(check, string_lower(minecraft_asset_get_name("modelstatevalue", statecurrent.value_name[s]))) > 0)
						match = true
				
				if (string_count(check, string_lower(text_get("modelstate" + state))) > 0)
					match = true
			}
			
			if (!match && string_count(check, string_lower(minecraft_asset_get_name("model", name))) > 0)
				match = true
			
			if (!match)
			{
				ds_list_delete(slist.display_list, p)
				p--
			}
		}
	}
	
	// Put name matches first in block/model search
	if (slist.column_sort = null && slist.search && check != "" && (blocklist || modellist))
	{
		var namelist, variantlist;
		namelist = []
		variantlist = []
		
		for (var i = 0; i < ds_list_size(slist.display_list); i++)
		{
			if (string_contains(string_lower(string(sortlist_column_get(slist, slist.display_list[|i], 0))), check))
				array_add(namelist, slist.display_list[|i])
			else
				array_add(variantlist, slist.display_list[|i])
		}
		
		ds_list_clear(slist.display_list)
		
		for (var i = 0; i < array_length(namelist); i++)
			ds_list_add(slist.display_list, namelist[i])
		
		for (var i = 0; i < array_length(variantlist); i++)
			ds_list_add(slist.display_list, variantlist[i])
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
}
