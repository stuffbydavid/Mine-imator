/// tl_keyframes_copy()

var minpos = null;
copy_kf_amount = 0
	
// Create new copies
with (obj_keyframe)
{
	if (!select)
		continue
		
	app.copy_kf_tl[app.copy_kf_amount] = iid_get(tl)
	app.copy_kf_pos[app.copy_kf_amount] = pos
	
	if (tl.part_of)
	{
		app.copy_kf_tl_bodypart_of[app.copy_kf_amount] = iid_get(tl.part_of)
		app.copy_kf_tl_bodypart[app.copy_kf_amount] = tl.bodypart
	}
	else
	{
		app.copy_kf_tl_bodypart_of[app.copy_kf_amount] = iid_get(tl)
		app.copy_kf_tl_bodypart[app.copy_kf_amount] = null
	}
	
	for (var v = 0; v < values; v++)
		app.copy_kf_value[app.copy_kf_amount, v] = tl_value_save(v, value[v])
		
	if (minpos = null || pos < minpos)
		minpos = pos
		
	app.copy_kf_amount++
	
}

// Align
for (var k = 0; k < copy_kf_amount; k++)
	copy_kf_pos[k] -= minpos
