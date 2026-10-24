function block_meshes_done()
{
	block_meshes_transparent = false

	for (var s = 0; s < array_length(block_meshes); s++)
	{
		var mesh = block_meshes[s];
		if (mesh = null)
			continue

		var hasmesh = false;
		for (var d = 0; d < e_block_depth.amount; d++)
		for (var vb = 0; vb < e_block_vbuffer.amount; vb++)
		{
			var index = d * e_block_vbuffer.amount + vb;
			vertex_end(mesh.block_vbuffer[@index])
			mesh.block_vbuffer[@index] = vbuffer_generate_tangents(mesh.block_vbuffer[@index])
			vertex_freeze(mesh.block_vbuffer[@index])

			var active = !vbuffer_is_empty(mesh.block_vbuffer[@index]);
			mesh.block_vbuffer_active[@index] = active
			if (active)
			{
				hasmesh = true
				mesh.block_vbuffer_depth_active[@d] = true
				
				if (d != e_block_depth.DEPTH0)
					block_meshes_transparent = true
			}
			else
			{
				vbuffer_destroy(mesh.block_vbuffer[@index])
				mesh.block_vbuffer[@index] = null
			}
		}

		if (!hasmesh)
		{
			with (mesh)
				instance_destroy()
			
			block_meshes[@s] = null
		}
	}

	mc_builder.block_meshes = []
}
