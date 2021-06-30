/// block_vbuffer_start()

function block_vbuffer_start()
{
	if (block_vbuffer != null)
		for (var d = 0; d < e_block_depth.amount; d++)
			for (var vb = 0; vb < e_block_vbuffer.amount; vb++)
				vbuffer_destroy(block_vbuffer[d, vb])
	
	for (var d = 0; d < e_block_depth.amount; d++)
	{
		for (var vb = 0; vb < e_block_vbuffer.amount; vb++)
		{
			block_vbuffer[d, vb] = vbuffer_start()
			mc_builder.vbuffer[d, vb] = block_vbuffer[d, vb]
		}
	}
	
	bounding_box.reset()
}
