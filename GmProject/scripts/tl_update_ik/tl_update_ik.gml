/// CppGen ConstRef ikparts
/// CppGen array<int> ikparts
/// @desc Updates active IK and bone previews, then applies pending transforms in timeline order

function tl_update_ik(ikparts)
{
	var partcount = array_length(ikparts);
	if (partcount = 0)
		return 0
	
	// Apply pending transforms before reevaluating IK
	repeat (2)
	{
		for (var i = 0; i < partcount; i++)
			with (ikparts[i])
				if (value[e_value.IK_TARGET] != null || (debug_show_bones && selected) || ik_target_prev != null ||
					array_length(part_joints_matrix) > 0 || array_length(part_joints_pos) > 0 || array_length(part_joints_bone_matrix) > 0)
					tl_update_ik_calculate()
		
		var first = null;
		var firstindex = ds_list_size(app.project_timeline_list);
		for (var i = 0; i < partcount; i++)
		{
			with (ikparts[i])
			{
				if (update_matrix)
				{
					var index = ds_list_find_index(app.project_timeline_list, id);
					if (index >= 0 && index < firstindex)
					{
						first = id
						firstindex = index
					}
				}
			}
		}
		if (first = null)
			break

		with (first)
			tl_update_matrix(false, false)
	}
}
