/// CppSeparate void tl_update_ik(VarType)
/// @desc Updates active IK and bone previews, then applies pending transforms in timeline order

function tl_update_ik(parts)
{
	if (array_length(parts) = 0)
		return 0
	
	// Recursivly update IK data, break if positions are done moving
	repeat (2)
	{
		var update = false;
		
		for (var i = 0; i < array_length(parts); i++)
			if (parts[i] != null)
				with (parts[i])
					tl_update_ik_calculate()
		
		var first = null;
		var firstindex = ds_list_size(app.project_timeline_list);
		for (var i = 0; i < array_length(parts); i++)
		{
			with (parts[i])
			{
				if (update_matrix)
				{
					update = true
					var index = ds_list_find_index(app.project_timeline_list, id);
					if (index >= 0 && index < firstindex)
					{
						first = id
						firstindex = index
					}
				}
			}
		}
		if (first != null)
			with (first)
				tl_update_matrix(false, false)
		
		if (!update)
			break
	}
}
