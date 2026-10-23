function tl_update_ik(parts)
{
	if (array_length(parts) = 0)
		return 0
	
	var profile = debug_profiler_begin("Inverse kinematics");

	// Recursivly update IK data, break if positions are done moving
	repeat (2)
	{
		var update = false;
		
		for (var i = 0; i < array_length(parts); i++)
			if (parts[i] != null)
				with (parts[i])
					tl_update_ik_calculate()
		
		for (var i = 0; i < array_length(parts); i++)
		{
			if (parts[i] != null && parts[i].update_matrix)
			{
				update = true
				break
			}
		}
		
		if (!update)
			break

		// Resolve all dirty IK parts and their children in one parent-first pass
		with (app)
			tl_update_matrix(false, false)
	}
	debug_profiler_end("Inverse kinematics", profile)
}
