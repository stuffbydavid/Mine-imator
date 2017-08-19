/// tl_duplicate()
/// @desc Duplicates the given timeline and children. Returns the new one.

copy = new(obj_timeline)
tl_copy(copy)

with (copy)
{
	root_copy = null
	copy = null
	
	if (temp && part_of = null)
		temp.count++
		
	// Copy keyframes
	for (var k = 0; k < ds_list_size(other.keyframe_list); k++)
	{
		var oldkf, newkf;
		oldkf = other.keyframe_list[|k]
		newkf = new(obj_keyframe)
		newkf.position = oldkf.position
		newkf.timeline = id
		newkf.selected = false
		newkf.sound_play_index = null
		for (var v = 0; v < values; v++)
			newkf.value[v] = oldkf.value[v]
		ds_list_add(keyframe_list, newkf)
	}
	
	// Copy tree structure
	for (var t = 0; t < ds_list_size(other.tree_list); t++)
	{
		with (other.tree_list[|t])
			ds_list_add(other.tree_list, tl_duplicate())
		tree_list[|t].parent = id
	}
	
	// Copy body part references
	for (var p = 0; p < ds_list_size(other.part_list); p++)
	{
		part_list[|p] = other.part[p].copy
		part_list[|p].part_of = id
	}
	
	tl_update_type_name()
	tl_update_display_name()
	tl_update_value_types()
	tl_update_rot_point()
	tl_update_values()
	tl_update_depth()
	
	if (type = "particles")
		particle_spawner_init()
		
	return id
}