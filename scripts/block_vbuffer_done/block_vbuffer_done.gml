/// block_vbuffer_done()

for (var d = 0; d < e_block_depth.amount; d++)
{
	for (var vb = 0; vb < e_block_vbuffer.amount; vb++)
	{
	    vertex_end(block_vbuffer[d, vb])
	    vertex_freeze(block_vbuffer[d, vb])
	}
}