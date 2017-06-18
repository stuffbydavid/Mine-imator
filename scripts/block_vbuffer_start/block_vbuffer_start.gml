/// block_vbuffer_start()

for (var d = 0; d < e_block_depth.amount; d++)
{
	for (var vb = 0; vb < e_block_vbuffer.amount; vb++)
	{
		if (block_vbuffer[d, vb] != null)
			vbuffer_destroy(block_vbuffer[d, vb])
		block_vbuffer[d, vb] = vbuffer_start()
		mc_builder.vbuffer[d, vb] = block_vbuffer[d, vb]
	}
}