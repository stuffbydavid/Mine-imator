/// block_vbuffer_destroy()

function block_vbuffer_destroy()
{
	if (block_vbuffer != null)
		for (var d = 0; d < e_block_depth.amount; d++)
			for (var vb = 0; vb < e_block_vbuffer.amount; vb++)
					vbuffer_destroy(block_vbuffer[d, vb])
}
