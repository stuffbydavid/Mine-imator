/// tl_duplicate()
/// @desc Duplicates the given timeline and children. Returns the new one.

copy = new(obj_timeline)
tl_copy(copy)

with (copy)
{
	rootcopy = null
	copy = null
	
	if (temp && !part_of)
		temp.count++
		
	for (var k = 0; k < keyframe_amount; k++)
	{
		var oldkf, newkf;
		oldkf = other.keyframe[k]
		newkf = new(obj_keyframe)
		newkf.pos = oldkf.pos
		newkf.tl = id
		newkf.index = k
		newkf.select = false
		newkf.sound_play_index = null
		for (var v = 0; v < values; v++)
			newkf.value[v] = oldkf.value[v]
		keyframe[k] = newkf
	}
	
	for (var t = 0; t < tree_amount; t++)
	{
		with (other.tree[t])
			other.tree[t] = tl_duplicate()
		tree[t].parent = id
	}
	
	for (var p = 0; p < part_amount; p++)
	{
		part[p] = other.part[p].copy
		part[p].part_of = id
	}
	
	tl_update_type_name()
	tl_update_display_name()
	tl_update_value_types()
	tl_update_rot_point()
	tl_update_values()
	tl_update_depth()
	
	if (type = "particles")
		particle_spawner_init()
}

return copy
