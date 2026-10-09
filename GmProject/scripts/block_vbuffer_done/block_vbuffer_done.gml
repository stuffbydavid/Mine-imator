function block_vbuffer_done()
{
	for (var d = 0; d < e_block_depth.amount; d++)
	{
		for (var vb = 0; vb < e_block_vbuffer.amount; vb++)
		{
			var index, active;
			index = d * e_block_vbuffer.amount + vb
			vertex_end(block_vbuffer[@ index])
			block_vbuffer[@ index] = vbuffer_generate_tangents(block_vbuffer[@ index])
			vertex_freeze(block_vbuffer[@ index])

			active = !vbuffer_is_empty(block_vbuffer[@ index])
			block_vbuffer_active[@ index] = active
			if (active)
				block_vbuffer_depth_active[d] = true
		}
	}
}
