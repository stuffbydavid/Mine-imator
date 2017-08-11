/// block_set_chorus_plant()
/// @desc Connects to other chorus plants, chorus flowers and end stone below.

for (var d = 0; d <= e_dir.amount; d++)
{
	var dstr = dir_get_string(d);
	vars[?dstr] = "false"

	if (build_edge[d])
		continue
		
	// Check for chorus plant/flower
	var block = array3D_get(block_obj, point3D_add(build_pos, dir_get_vec3(d)));
	if (is_undefined(block)) // Skip air
		continue
		
	if (block = block_current || block.type = "chorus_plant_connect")
	{
		vars[?dstr] = "true"
		continue
	}
	
	// Check for end stone
	if (d = e_dir.DOWN)
	{
		block = array3D_get(block_obj, point3D_add(build_pos, dir_get_vec3(d)));
		if (!is_undefined(block) && block.name = "end_stone")
			vars[?dstr] = "true"
	}
}

return 0