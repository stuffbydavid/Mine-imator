function tl_animate_scenery()
{
	var list, hobj;
	list = temp.scenery.scenery_tl_list
	hobj = scenery_part_history

	if (ds_list_valid(list))
	{
		if (part_list = null)
			part_list = ds_list_create()

		var used, parts;
		used = array_create(ds_list_size(list), false)
		parts = []

		for (var p = 0; p < ds_list_size(part_list); p++)
		{
			var part, match, posmatch;
			part = part_list[|p]
			match = -1
			posmatch = -1

			for (var i = 0; i < ds_list_size(list); i++)
			{
				var source = list[|i];
				if (part.type != e_tl_type.BLOCK && part.type != e_tl_type.SPECIAL_BLOCK)
					continue

				if (used[i])
					continue

				var xx, yy, zz;
				xx = source.position[Y]
				yy = temp.scenery.scenery_size[Y] * block_size - source.position[X]
				zz = source.position[Z]

				if (abs(part.value_default[e_value.POS_X] - xx) < 0.01 &&
					abs(part.value_default[e_value.POS_Y] - yy) < 0.01 &&
					abs(part.value_default[e_value.POS_Z] - zz) < 0.01)
				{
					// Keep a changed block matched to its original position
					if (posmatch < 0)
						posmatch = i

					if (part.type = e_tl_type.BLOCK)
					{
						if (source.model_name != "" || source.block.name != part.block_name)
							continue
					}
					else if (source.model_name != part.model_name)
						continue

					match = i
					break
				}
			}

			if (match < 0)
				match = posmatch

			if (match < 0)
				array_add(parts, part)
			else
				used[match] = true
		}

		if (array_length(parts) > 0)
		{
			var savehobj = hobj;
			if (savehobj = history_data)
				savehobj = null

			with (temp)
				temp_set_scenery(scenery, false, savehobj, true, parts)
		}

		if (scenery_animate_create)
		{
			for (var i = 0; i < ds_list_size(list); i++)
			{
				if (used[i])
					continue
					
				// Leave missing timelines when their option stayed enabled
				if (hobj != null && hobj.script = action_res_block_settings)
				{
					var source, tltype;
					source = list[|i]
					tltype = ""
					
					if (source.model_name != "")
						tltype = mc_assets.model_name_map[?source.model_name].entity_tl_type
					
					if (tltype = "")
						tltype = source.block.tl_type

					if (hobj.old_tl_all_types || array_contains(hobj.old_tl_types, tltype))
						continue
				}

				with (list[|i])
					block_animate(other.id)
			}
		}
	}

	if (placed)
		tl_mark_placed(true)
	
	scenery_animate = false
	scenery_animate_create = true
	scenery_part_history = null
}
