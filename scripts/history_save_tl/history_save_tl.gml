/// history_save_tl(timeline)
/// @arg timeline
/// @desc Saves a timeline in memory.

var tl, save;
tl = argument0
save = new(obj_history_save)
save.hobj = id

with (tl)
	tl_copy(save)
	
with (save)
{
	iid = tl.iid
	temp = iid_get(temp)
	for (var v = 0; v < values; v++)
		value_default[v] = tl_value_save(v, tl.value_default[v])
		
	for (var k = 0; k < keyframe_amount; k++)
	{
		with (tl.keyframe[k])
		{
			save.kf_pos[k] = pos
			for (var v = 0; v < values; v++)
				save.kf_value[k, v] = tl_value_save(v, value[v])
		}
	}
	parent = iid_get(parent)
	part_of = iid_get(part_of)
	
	// Save references in templates
	usage_temp_shape_tex_amount = 0
	with (obj_template)
	{
		if (shape_tex != tl)
			continue
		save.usage_temp_shape_tex[save.usage_temp_shape_tex_amount] = iid
		save.usage_temp_shape_tex_amount++
	}
	
	// Save references in timelines
	usage_tl_texture_amount = 0
	usage_tl_attractor_amount = 0
	with (obj_timeline)
	{
		if (value[TEXTUREOBJ] = tl)
		{
			save.usage_tl_texture[save.usage_tl_texture_amount] = iid
			save.usage_tl_texture_amount++
		}
		if (value[ATTRACTOR] = tl)
		{
			save.usage_tl_attractor[save.usage_tl_attractor_amount] = iid
			save.usage_tl_attractor_amount++
		}
	}
	
	// Save references in keyframe_amount
	usage_kf_texture_amount = 0
	usage_kf_attractor_amount = 0
	with (obj_keyframe)
	{
		if (value[TEXTUREOBJ] = tl)
		{
			save.usage_kf_texture_tl[save.usage_kf_texture_amount] = iid_get(id.tl)
			save.usage_kf_texture_index[save.usage_kf_texture_amount] = index
			save.usage_kf_texture_amount++
		}
		if (value[ATTRACTOR] = tl)
		{
			save.usage_kf_attractor_tl[save.usage_kf_attractor_amount] = iid_get(id.tl)
			save.usage_kf_attractor_index[save.usage_kf_attractor_amount] = index
			save.usage_kf_attractor_amount++
		}
	}
}

// Save recursively
for (var t = 0; t < save.tree_amount; t++)
	save.tree[t] = history_save_tl(tl.tree[t])

return save
