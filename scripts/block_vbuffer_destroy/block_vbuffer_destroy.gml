/// block_vbuffer_destroy()

function block_vbuffer_destroy()
{
	var size = [array_length(scenery_chunk_array),
				array_length(scenery_chunk_array[0]),
				array_length(scenery_chunk_array[0][0])];
	
	for (var cx = 0; cx < size[X]; cx++)
		for (var cy = 0; cy < size[Y]; cy++)
			for (var cz = 0; cz < size[Z]; cz++)
				scenery_chunk_array[cx][cy][cz].destroy()
}
