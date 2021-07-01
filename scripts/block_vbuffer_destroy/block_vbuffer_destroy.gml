/// block_vbuffer_destroy()

function block_vbuffer_destroy()
{
	for (var cx = 0; cx < mc_builder.builder_chunk_size_x; cx++)
		for (var cy = 0; cy < mc_builder.builder_chunk_size_y; cy++)
			for (var cz = 0; cz < mc_builder.builder_chunk_size_z; cz++)
				scenery_chunk_array[cx][cy][cz].destroy()
}
