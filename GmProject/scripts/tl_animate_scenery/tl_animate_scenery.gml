function tl_animate_scenery()
{
	var list = temp.scenery.scenery_tl_list;
	if (ds_list_valid(list))
	{
		if (part_list = null)
			part_list = ds_list_create()

		var used, parts;
		used = array_create(ds_list_size(list), false)
		parts = []

		for (var p = 0; p < ds_list_size(part_list); p++)
		{
			var part, match;
			part = part_list[|p]
			match = -1

			for (var i = 0; i < ds_list_size(list); i++)
			{
				var source = list[|i];
				if (part.type = e_tl_type.BLOCK)
				{
					if (source.model_name != "" || source.block.name != part.block_name)
						continue
				}
				else if (part.type = e_tl_type.SPECIAL_BLOCK)
				{
					if (source.model_name != part.model_name)
						continue
				}
				else
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
					match = i
					break
				}
			}

			if (match < 0)
				array_add(parts, part)
			else
				used[match] = true
		}

		if (array_length(parts) > 0)
		{
			var hobj = scenery_part_history;
			with (temp)
				temp_set_scenery(scenery, false, hobj, true, parts)
		}

		if (scenery_animate_create)
			for (var i = 0; i < ds_list_size(list); i++)
				if (!used[i])
					with (list[|i])
						block_animate(other.id)
	}

	if (placed)
		tl_mark_placed(true)
	
	scenery_animate = false
	scenery_animate_create = true
	scenery_part_history = null
}
