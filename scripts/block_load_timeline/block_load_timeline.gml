/// block_load_timeline(map)
/// @arg map
/// @desc Loads the data required to create a timeline for the block

var map = argument0;

timeline = true
		
// Model to use
if (is_string(map[?"model"]))
{
	tl_model_name = map[?"model"]
	
	// Model state
	tl_model_state = ""
	tl_model_state_amount = 0
	if (is_string(map[?"model_state"]))
		tl_model_state = map[?"model_state"]
	else if (ds_map_valid(map[?"model_state"])) // Determined by block state
	{
		var key = ds_map_find_first(map[?"model_state"]);
		while (!is_undefined(key))
		{
			with (new(obj_block_tl_state))
			{
				state_map = ds_map_create()
				state_vars_string_to_map(key, state_map)
				value = ds_map_find_value(map[?"model_state"], key)
				other.tl_model_state[other.tl_model_state_amount++] = id
			}
			key = ds_map_find_next(map[?"model_state"], key)
		}
	}
}
else // Uses own block model with default state
	tl_model_name = ""
		
// Rotation point (block model only)
tl_rot_point = point3D(0, 0, 0)
tl_rot_point_state_amount = 0
if (is_array(map[?"rotation_point"]))
	tl_rot_point = map[?"rotation_point"]
else if (ds_map_valid(map[?"rotation_point"])) // Determined by state
{
	var key = ds_map_find_first(map[?"rotation_point"]);
	while (!is_undefined(key))
	{
		with (new(obj_block_tl_state))
		{
			state_map = ds_map_create()
			state_vars_string_to_map(key, state_map)
			var vallist = ds_map_find_value(map[?"rotation_point"], key)
			if (ds_list_valid(vallist))
				value = array(vallist[|X], vallist[|Z], vallist[|Y])
			else
				value = point3D(0, 0, 0)
			other.tl_rot_point_state[other.tl_rot_point_state_amount++] = id
		}
		key = ds_map_find_next(map[?"rotation_point"], key)
	}
}
		
// Position
tl_position = point3D(0, 0, 0)
tl_position_state_amount = 0
if (is_array(map[?"position"]))
	tl_position = map[?"position"]
else if (ds_map_valid(map[?"position"])) // Determined by state
{
	var key = ds_map_find_first(map[?"position"]);
	while (!is_undefined(key))
	{
		with (new(obj_block_tl_state))
		{
			state_map = ds_map_create()
			state_vars_string_to_map(key, state_map)
			var vallist = ds_map_find_value(map[?"position"], key)
			if (ds_list_valid(vallist))
				value = array(vallist[|X], vallist[|Z], vallist[|Y])
			else
				value = point3D(0, 0, 0)
			other.tl_position_state[other.tl_position_state_amount++] = id
		}
		key = ds_map_find_next(map[?"position"], key)
	}
}
		
// Rotation
tl_rotation = point3D(0, 0, 0)
tl_rotation_state_amount = 0
if (is_array(map[?"rotation"]))
	tl_rotation = map[?"rotation"]
else if (ds_map_valid(map[?"rotation"])) // Determined by state
{
	var key = ds_map_find_first(map[?"rotation"]);
	while (!is_undefined(key))
	{
		with (new(obj_block_tl_state))
		{
			state_map = ds_map_create()
			state_vars_string_to_map(key, state_map)
			var vallist = ds_map_find_value(map[?"rotation"], key)
			if (ds_list_valid(vallist))
				value = array(vallist[|X], vallist[|Z], vallist[|Y])
			else
				value = vec3(0, 0, 0)
			other.tl_rotation_state[other.tl_rotation_state_amount++] = id
		}
		key = ds_map_find_next(map[?"rotation"], key)
	}
}

// TODO create preview vbuffer