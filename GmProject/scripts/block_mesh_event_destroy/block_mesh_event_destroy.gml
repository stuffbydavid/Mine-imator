function block_mesh_event_destroy()
{
	for (var i = 0; i < array_length(block_vbuffer); i++)
	{
		var buffer = block_vbuffer[@i];
		if (buffer != null)
			vbuffer_destroy(buffer)
	}

	if (block_palette_buffer != null)
		buffer_delete(block_palette_buffer)

	if (block_grid_buffer != null)
		buffer_delete(block_grid_buffer)
}
