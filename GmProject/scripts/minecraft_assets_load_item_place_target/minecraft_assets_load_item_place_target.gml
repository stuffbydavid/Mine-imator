/// minecraft_assets_load_item_place_target(map)
/// @arg map

function minecraft_assets_load_item_place_target(map)
{
	ds_map_clear(minecraft_item_place_target_map)
	if (!ds_map_valid(map))
		return

	var key = ds_map_find_first(map);
	while (!is_undefined(key))
	{
		var itemval, targetmap, parentaction;
		itemval = map[?key]
		targetmap = null

		if (is_string(itemval))
		{
			parentaction = null
			switch (itemval)
			{
				case "bow":		 parentaction = array(bow_parent_action_right, bow_parent_action_left) break
				case "tool":	 parentaction = array(tool_parent_action, tool_parent_action) break
				case "rod":		 parentaction = array(rod_parent_action, rod_parent_action) break
				case "crossbow": parentaction = array(crossbow_parent_action_right,crossbow_parent_action_left) break
				case "spear":	 parentaction = array(spear_parent_action, spear_parent_action) break
			}

			if (is_array(parentaction))
			{
				targetmap = ds_map_create()
				targetmap[?"right_arm"] = parentaction[0]
				targetmap[?"left_arm"] = parentaction[1]
			}
		}
		else if (ds_map_valid(itemval))
			targetmap = minecraft_assets_load_place_target(itemval)

		if (ds_map_valid(targetmap))
			ds_map_add_map(minecraft_item_place_target_map, key, targetmap)
			
		key = ds_map_find_next(map, key)
	}
}
