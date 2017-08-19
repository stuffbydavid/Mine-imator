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
		case "char":
		case "spblock":
		{
			if (other.model_file != null)
				for (var p = 0; p < ds_list_size(other.model_file.file_part_list); p++)
					tl_new_part(other.model_file.file_part_list[|p])
			
			tl_update_part_list(temp.model_file, id)
			break
		}
		
		case "block":
		case "scenery":
			texture_filtering = true
			break
		
		case "bodypart":
		{
			model_part = temp.model_part 
			if (model_part != null)
				model_part_name = model_part.name
			else
				model_part_name = ""
			break
		}
		
		case "text":
		case "surface":
			backfaces = true
			break
	}

	tl_value_spawn()
	tl_update_value_types()
	tl_update_rot_point()
	tl_update_type_name()
	tl_update_display_name()
	tl_update_depth()
	
	if (type = "particles")
		particle_spawner_init()
		
	return id
}
