/// temp_animate()
/// @desc Adds a new timeline from the template.

count++

with (new(obj_timeline))
{
	type = other.type
	temp = other.id
	
	tl_parent_root()
	
	switch (type)
	{
		case "char":
		case "spblock":
			new_tl_model_file_parts(id, other.char_model_file)
			break

		case "block":
		case "scenery":
			texture_filtering = true
			break
		
		case "bodypart":
			bodypart = temp.char_bodypart 
			break
	
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
