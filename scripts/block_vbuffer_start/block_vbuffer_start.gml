/// block_vbuffer_start(size)
/// @arg size

function block_vbuffer_start(size)
{
	// Initialize chunks
	mc_builder.build_chunk_size_x = ceil(size[X]/chunk_size)
	mc_builder.build_chunk_size_y = ceil(size[Y]/chunk_size)
	mc_builder.build_chunk_size_z = ceil(size[Z]/chunk_size)
	mc_builder.build_chunk_size_total = (mc_builder.build_chunk_size_x * mc_builder.build_chunk_size_y * mc_builder.build_chunk_size_z)
	mc_builder.build_chunk_progress = 0
	
	if (scenery_chunk_array != null)
	{
		for (var cx = 0; cx < array_length(scenery_chunk_array); cx++)
		{
			for (var cy = 0; cy < array_length(scenery_chunk_array[0]); cy++)
			{
				for (var cz = 0; cz < array_length(scenery_chunk_array[0][0]); cz++)
				{
					scenery_chunk_array[cx][cy][cz].destroy()
					delete scenery_chunk_array[cx][cy][cz]
				}
			}
		}
	}
	
	scenery_chunk_array = null
	
	for (var cx = 0; cx < mc_builder.build_chunk_size_x; cx++)
		for (var cy = 0; cy < mc_builder.build_chunk_size_y; cy++)
			for (var cz = 0; cz < mc_builder.build_chunk_size_z; cz++)
				scenery_chunk_array[cx][cy][cz] = new chunk()
	
	mc_builder.chunk_array = scenery_chunk_array
}
