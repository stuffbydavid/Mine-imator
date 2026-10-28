/// @desc Adds a block at a position and returns the previous block/state ID, or null if unchanged or unavailable.
/// @arg x
/// @arg y
/// @arg z
/// @arg [blockid]
/// @arg [stateid]

function tl_add_block(xx, yy, zz, blockid = 0, stateid = 0)
{
	if (type != e_tl_type.SCENERY || temp = null || temp.scenery = null || !temp.scenery.ready)
		return null

	// Valid block
	if (blockid < 0 || blockid >= array_length(block_objs) || (blockid != 0 && block_objs[blockid] = null))
		return null

	// Valid position
	var res, rep, blockpos;
	res = temp.scenery
	rep = temp.block_repeat_enable ? temp.block_repeat : vec3(1)
	blockpos = vec3(xx, yy, zz)
	
	for (var a = X; a <= Z; a++)
	{
		if (blockpos[a] < 0 || blockpos[a] >= res.scenery_size[a] * rep[a])
			return null
	}

	return tl_update_block_meshes(blockpos, blockid, stateid)
}
