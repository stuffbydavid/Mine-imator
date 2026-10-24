function block_meshes_start()
{
	block_meshes_destroy()

	var count = block_meshes_size[X] * block_meshes_size[Y] * block_meshes_size[Z];
	block_meshes = array_create(count, null)

	for (var s = 0; s < count; s++)
	{
		if (is_array(block_meshes_active) && !block_meshes_active[s])
			continue

		var mesh = new_obj(obj_block_mesh);
		mesh.block_vbuffer = array_create(e_block_depth.amount * e_block_vbuffer.amount, null)
		mesh.block_vbuffer_active = array_create(e_block_depth.amount * e_block_vbuffer.amount, false)
		mesh.block_vbuffer_depth_active = array_create(e_block_depth.amount, false)
		block_meshes[@s] = mesh

		for (var d = 0; d < e_block_depth.amount; d++)
		for (var vb = 0; vb < e_block_vbuffer.amount; vb++)
		{
			var index = d * e_block_vbuffer.amount + vb;
			mesh.block_vbuffer[@index] = vbuffer_start()
			vbuffer_set_batching(mesh.block_vbuffer[@index], false)
		}
	}

	block_meshes_active = null
	mc_builder.block_meshes = block_meshes
	mc_builder.block_meshes_size = block_meshes_size
}
