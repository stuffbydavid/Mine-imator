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
			part_list = ds_list_create()
		
			if (other.model_file != null)
				for (var p = 0; p < ds_list_size(other.model_file.file_part_list); p++)
					ds_list_add(part_list, tl_new_part(other.model_file.file_part_list[|p]))
			
			tl_update_part_list(temp.model_file, id)
			break
		}
		
		case "block":
			texture_filtering = true
			break
			
		case "scenery":
		{
			texture_filtering = true
			
			// TODO add timelines
			break
		}
		
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

	tl_update()
	tl_value_spawn()
		
	return id
}
