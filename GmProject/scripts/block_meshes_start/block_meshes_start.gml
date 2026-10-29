function block_meshes_start(keepblocks = false)
{
	var count = block_meshes_size[X] * block_meshes_size[Y] * block_meshes_size[Z];
	
	if (!keepblocks)
	{
		block_meshes_destroy()
		block_meshes = array_create(count, null)
	}

	var batching = true;
	for (var s = 0; s < count; s++)
	{
		if (is_array(block_meshes_active) && !block_meshes_active[s])
			continue

		var mesh = block_meshes[s];
		if (mesh = null)
		{
			mesh = new_obj(obj_block_mesh)
			block_meshes[@s] = mesh
		}

		for (var d = 0; d < e_block_depth.amount; d++)
		for (var vb = 0; vb < e_block_vbuffer.amount; vb++)
		{
			var index = d * e_block_vbuffer.amount + vb;
			mesh.block_vbuffer[@index] = vbuffer_start()
			vbuffer_set_batching(mesh.block_vbuffer[@index], batching)
		}
	}

	block_meshes_active = null
	mc_builder.block_meshes = block_meshes
	mc_builder.block_meshes_size = block_meshes_size
}
