/// tl_update_ik(parts)
/// @arg parts

function tl_update_ik(parts)
{
	if (array_length(parts) = 0)
		return 0
	
	// Recursivly update IK data, break if positions are done moving
	repeat (2)
	{
		var update = false
		
		for (var i = 0; i < array_length(parts); i++)
			if (parts[i] != null)
				with (parts[i])
					tl_update_ik_calculate()
		
		for (var i = 0; i < array_length(parts); i++)
		{
			with (parts[i])
			{
				if (update_matrix)
				{
					update = true
					tl_update_matrix(false, false)
				}
			}
		}
		
		if (!update)
			break
	}
}
