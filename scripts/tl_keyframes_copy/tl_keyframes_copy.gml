/// tl_keyframes_copy()

var minpos = null;
copy_kf_amount = 0
	
// Create new copies
with (obj_keyframe)
{
	if (!selected)
		continue
		
	app.copy_kf_tl_save_id[app.copy_kf_amount] = save_id_get(timeline)
	app.copy_kf_pos[app.copy_kf_amount] = position
	
	if (timeline.part_of != null)
		app.copy_kf_tl_part_of_save_id[app.copy_kf_amount] = save_id_get(timeline.part_of)
	else
		app.copy_kf_tl_part_of_save_id[app.copy_kf_amount] = save_id_get(timeline)
	app.copy_kf_tl_model_part_name[app.copy_kf_amount] = timeline.model_part_name
	
	for (var v = 0; v < e_value.amount; v++)
		app.copy_kf_value[app.copy_kf_amount, v] = tl_value_save(v, value[v])
		
	if (minpos = null || position < minpos)
		minpos = position
		
	app.copy_kf_amount++
	
}

// Align
for (var k = 0; k < copy_kf_amount; k++)
	copy_kf_pos[k] -= minpos
