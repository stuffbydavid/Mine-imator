/// lib_chunk()

function chunk() constructor {
	
	bounding_box = new bbox()
	empty = false
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
		{
			for (var vb = 0; vb < e_block_vbuffer.amount; vb++)
			{
				vbuffer[d][vb] = vbuffer_start()
				vbuffer_empty[d][vb] = false
			}
		}
		
		empty = true
	}
	
	static model_done = function()
	{
		self.bounding_box.set_vbuffer()
		
		empty = true
		
		for (var d = 0; d < e_block_depth.amount; d++)
		{
			for (var vb = 0; vb < e_block_vbuffer.amount; vb++)
			{
				vertex_end(vbuffer[d][vb])
				vertex_freeze(vbuffer[d][vb])
				
				if (!vbuffer_is_empty(vbuffer[d][vb]))
				{
					vbuffer_empty[d][vb] = false
					empty = false
				}
				else
					vbuffer_empty[d][vb] = true
			}
		}
	}
}

function render_chunks_vbuffer(arr, vbuffer_depth, vbuffer)
{
	if (id.object_index = obj_timeline && visible_chunks_array != null)
	{
		var reparray = visible_chunks_array[render_repeat[X]][render_repeat[Y]][render_repeat[Z]][vbuffer_depth][vbuffer];
		
		for (var i = 0; i < array_length(reparray); i++)
			vertex_submit(reparray[i].vbuffer[vbuffer_depth][vbuffer], pr_trianglelist, -1)
	}
	else
	{
		for (var cx = 0; cx < array_length(arr); cx++)
		{
			for (var cy = 0; cy < array_length(arr[0]); cy++)
			{
				for (var cz = 0; cz < array_length(arr[0][0]); cz++)
				{
					var c = arr[cx][cy][cz];
					
					/*
					if (render_frustum.active && id.object_index = obj_timeline)
					{
						var box = scenery_repeat_bounding_box[render_repeat[X]][render_repeat[Y]][render_repeat[Z]][cx][cy][cz];
					
						if (box.culled)
							continue
					}
					*/
					
					if (!vbuffer_is_empty(c.vbuffer[vbuffer_depth][vbuffer]))
						vbuffer_render(c.vbuffer[vbuffer_depth][vbuffer])
				}
			}
		}
	}
}