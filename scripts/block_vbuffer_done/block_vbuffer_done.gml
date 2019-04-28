/// block_vbuffer_done()

for (var d = 0; d < e_block_depth.amount; d++)
{
	for (var vb = 0; vb < e_block_vbuffer.amount; vb++)
	{
		vertex_end(block_vbuffer[d, vb])
		vertex_freeze(block_vbuffer[d, vb])
	}
}

block_vbuffer_depth0 = false
block_vbuffer_depth1 = false
block_vbuffer_depth2 = false

if (!vbuffer_is_empty(block_vbuffer[e_block_depth.DEPTH0, e_block_vbuffer.NORMAL]) ||
	!vbuffer_is_empty(block_vbuffer[e_block_depth.DEPTH0, e_block_vbuffer.ANIMATED]) ||
	!vbuffer_is_empty(block_vbuffer[e_block_depth.DEPTH0, e_block_vbuffer.GRASS]))
	block_vbuffer_depth0 = true

if (!vbuffer_is_empty(block_vbuffer[e_block_depth.DEPTH1, e_block_vbuffer.NORMAL]) ||
	!vbuffer_is_empty(block_vbuffer[e_block_depth.DEPTH1, e_block_vbuffer.ANIMATED]) ||
	!vbuffer_is_empty(block_vbuffer[e_block_depth.DEPTH1, e_block_vbuffer.GRASS]) ||
	!vbuffer_is_empty(block_vbuffer[e_block_depth.DEPTH1, e_block_vbuffer.LEAVES]))
	block_vbuffer_depth1 = true

if (!vbuffer_is_empty(block_vbuffer[e_block_depth.DEPTH2, e_block_vbuffer.NORMAL]) ||
	!vbuffer_is_empty(block_vbuffer[e_block_depth.DEPTH2, e_block_vbuffer.ANIMATED]) ||
	!vbuffer_is_empty(block_vbuffer[e_block_depth.DEPTH2, e_block_vbuffer.WATER]))
	block_vbuffer_depth2 = true