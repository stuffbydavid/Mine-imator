/// block_load_timeline(map, typemap)
/// @arg map
/// @arg typemap
/// @desc Loads the data required to create a timeline for the block

function block_load_timeline(map, typemap)
{
	timeline = true
		
	// Model to use
	if (is_string(map[?"model"]))
	{
		tl_model_name = map[?"model"]
		
		// Model state
		tl_model_state = array()
		tl_model_state_amount = 0
		tl_has_model_state = false
		
		if (typemap[?"model_state"] = e_json_type.STRING)
		{
			tl_model_state = string_get_state_vars(map[?"model_state"])
			tl_has_model_state = true
		}
		else if (typemap[?"model_state"] = e_json_type.OBJECT) // Determined by block state
		{
			var key = ds_map_find_first(map[?"model_state"]);
			while (!is_undefined(key))
			{
				with (new_obj(obj_block_tl_state))
				{
					vars = string_get_state_vars(key)
					value = string_get_state_vars(ds_map_find_value(map[?"model_state"], key))
					
					// Apply to matching state IDs
					state_id = array()
					for (var i = 0; i < other.state_id_amount; i++)
						if (state_vars_match_state_id(vars, other.id, i))
							state_id = array_add(state_id, i)
					
					other.tl_model_state[other.tl_model_state_amount++] = id
				}
				
				key = ds_map_find_next(map[?"model_state"], key)
			}
			
			tl_has_model_state = true
		}
	}
	else // Uses own block model with default state
	{
		tl_model_name = ""
		tl_has_model_state = false
	}
	
	// Render block model with timeline model?
	if (is_bool(map[?"model_double"]))
		model_double = map[?"model_double"]
	
	// Text
	tl_has_text = false
	if (is_bool(map[?"has_text"]))
		tl_has_text = map[?"has_text"]
	
	if (tl_has_text)
		tl_text_position = value_get_point3D(map[?"text_position"], point3D(0, 0, 0))
	
	// Is a banner
	tl_is_banner = false
	if (is_bool(map[?"is_banner"]))
		tl_is_banner = map[?"is_banner"]
	
	// Rotation point
	tl_rot_point = point3D(0, 0, 0)
	tl_rot_point_state_amount = 0
	if (typemap[?"rotation_point"] = e_json_type.ARRAY)
		tl_rot_point = value_get_point3D(map[?"rotation_point"], point3D(0, 0, 0))
	else if (typemap[?"rotation_point"] = e_json_type.OBJECT) // Determined by state
	{
		var key = ds_map_find_first(map[?"rotation_point"]);
		while (!is_undefined(key))
		{
			with (new_obj(obj_block_tl_state))
			{
				vars = string_get_state_vars(key)
				value = value_get_point3D(ds_map_find_value(map[?"rotation_point"], key), point3D(0, 0, 0))
				
				// Apply to matching state IDs
				state_id = array()
				for (var i = 0; i < other.state_id_amount; i++)
					if (state_vars_match_state_id(vars, other.id, i))
						state_id = array_add(state_id, i)
				
				other.tl_rot_point_state[other.tl_rot_point_state_amount++] = id
			}
			
			key = ds_map_find_next(map[?"rotation_point"], key)
		}
	}
	
	// Position
	tl_position = point3D(0, 0, 0)
	tl_position_state_amount = 0
	if (typemap[?"position"] = e_json_type.ARRAY)
		tl_position = value_get_point3D(map[?"position"], point3D(0, 0, 0))
	else if (typemap[?"position"] = e_json_type.OBJECT) // Determined by state
	{
		var key = ds_map_find_first(map[?"position"]);
		while (!is_undefined(key))
		{
			with (new_obj(obj_block_tl_state))
			{
				vars = string_get_state_vars(key)
				value = value_get_point3D(ds_map_find_value(map[?"position"], key), point3D(0, 0, 0))
				
				// Apply to matching state IDs
				state_id = array()
				for (var i = 0; i < other.state_id_amount; i++)
					if (state_vars_match_state_id(vars, other.id, i))
						state_id = array_add(state_id, i)
				
				other.tl_position_state[other.tl_position_state_amount++] = id
			}
			
			key = ds_map_find_next(map[?"position"], key)
		}
	}
	
	// Rotation
	tl_rotation = point3D(0, 0, 0)
	tl_rotation_state_amount = 0
	if (typemap[?"rotation"] = e_json_type.ARRAY)
		tl_rotation = value_get_point3D(map[?"rotation"], point3D(0, 0, 0))
	else if (typemap[?"rotation"] = e_json_type.OBJECT) // Determined by state
	{
		var key = ds_map_find_first(map[?"rotation"]);
		while (!is_undefined(key))
		{
			with (new_obj(obj_block_tl_state))
			{
				vars = string_get_state_vars(key)
				value = value_get_point3D(ds_map_find_value(map[?"rotation"], key), point3D(0, 0, 0))
				
				// Apply to matching state IDs
				state_id = array()
				for (var i = 0; i < other.state_id_amount; i++)
					if (state_vars_match_state_id(vars, other.id, i))
						state_id = array_add(state_id, i)
				
				other.tl_rotation_state[other.tl_rotation_state_amount++] = id
			}
			
			key = ds_map_find_next(map[?"rotation"], key)
		}
	}
}
