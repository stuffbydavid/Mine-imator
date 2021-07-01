/// lib_chunk()

function chunk() constructor {
	
	bounding_box = new bbox()
	self.init()
	
	static destroy = function()
	{
		for (var d = 0; d < e_block_depth.amount; d++)
			for (var vb = 0; vb < e_block_vbuffer.amount; vb++)
				if (vbuffer[d][vb] != null || !vbuffer_is_empty(vbuffer[d][vb]))
					vbuffer_destroy(vbuffer[d][vb])
	}
	
	static init = function()
	{
		for (var d = 0; d < e_block_depth.amount; d++)
			for (var vb = 0; vb < e_block_vbuffer.amount; vb++)
				vbuffer[d][vb] = vbuffer_start()
	}
	
	static model_done = function()
	{
		self.bounding_box.set_vbuffer()
		
		for (var d = 0; d < e_block_depth.amount; d++)
		{
			for (var vb = 0; vb < e_block_vbuffer.amount; vb++)
			{
				vertex_end(vbuffer[d][vb])
				vertex_freeze(vbuffer[d][vb])
			}
		}
	}
}

function render_chunks_vbuffer(arr, vbuffer_depth, vbuffer)
{
	for (var cx = 0; cx < array_length(arr); cx++)
	{
		for (var cy = 0; cy < array_length(arr[0]); cy++)
		{
			for (var cz = 0; cz < array_length(arr[0][0]); cz++)
			{
				var c = arr[cx][cy][cz];
				
				if (render_frustum.active && id.object_index = obj_timeline)
				{
					var box = scenery_repeat_bounding_box[render_scenery_repeat[X]][render_scenery_repeat[Y]][render_scenery_repeat[Z]][cx][cy][cz];
					
					if (box.culled)
						continue
				}
				
				if (!vbuffer_is_empty(c.vbuffer[vbuffer_depth][vbuffer]))
					vbuffer_render(c.vbuffer[vbuffer_depth][vbuffer])
			}
		}
	}
}