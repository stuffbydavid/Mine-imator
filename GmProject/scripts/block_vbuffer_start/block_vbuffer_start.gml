function block_vbuffer_start()
{
	if (block_vbuffer != null)
		for (var d = 0; d < e_block_depth.amount; d++)
			for (var vb = 0; vb < e_block_vbuffer.amount; vb++)
				vbuffer_destroy(block_vbuffer[@ d * e_block_vbuffer.amount + vb])

	block_vbuffer = array_create(e_block_depth.amount * e_block_vbuffer.amount, null)
	block_vbuffer_active = array_create(e_block_depth.amount * e_block_vbuffer.amount, false)
	block_vbuffer_depth_active = array_create(e_block_depth.amount, false)
	mc_builder.vbuffer = array_create(e_block_depth.amount * e_block_vbuffer.amount, null)
	
	for (var d = 0; d < e_block_depth.amount; d++)
	{
		for (var vb = 0; vb < e_block_vbuffer.amount; vb++)
		{
			var index = d * e_block_vbuffer.amount + vb;
			block_vbuffer[@ index] = vbuffer_start()
			vbuffer_set_save_data(block_vbuffer[@ index], true)
			mc_builder.vbuffer[@ index] = block_vbuffer[@ index]
		}
	}
}
