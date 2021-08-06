/// lib_bbox()
/// @desc Functions library for making and editing bounding boxes

function bbox() constructor {
	
	frustum_state = e_frustum_state.INIT
	frustum_state_prev = frustum_state
	changed = false
	start_pos = [no_limit, no_limit, no_limit]
	end_pos = [-no_limit, -no_limit, -no_limit]
	size = no_limit*2
	center = [0, 0, 0]
	
	static updatePoints = function()
	{
		/*
		boxp[0] = point3D(start_pos[X], start_pos[Y], start_pos[Z])
		boxp[1] = point3D(start_pos[X], end_pos[Y],   start_pos[Z])
		boxp[2] = point3D(end_pos[X],   end_pos[Y],   start_pos[Z])
		boxp[3] = point3D(end_pos[X],   start_pos[Y], start_pos[Z])
		
		boxp[4] = point3D(start_pos[X], start_pos[Y], end_pos[Z])
		boxp[5] = point3D(start_pos[X], end_pos[Y],   end_pos[Z])
		boxp[6] = point3D(end_pos[X],   end_pos[Y],   end_pos[Z])
		boxp[7] = point3D(end_pos[X],   start_pos[Y], end_pos[Z])
		*/
		
		// Convert points to cube
		center[X] = start_pos[X] + ((end_pos[X] - start_pos[X]) * .5)
		center[Y] = start_pos[Y] + ((end_pos[Y] - start_pos[Y]) * .5)
		center[Z] = start_pos[Z] + ((end_pos[Z] - start_pos[Z]) * .5)
		size = point_distance_3d(start_pos[X], start_pos[Y], start_pos[Z], center[X], center[Y], center[Z])
		
		//center = point3D_add(start_pos, point3D_mul(point3D_sub(end_pos, start_pos), .5))
		//size = point3D_distance(start_pos, center)
		
		//start_pos = point3D_sub(center, vec3(size * .5))
		//end_pos = point3D_add(center, vec3(size * .5))
	}
	
	static reset = function()
	{
		changed = false
		start_pos = point3D(no_limit, no_limit, no_limit)
		end_pos = point3D(-no_limit, -no_limit, -no_limit)
		
		self.updatePoints()
	}
	
	static mul_matrix = function(mat)
	{
		var p, np, i, corner, xx, yy, zz;
		p = array_create(8, array_create(3))
		np = array_create(8, array_create(3))
		p[0] = [start_pos[X], start_pos[Y], start_pos[Z]]
		p[1] = [start_pos[X], end_pos[Y],   start_pos[Z]]
		p[2] = [end_pos[X],   end_pos[Y],   start_pos[Z]]
		p[3] = [end_pos[X],   start_pos[Y], start_pos[Z]]
		
		p[4] = [start_pos[X], start_pos[Y], end_pos[Z]]
		p[5] = [start_pos[X], end_pos[Y],   end_pos[Z]]
		p[6] = [end_pos[X],   end_pos[Y],   end_pos[Z]]
		p[7] = [end_pos[X],   start_pos[Y], end_pos[Z]]
		
		// Apply matrix
		i = 0
		repeat (8)
		{
			xx = p[i][X]
			yy = p[i][Y]
			zz = p[i][Z]
			
			np[i][X] = mat[@ 0] * xx + mat[@ 4] * yy + mat[@ 8]  * zz + mat[@ 12]
			np[i][Y] = mat[@ 1] * xx + mat[@ 5] * yy + mat[@ 9]  * zz + mat[@ 13]
			np[i][Z] = mat[@ 2] * xx + mat[@ 6] * yy + mat[@ 10] * zz + mat[@ 14]
			
			i++
		}
		
		start_pos = point3D(no_limit, no_limit, no_limit)
		end_pos = point3D(-no_limit, -no_limit, -no_limit)
		
		i = 0
		repeat (8)
		{
			corner = np[i]
			start_pos[X] = start_pos[X] < corner[X] ? start_pos[X] : corner[X]
			start_pos[Y] = start_pos[Y] < corner[Y] ? start_pos[Y] : corner[Y]
			start_pos[Z] = start_pos[Z] < corner[Z] ? start_pos[Z] : corner[Z]
			
			end_pos[X] = end_pos[X] > corner[X] ? end_pos[X] : corner[X]
			end_pos[Y] = end_pos[Y] > corner[Y] ? end_pos[Y] : corner[Y]
			end_pos[Z] = end_pos[Z] > corner[Z] ? end_pos[Z] : corner[Z]
			
			i++
		}
		
		self.updatePoints()
	}
	
	static merge = function(box)
	{
		if (!box.changed)
			return 0
		
		start_pos[X] = (start_pos[X] < box.start_pos[X] ? start_pos[X] : box.start_pos[X])//min(start_pos[X], box.start_pos[X], box.end_pos[X])
		start_pos[Y] = (start_pos[Y] < box.start_pos[Y] ? start_pos[Y] : box.start_pos[Y])//min(start_pos[Y], box.start_pos[Y], box.end_pos[Y])
		start_pos[Z] = (start_pos[Z] < box.start_pos[Z] ? start_pos[Z] : box.start_pos[Z])//min(start_pos[Z], box.start_pos[Z], box.end_pos[Z])
		
		
		end_pos[X] = (end_pos[X] > box.end_pos[X] ? end_pos[X] : box.end_pos[X])
		end_pos[Y] = (end_pos[Y] > box.end_pos[Y] ? end_pos[Y] : box.end_pos[Y])
		end_pos[Z] = (end_pos[Z] > box.end_pos[Z] ? end_pos[Z] : box.end_pos[Z])
		
		/*
		end_pos[X] = max(end_pos[X], box.start_pos[X], box.end_pos[X])
		end_pos[Y] = max(end_pos[Y], box.start_pos[Y], box.end_pos[Y])
		end_pos[Z] = max(end_pos[Z], box.start_pos[Z], box.end_pos[Z])
		*/
		
		changed = true
		self.updatePoints()
	}
	
	static copy_vbuffer = function(update)
	{
		start_pos = [vbuffer_xmin, vbuffer_ymin, vbuffer_zmin]
		end_pos = [vbuffer_xmax, vbuffer_ymax, vbuffer_zmax]
		
		changed = true
		
		if (update = undefined && update = true)
			self.updatePoints()
	}
	
	static set_vbuffer = function()
	{
		vbuffer_xmin = start_pos[X]
		vbuffer_ymin = start_pos[Y]
		vbuffer_zmin = start_pos[Z]
		
		vbuffer_xmax = end_pos[X]
		vbuffer_ymax = end_pos[Y]
		vbuffer_zmax = end_pos[Z]
	}
	
	static copy = function(box)
	{
		start_pos = array_copy_1d(box.start_pos)
		end_pos = array_copy_1d(box.end_pos)
		
		changed = box.changed
		self.updatePoints()
	}
	
	static updateFrustumState = function()
	{
		frustum_state_prev = frustum_state
		
		if (frustum_state = e_frustum_state.INIT)
		{
			frustum_state = e_frustum_state.PARTIAL
			return 0
		}
		
		if (size > no_limit)
			return 0
		
		var i, side, distance;
		
		i = 0
		repeat (6)
		{
			side = render_frustum.p[i]

			distance = ((side[X] * center[X]) + (side[Y] * center[Y]) + (side[Z] * center[Z]) + side[W])
			
			if (abs(distance) <= size)
			{
				frustum_state = e_frustum_state.PARTIAL
				return 0
			}
			else if (distance < -size)
			{
				frustum_state = e_frustum_state.HIDDEN
				return 0
			}
			
			i++
		}
		
		frustum_state = e_frustum_state.VISIBLE
	}
}

