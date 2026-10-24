function block_mesh_event_destroy()
{
	if (block_vbuffer != null)
	{
		for (var d = 0; d < e_block_depth.amount; d++)
		for (var vb = 0; vb < e_block_vbuffer.amount; vb++)
		{
			var buffer = block_vbuffer[@d * e_block_vbuffer.amount + vb];
			if (buffer != null)
				vbuffer_destroy(buffer)
		}
	}
}
