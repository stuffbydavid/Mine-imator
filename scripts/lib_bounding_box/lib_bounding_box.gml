/// lib_bbox()
/// @desc Functions library for making and editing bounding boxes

function bbox() constructor {
	
	culled = false
	changed = false
	start_pos = point3D(no_limit, no_limit, no_limit)
	end_pos = point3D(-no_limit, -no_limit, -no_limit)
	self.updatePoints()
	
	static updatePoints = function()
	{
		boxp[0] = point4D(start_pos[X], start_pos[Y], start_pos[Z], 1)
		boxp[1] = point4D(start_pos[X], end_pos[Y],   start_pos[Z], 1)
		boxp[2] = point4D(end_pos[X],   end_pos[Y],   start_pos[Z], 1)
		boxp[3] = point4D(end_pos[X],   start_pos[Y], start_pos[Z], 1)
		
		boxp[4] = point4D(start_pos[X], start_pos[Y], end_pos[Z], 1)
		boxp[5] = point4D(start_pos[X], end_pos[Y],   end_pos[Z], 1)
		boxp[6] = point4D(end_pos[X],   end_pos[Y],   end_pos[Z], 1)
		boxp[7] = point4D(end_pos[X],   start_pos[Y], end_pos[Z], 1)
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
		var p;
		p[0] = point3D(start_pos[X], start_pos[Y], start_pos[Z])
		p[1] = point3D(start_pos[X], end_pos[Y],   start_pos[Z])
		p[2] = point3D(end_pos[X],   end_pos[Y],   start_pos[Z])
		p[3] = point3D(end_pos[X],   start_pos[Y], start_pos[Z])
		
		p[4] = point3D(start_pos[X], start_pos[Y], end_pos[Z])
		p[5] = point3D(start_pos[X], end_pos[Y],   end_pos[Z])
		p[6] = point3D(end_pos[X],   end_pos[Y],   end_pos[Z])
		p[7] = point3D(end_pos[X],   start_pos[Y], end_pos[Z])
		
		for (var i = 0; i < 8; i++)
			p[i] = point3D_mul_matrix(p[i], mat)
		
		start_pos = point3D(no_limit, no_limit, no_limit)
		end_pos = point3D(-no_limit, -no_limit, -no_limit)
		
		var sp, ep;
		sp = point3D(no_limit, no_limit, no_limit)
		ep = point3D(-no_limit, -no_limit, -no_limit)
		
		for (var i = 0; i < 8; i++)
		{
			var corner = p[i];
			start_pos[X] = min(start_pos[X], corner[X])
			start_pos[Y] = min(start_pos[Y], corner[Y])
			start_pos[Z] = min(start_pos[Z], corner[Z])
			
			end_pos[X] = max(end_pos[X], corner[X])
			end_pos[Y] = max(end_pos[Y], corner[Y])
			end_pos[Z] = max(end_pos[Z], corner[Z])
		}
		
		self.updatePoints()
	}
	
	static merge = function(box)
	{
		if (!box.changed)
			return 0
		
		start_pos[X] = min(start_pos[X], box.start_pos[X], box.end_pos[X])
		start_pos[Y] = min(start_pos[Y], box.start_pos[Y], box.end_pos[Y])
		start_pos[Z] = min(start_pos[Z], box.start_pos[Z], box.end_pos[Z])
			
		end_pos[X] = max(end_pos[X], box.start_pos[X], box.end_pos[X])
		end_pos[Y] = max(end_pos[Y], box.start_pos[Y], box.end_pos[Y])
		end_pos[Z] = max(end_pos[Z], box.start_pos[Z], box.end_pos[Z])
		
		changed = true
		self.updatePoints()
	}
	
	static copy_vbuffer = function()
	{
		start_pos = point3D(vbuffer_xmin, vbuffer_ymin, vbuffer_zmin)
		end_pos = point3D(vbuffer_xmax, vbuffer_ymax, vbuffer_zmax)
		
		changed = true
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
	
	static frustumVisible = function(viewFrustum)
	{
		for (var i = 0; i < 6; i++)
		{
			var pointInside = false;
			
			for (var j = 0; j < 8; j++)
			{
				if (vec4_dot(viewFrustum.p[i], boxp[j]) > 0)
				{
					pointInside = true
					break
				}
			}
			
			if (!pointInside)
				return false
		}
		
		return true
	}
}

function bbox_update_visible(viewFrustum)
{
	with (obj_timeline)
	{
		bounding_box_matrix.culled = !bounding_box_matrix.frustumVisible(viewFrustum)
		
		if (type = e_tl_type.SCENERY || type = e_tl_type.BLOCK)
		{
			for (var rx = 0; rx < array_length(scenery_repeat_bounding_box); rx++)
				for (var ry = 0; ry < array_length(scenery_repeat_bounding_box[0]); ry++)
					for (var rz = 0; rz < array_length(scenery_repeat_bounding_box[0][0]); rz++)
						for (var cx = 0; cx < array_length(scenery_repeat_bounding_box[0][0][0]); cx++)
							for (var cy = 0; cy < array_length(scenery_repeat_bounding_box[0][0][0][0]); cy++)
								for (var cz = 0; cz < array_length(scenery_repeat_bounding_box[0][0][0][0][0]); cz++)
									scenery_repeat_bounding_box[rx][ry][rz][cx][cy][cz].culled = !scenery_repeat_bounding_box[rx][ry][rz][cx][cy][cz].frustumVisible(viewFrustum)
		}
	}
}

function frustum() constructor {
	
	active = true
	p[0] = [ 1,  0,  0, 1]
	p[1] = [-1,  0,  0, 1]
	p[2] = [ 0,  1,  0, 1]
	p[3] = [ 0, -1,  0, 1]
	p[4] = [ 0,  0,  0, 1]
	p[5] = [ 0,  0, -1, 1]
	
	static reset = function()
	{
		p[0] = [ 1,  0,  0, 1]
		p[1] = [-1,  0,  0, 1]
		p[2] = [ 0,  1,  0, 1]
		p[3] = [ 0, -1,  0, 1]
		p[4] = [ 0,  0,  0, 1]
		p[5] = [ 0,  0, -1, 1]
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