function bbox_update_visible()
{
	var chunks, chunkarray, rep, chunksize;
	chunks = 0
	
	// Update models
	for (var i = 0; i < ds_list_size(project_model_list); i++)
	{
		with (project_model_list[|i])
		{
			if (type = e_tl_type.MODEL && temp.model.model_format = e_model_format.BLOCK)
				continue
			
			if (model_timeline_list = null)
				continue
			
			bounding_box_matrix.updateFrustumState()
			bounding_box_update = false
			
			if (bounding_box_matrix.frustum_state = e_frustum_state.PARTIAL)
			{
				for (var j = 0; j < ds_list_size(model_timeline_list); j++)
				{
					var tl = model_timeline_list[|j];
					
					if (!tl.render_visible)
						continue
					
					tl.bounding_box_update = true
				}
			}
			else
			{
				for (var j = 0; j < ds_list_size(model_timeline_list); j++)
				{
					var tl = model_timeline_list[|j];
					
					if (!tl.render_visible)
						continue
					
					tl.bounding_box_update = false
					tl.bounding_box_matrix.frustum_state = bounding_box_matrix.frustum_state
				}
			}
		}
	}
	
	// Update timelines
	with (obj_timeline)
	{
		if (!render_visible ||
			!bounding_box_update || 
			type = e_tl_type.CHARACTER ||
			type = e_tl_type.SPECIAL_BLOCK ||
			type = e_tl_type.FOLDER ||
			type = e_tl_type.BACKGROUND ||
			type = e_tl_type.AUDIO ||
			type = e_tl_type.CAMERA)
			continue
		
		// Objects in scenery don't use template objects
		if (part_root = null && temp != null && temp.object_index = obj_template)
		{
			if (type = e_tl_type.SCENERY && temp.scenery = null && !scenery_update_chunks)
				continue
			else
			{
				if (type = e_tl_type.SCENERY && temp.scenery != null && !temp.scenery.ready)
					continue
			}
		}
		
		bounding_box_matrix.updateFrustumState()
		
		if ((bounding_box_matrix.frustum_state = e_frustum_state.VISIBLE || bounding_box_matrix.frustum_state = e_frustum_state.HIDDEN) && !scenery_update_chunks)
			continue
		
		if ((bounding_box_matrix.frustum_state_prev = bounding_box_matrix.frustum_state) && !scenery_update_chunks)
			continue
		
		scenery_update_chunks = false
		
		// Make a list of all visible chunks vbuffers to render
		if (((type = e_tl_type.SCENERY || type = e_tl_type.BLOCK) && scenery_repeat_bounding_box != null))
		{
			rep = temp.block_repeat_enable ? temp.block_repeat : vec3(1)
			chunkarray = (type = e_tl_type.SCENERY ? temp.scenery.scenery_chunk_array : temp.scenery_chunk_array)
			visible_chunks_array = null
			chunks = 0
			chunksize = [array_length(scenery_repeat_bounding_box[0][0][0]),
						 array_length(scenery_repeat_bounding_box[0][0][0][0]),
						 array_length(scenery_repeat_bounding_box[0][0][0][0][0])]
			
			// Loop through repeat
			for (var rx = 0; rx < rep[X]; rx++)
			{
				for (var ry = 0; ry < rep[Y]; ry++)
				{
					for (var rz = 0; rz < rep[Z]; rz++)
					{
						// Initialize vbuffer arrays
						for (var d = 0; d < e_block_depth.amount; d++)
							for (var vb = 0; vb < e_block_vbuffer.amount; vb++)
								visible_chunks_array[rx][ry][rz][d][vb] = []
						
						// Loop through chunks
						for (var cx = 0; cx < chunksize[X]; cx++)
						{
							for (var cy = 0; cy < chunksize[Y]; cy++)
							{
								for (var cz = 0; cz < chunksize[Z]; cz++)
								{
									var c = chunkarray[cx][cy][cz];
									
									var addchunk = (bounding_box_matrix.frustum_state != e_frustum_state.HIDDEN);
									
									if (!addchunk)
									{
										scenery_repeat_bounding_box[rx][ry][rz][cx][cy][cz].updateFrustumState()
										addchunk = (scenery_repeat_bounding_box.frustum_state != e_frustum_state.HIDDEN)
									}
									
									// Chunk is visible somehow, now check vbuffers
									if (!c.empty && addchunk)
									{
										for (var d = 0; d < e_block_depth.amount; d++)
										{
											for (var vb = 0; vb < e_block_vbuffer.amount; vb++)
											{
												if (!c.vbuffer_empty[d][vb])
												{
													chunks = array_length(visible_chunks_array[rx][ry][rz][d][vb])
													visible_chunks_array[rx][ry][rz][d][vb][chunks] = c
												}
											}
										}
									}
								}	
							}
						}
					}
				}
			}
		}
	}
}

function frustum() constructor {
	
	active = true
	self.reset()
	
	static reset = function()
	{
		p[0] = [ 1,  0,  0, 1] // Left
		p[1] = [-1,  0,  0, 1] // Right
		p[2] = [ 0,  1,  0, 1] // Bottom
		p[3] = [ 0, -1,  0, 1] // Top
		p[4] = [ 0,  0,  1, 1] // Behind view
		p[5] = [ 0,  0, -1, 1] // Beyond view
	}
	
	static build = function(matVP)
	{
		var matVPt = matrix_transpose(matVP);
		self.reset()
		
		for (var i = 0; i < 6; i++)
		{
			var mul = vec4_mul_matrix(p[i], matVPt);
			p[i] = vec4_div(mul, vec3_length(vec3(mul[X], mul[Y], mul[Z])))
		}
	}
}