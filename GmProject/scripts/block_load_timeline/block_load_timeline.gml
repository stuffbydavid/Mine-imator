/// @desc Loads the data required to create a timeline for the block.

function block_load_timeline(map, typemap)
{
	timeline = (ds_map_size(map) > 1 || !ds_map_exists(map, "offset"))
	
	tl_type = value_get_string(map[?"type"], name)
	tl_facing = value_get_string(map[?"facing"], "")
	tl_build_transform = value_get_real(map[?"transform"], true)
	tl_hide_model = value_get_string(map[?"hide_model"], "")
		
	// Model to use
	if (is_string(map[?"model"]))
	{
		tl_model_name = map[?"model"]
		
		// Model state
		tl_model_state = []
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
					state_id = []
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
		tl_model_double = map[?"model_double"]
	
	// Animated setting
	tl_animated = value_get_real(map[?"animated"], false)
	tl_animated_parts = value_get_array(map[?"animated_parts"], [])
		
	// Text
	tl_has_text = false
	tl_text_front_position = []
	tl_text_front_rotation = []
	tl_text_front_scale = 1
	tl_text_back_position = []
	tl_text_back_rotation = []
	tl_text_back_scale = 1
	
	if (ds_map_valid(map[?"text"]))
	{
		var textmap = map[?"text"];
		
		if (ds_map_valid(textmap[?"front"]))
		{
			var front = textmap[?"front"];
			tl_text_front_position = value_get_point3D(front[?"position"], point3D(0))
			tl_text_front_rotation = value_get_point3D(front[?"rotation"], point3D(0))
			tl_text_front_scale = value_get_real(front[?"scale"], 1)
		}
		
		if (ds_map_valid(textmap[?"back"]))
		{
			var back = textmap[?"back"];
			tl_text_back_position = value_get_point3D(back[?"position"], point3D(0))
			tl_text_back_rotation = value_get_point3D(back[?"rotation"], point3D(0))
			tl_text_back_scale = value_get_real(back[?"scale"], 1)
		}
		
		tl_has_text = true
	}
	
	// Supports patterns
	tl_pattern_type = ""
	if (is_string(map[?"pattern_type"]))
		tl_pattern_type = map[?"pattern_type"]
	
	// Part state-to-transform mapping
	tl_parts = map[?"parts"]
	if (!ds_map_valid(tl_parts))
		tl_parts = null
	else  // Retain tl_parts map in memory
		ds_map_delete(map, "parts")
	
	// Rotation point
	var rotpointdata = block_load_timeline_transform(map[?"rotation_point"], typemap[?"rotation_point"], vec3(0));
	tl_rot_point = rotpointdata[0]
	tl_rot_point_state = rotpointdata[1]
	tl_rot_point_state_amount = array_length(tl_rot_point_state)

	// Position
	if (timeline)
		tl_position = vec3(0)

	var posdata = block_load_timeline_transform(map[?"position"], typemap[?"position"], tl_position);
	tl_position = posdata[0]
	tl_position_state = posdata[1]
	tl_position_state_amount = array_length(tl_position_state)

	// Offset
	var offsetdata = block_load_timeline_transform(map[?"offset"], typemap[?"offset"], vec3(0));
	tl_offset = offsetdata[0]
	tl_offset_state = offsetdata[1]
	tl_offset_state_amount = array_length(tl_offset_state)

	// Rotation
	var rotdata = block_load_timeline_transform(map[?"rotation"], typemap[?"rotation"], vec3(0));
	tl_rotation = rotdata[0]
	tl_rotation_state = rotdata[1]
	tl_rotation_state_amount = array_length(tl_rotation_state)
}
