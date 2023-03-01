/// history_save_part_usage_tl(tl, hobj)
/// @arg tl
/// @arg hobj
/// @desc Saves usage of the model part in values like particle attraction, IK targets, etc.

function history_save_part_usage_tl(tl, hobj)
{
	var used = false;
	
	with (obj_timeline)
	{
		if (value[e_value.ATTRACTOR] = tl)
		{
			hobj.usage_tl_attractor_save_id[hobj.usage_tl_attractor_amount] = save_id
			hobj.usage_tl_attractor_part_save_id[hobj.usage_tl_attractor_amount] = tl.save_id
			hobj.usage_tl_attractor_amount++
			
			used = true
		}
		
		if (value[e_value.IK_TARGET] = tl)
		{
			hobj.usage_tl_ik_target_save_id[hobj.usage_tl_ik_target_amount] = save_id
			hobj.usage_tl_ik_target_part_save_id[hobj.usage_tl_ik_target_amount] = tl.save_id
			hobj.usage_tl_ik_target_amount++
			
			used = true
		}
		
		if (value[e_value.IK_TARGET_ANGLE] = tl)
		{
			hobj.usage_tl_ik_target_angle_save_id[hobj.usage_tl_ik_target_angle_amount] = save_id
			hobj.usage_tl_ik_target_angle_part_save_id[hobj.usage_tl_ik_target_angle_amount] = tl.save_id
			hobj.usage_tl_ik_target_angle_amount++
			
			used = true
		}
	}
	
	// Save references in keyframes
	with (obj_keyframe)
	{
		if (value[e_value.IK_TARGET] = tl)
		{
			hobj.usage_kf_ik_target_tl_save_id[hobj.usage_kf_ik_target_amount] = save_id_get(timeline)
			hobj.usage_kf_ik_target_tl_part_save_id[hobj.usage_kf_ik_target_amount] = tl.save_id
			hobj.usage_kf_ik_target_index[hobj.usage_kf_ik_target_amount] = ds_list_find_index(timeline.keyframe_list, id)
			hobj.usage_kf_ik_target_amount++
			
			used = true
		}
		
		if (value[e_value.IK_TARGET_ANGLE] = tl)
		{
			hobj.usage_kf_ik_target_angle_tl_save_id[hobj.usage_kf_ik_target_angle_amount] = save_id_get(timeline)
			hobj.usage_kf_ik_target_angle_tl_part_save_id[hobj.usage_kf_ik_target_angle_amount] = tl.save_id
			hobj.usage_kf_ik_target_angle_index[hobj.usage_kf_ik_target_angle_amount] = ds_list_find_index(timeline.keyframe_list, id)
			hobj.usage_kf_ik_target_angle_amount++
			
			used = true
		}
		
		if (value[e_value.ATTRACTOR] = tl)
		{
			hobj.usage_kf_attractor_tl_save_id[hobj.usage_kf_attractor_amount] = save_id_get(timeline)
			hobj.usage_kf_attractor_tl_part_save_id[hobj.usage_kf_attractor_amount] = tl.save_id
			hobj.usage_kf_attractor_index[hobj.usage_kf_attractor_amount] = ds_list_find_index(timeline.keyframe_list, id)
			hobj.usage_kf_attractor_amount++
			
			used = true
		}
	}
	
	return used
}

