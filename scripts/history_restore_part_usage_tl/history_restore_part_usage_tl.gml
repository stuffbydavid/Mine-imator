/// history_restore_part_usage_tl(hobj)
/// @arg hobj

function history_restore_part_usage_tl(hobj)
{	
	var tl, kfindex;
	
	with (hobj)
	{
		// Restore references in timelines
		for (var i = 0; i < usage_tl_attractor_amount; i++)
		{
			tl = save_id_find(usage_tl_attractor_save_id[i])
			tl.value[e_value.ATTRACTOR] = save_id_find(usage_tl_attractor_part_save_id[i])
		}
		
		for (var i = 0; i < usage_tl_ik_target_amount; i++)
		{
			tl = save_id_find(usage_tl_ik_target_save_id[i])
			tl.value[e_value.IK_TARGET] = save_id_find(usage_tl_ik_target_part_save_id[i])
		}
		
		for (var i = 0; i < usage_tl_ik_target_angle_amount; i++)
		{
			tl = save_id_find(usage_tl_ik_target_angle_save_id[i])
			tl.value[e_value.IK_TARGET_ANGLE] = save_id_find(usage_tl_ik_target_angle_part_save_id[i])
		}
		
		// Restore references in keyframes
		for (var i = 0; i < usage_kf_attractor_amount; i++)
		{
			tl = save_id_find(usage_kf_attractor_tl_save_id[i])
			kfindex = usage_kf_attractor_index[i]
			tl.keyframe_list[|kfindex].value[e_value.ATTRACTOR] = save_id_find(usage_kf_attractor_tl_part_save_id[i])
		}
		
		for (var i = 0; i < usage_kf_ik_target_amount; i++)
		{
			tl = save_id_find(usage_kf_ik_target_tl_save_id[i])
			kfindex = usage_kf_ik_target_index[i]
			tl.keyframe_list[|kfindex].value[e_value.IK_TARGET] = save_id_find(usage_kf_ik_target_tl_part_save_id[i])
		}
		
		for (var i = 0; i < usage_kf_ik_target_angle_amount; i++)
		{
			tl = save_id_find(usage_kf_ik_target_angle_tl_save_id[i])
			kfindex = usage_kf_ik_target_angle_index[i]
			tl.keyframe_list[|kfindex].value[e_value.IK_TARGET_ANGLE] = save_id_find(usage_kf_ik_target_tl_part_save_id[i])
		}
	}
}