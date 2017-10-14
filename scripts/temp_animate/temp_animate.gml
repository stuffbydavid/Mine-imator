/// temp_animate()
/// @desc Adds a new timeline from the template.

count++

with (new(obj_timeline))
{
	type = other.type
	temp = other.id
	
	tl_set_parent_root()
	
	switch (type)
	{
		case e_temp_type.CHARACTER:
		case e_temp_type.SPECIAL_BLOCK:
		{
			part_list = ds_list_create()
			if (temp.model_file != null)
			{
				for (var p = 0; p < ds_list_size(temp.model_file.file_part_list); p++)
				{
					var part = temp.model_file.file_part_list[|p];
					if (temp.model_hide_list = null || ds_list_find_index(temp.model_hide_list, part.name) = -1)
						ds_list_add(part_list, tl_new_part(part))
				}
				tl_update_part_list(temp.model_file, id)
			}
			break
		}
		
		case e_temp_type.BLOCK:
			texture_filtering = true
			break
			
		case e_temp_type.SCENERY:
		{
			texture_filtering = true
			
			if (temp.scenery != null)
			{
				if (temp.scenery.ready)
					tl_animate_scenery()
				else
					scenery_animate = true
			}
			
			break
		}
		
		case e_temp_type.BODYPART:
		{
			model_part = temp.model_part 
			if (model_part != null)
				model_part_name = model_part.name
			else
				model_part_name = ""
			break
		}
		
		case e_temp_type.SURFACE:
			backfaces = true
			break
	}

	tl_update()
	tl_value_spawn()
		
	return id
}
