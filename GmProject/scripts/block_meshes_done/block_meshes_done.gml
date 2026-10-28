function block_meshes_done()
{
	block_meshes_transparent = false

	for (var s = 0; s < array_length(block_meshes); s++)
	{
		var mesh = block_meshes[s];
		if (mesh = null)
			continue

		var hasmesh = false;
		with (mesh)
		{
			block_vbuffer_render_order = []

			for (var d = 0; d < e_block_depth.amount; d++)
			{
				block_vbuffer_render_offsets[@d] = array_length(block_vbuffer_render_order)
				block_vbuffer_depth_active[@d] = false

				for (var vb = 0; vb < e_block_vbuffer.amount; vb++)
				{
					var index = d * e_block_vbuffer.amount + vb;
					if (block_vbuffer[@index] = null)
						continue

					vertex_end(block_vbuffer[@index])
					block_vbuffer[@index] = vbuffer_generate_tangents(block_vbuffer[@index])
					vertex_freeze(block_vbuffer[@index])

					var active = !vbuffer_is_empty(block_vbuffer[@index]);
					block_vbuffer_active[@index] = active
					if (active)
					{
						hasmesh = true
						block_vbuffer_depth_active[@d] = true
						block_vbuffer_render_order[@array_length(block_vbuffer_render_order)] = index
					}
					else
					{
						vbuffer_destroy(block_vbuffer[@index])
						block_vbuffer[@index] = null
					}
				}
			}

			block_vbuffer_render_offsets[@e_block_depth.amount] = array_length(block_vbuffer_render_order)
		}

		if (mesh.block_vbuffer_depth_active[@e_block_depth.DEPTH1] ||
			mesh.block_vbuffer_depth_active[@e_block_depth.DEPTH2])
			block_meshes_transparent = true

		if (!hasmesh && mesh.block_grid_buffer = null)
		{
			with (mesh)
				instance_destroy()

			block_meshes[@s] = null
			block_meshes_active[@s] = false
		}
	}

	mc_builder.block_meshes = []
}
