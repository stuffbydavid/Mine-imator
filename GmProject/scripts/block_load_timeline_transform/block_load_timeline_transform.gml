/// @desc Loads a timeline transform value and state rules as [ default, rules ].
/// @arg value
/// @arg datatype
/// @arg default

function block_load_timeline_transform(data, datatype, def)
{
	var states = [];
	if (datatype = e_json_type.ARRAY)
		def = value_get_point3D(data, def)
	else if (datatype = e_json_type.OBJECT)
	{
		// Retain the source order for first-match state lookups
		var key = ds_map_find_first(data);
		while (!is_undefined(key))
		{
			with (new_obj(obj_block_tl_state))
			{
				vars = string_get_state_vars(key)
				value = value_get_point3D(data[?key], vec3(0))

				// Precompute the block states matched by this rule
				state_id = []
				for (var i = 0; i < other.state_id_amount; i++)
					if (state_vars_match_state_id(vars, other.id, i))
						state_id = array_add(state_id, i)

				states = array_add(states, id, false)
			}

			key = ds_map_find_next(data, key)
		}
	}

	return [ def, states ]
}
