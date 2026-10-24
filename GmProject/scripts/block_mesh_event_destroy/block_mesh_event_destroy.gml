function block_mesh_event_destroy()
{
	for (var i = 0; i < array_length(block_vbuffer); i++)
	{
		var buffer = block_vbuffer[@i];
		if (buffer != null)
			vbuffer_destroy(buffer)
	}
}
