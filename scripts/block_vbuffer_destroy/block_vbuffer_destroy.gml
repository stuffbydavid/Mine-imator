/// block_vbuffer_destroy()

function block_vbuffer_destroy()
{
	for (var cx = 0; cx < array_length(scenery_chunk_array); cx++)
		for (var cy = 0; cy < array_length(scenery_chunk_array[0]); cy++)
			for (var cz = 0; cz < array_length(scenery_chunk_array[0][0]); cz++)
				scenery_chunk_array[cx][cy][cz].destroy()
}
