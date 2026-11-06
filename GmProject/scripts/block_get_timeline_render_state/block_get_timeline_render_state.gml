/// @desc Returns the state used by a timeline's render model.
/// @arg block
/// @arg stateid

function block_get_timeline_render_state(block, stateid)
{
	var vars = block_get_state_id_state_vars(block, stateid);
	if (block.tl_model_name = "")
	{
		var defstate, trstates;
		defstate = block_get_state_id(block, block.default_state)
		trstates = [ "facing", "face", "half", "hinge", "open", "location", "direction", "rotation", "in_wall" ]
		
		for (var s = 0; s < array_length(trstates); s++)
		{
			var val = block_get_state_id_value(block, defstate, trstates[s]);
			if (!is_undefined(val))
				state_vars_set_value(vars, trstates[s], val)
		}
	}

	return vars
}
