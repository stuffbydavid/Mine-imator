/// block_vbuffer_done()

function block_vbuffer_done()
{
	for (var cx = 0; cx < mc_builder.build_chunk_size; cx++)
		for (var cy = 0; cy < mc_builder.build_chunk_size_y; cy++)
			for (var cz = 0; cz < mc_builder.build_chunk_size_z; cz++)
				scenery_chunk_array[cx][cy][cz].model_done()
	
	bounding_box.reset()
	
	for (var cx = 0; cx < mc_builder.build_chunk_size; cx++)
		for (var cy = 0; cy < mc_builder.build_chunk_size_y; cy++)
			for (var cz = 0; cz < mc_builder.build_chunk_size_z; cz++)
				bounding_box.merge(scenery_chunk_array[cx][cy][cz].bounding_box)
}
