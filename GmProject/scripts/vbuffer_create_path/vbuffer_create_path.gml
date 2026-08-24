/// vbuffer_create_path(path, [small])
/// @arg path
/// @arg [small]

function vbuffer_create_path(path, small = false)
{
	var points, radius, detail, closed, rail, texlength, invert;
	points = path.path_table
	radius = path.path_shape_radius
	detail = path.path_shape_detail
	closed = path.path_closed
	rail = !path.path_shape_tube
	texlength = path.path_shape_tex_length
	invert = path.path_shape_invert
	
	// Create mesh for clicking path(for selection) where a shape isn't set to be used in timeline
	if (small)
	{
		radius = 1
		detail = 4
		rail = false
		invert = false
	}
	
	vbuffer_start()
	
	// Compile coordinate frames
	var frames, p;
	
	for (var i = 0; i < array_length(points); i++)
	{
		p = points[i]
		frames[i] = matrix_create_rotate_to([p[PATH_TANGENT_X], p[PATH_TANGENT_Y], p[PATH_TANGENT_Z]],
											[p[PATH_NORMAL_X], p[PATH_NORMAL_Y], p[PATH_NORMAL_Z]])
	}
	
	var p1, p2, p3, p4;
	var n1, n2, n3, n4, nflatp, nflat;
	var nn1, nn2, nn3, nn4;
	var t1, t2, t3, t4;
	var jp, j;
	var ringp;
	var length, plength;
	length = 0
	plength = 0
	
	for (var i = 0; i < array_length(frames) - 1; i++)
	{
		if (!rail)
		{
			jp = 0
			j = 1/detail
		}
		else
			jp = .5 // Left side of rail
		
		ringp = [cos(jp * pi * 2), 0, -sin(jp * pi * 2)]
		
		plength = length
		length += point3D_distance(points[i], points[i + 1])
		
		// p1 - current point's segment
		n1 = vec3_normalize(vec3_mul_matrix(ringp, frames[i]))
		p1 = point3D_add(vec3_mul(n1, radius * points[i][4]), points[i])
		
		// p3 - next point's segment
		n3 = vec3_normalize(vec3_mul_matrix(ringp, frames[i + 1]))
		p3 = point3D_add(vec3_mul(n3, radius * points[i + 1][4]), points[i + 1])
		
		// Offset before loop
		jp = 0
		j = 0
		
		while (j < 1)
		{
			if (!rail)
			{
				jp = j
				j += 1 / detail
			}
			else
				j = 0 // Right side of rail
			
			ringp = [cos(j * pi * 2), 0, -sin(j * pi * 2)]
			
			// Next segment
			n2 = vec3_normalize(vec3_mul_matrix(ringp, frames[i]))
			p2 = point3D_add(vec3_mul(n2, radius * points[i][4]), points[i])
			
			// Next segment
			n4 = vec3_normalize(vec3_mul_matrix(ringp, frames[i + 1]))
			p4 = point3D_add(vec3_mul(n4, radius * points[i + 1][4]), points[i + 1])
			
			if (rail)
			{
				t1 = vec2(0, plength / texlength)
				t2 = vec2(1, plength / texlength)
				t3 = vec2(0, length / texlength)
				t4 = vec2(1, length / texlength)
				
				n1 = [frames[i][8], frames[i][9], frames[i][10]]
				n2 = n1
				n3 = [frames[i + 1][8], frames[i + 1][9], frames[i + 1][10]]
				n4 = n3
			}
			else
			{
				t1 = vec2(jp, plength / texlength)
				t2 = vec2(j, plength / texlength)
				t3 = vec2(jp, length / texlength)
				t4 = vec2(j, length / texlength)
			}
			
			t1[X] /= 3
			t2[X] /= 3
			t3[X] /= 3
			t4[X] /= 3
			
			nn1 = n1
			nn2 = n2
			nn3 = n3
			nn4 = n4
			
			// Invert normals
			if (invert)
			{
				nn1 = vec3_mul(nn1, -1)
				nn2 = vec3_mul(nn2, -1)
				nn3 = vec3_mul(nn3, -1)
				nn4 = vec3_mul(nn4, -1)
			}
			
			// Smooth segments, flat radius
			if (path.path_shape_smooth_segments && !path.path_shape_smooth_ring)
			{
				nflatp = vec3_normalize(vec3_add(nn1, nn2))
				nflat = vec3_normalize(vec3_add(nn3, nn4))
				nn1 = nflatp
				nn2 = nflatp
				nn3 = nflat
				nn4 = nflat
			}
			else if (!path.path_shape_smooth_segments && path.path_shape_smooth_ring) // Flat segments, smooth radius
			{
				nflatp = vec3_normalize(vec3_add(nn1, nn3))
				nflat = vec3_normalize(vec3_add(nn2, nn4))
				nn1 = nflatp
				nn2 = nflat
				nn3 = nflatp
				nn4 = nflat
			}
			else if (!path_shape_smooth_segments && !path_shape_smooth_ring) // Flat
			{
				nflat = vec3_normalize(vec3_add(vec3_add(vec3_add(nn1, nn2), nn3), nn4))
				nn1 = nflat
				nn2 = nflat
				nn3 = nflat
				nn4 = nflat
			}
				
			if (invert)
			{
				vbuffer_add_triangle(p2, p1, p4, t2, t1, t4, nn2, nn1, nn4)
				vbuffer_add_triangle(p1, p3, p4, t1, t3, t4, nn1, nn3, nn4)
			}
			else
			{
				vbuffer_add_triangle(p4, p1, p2, t4, t1, t2, nn4, nn1, nn2)
				vbuffer_add_triangle(p4, p3, p1, t4, t3, t1, nn4, nn3, nn1)
			}
			
			if (rail)
				break
			
			// Fill ends of tube
			if (!closed)
			{
				t1 = [(cos((jp + .25) * pi * 2) + 1)/2, (sin((jp + .25) * pi * 2) + 1)/2]
				t2 = [(cos((j + .25) * pi * 2) + 1)/2, (sin((j + .25) * pi * 2) + 1)/2]
				t3 = [.5, .5]
				
				t1[X] = (t1[X] / 3) + (1/3)
				t2[X] = (t2[X] / 3) + (1/3)
				t3[X] = (t3[X] / 3) + (1/3)
				
				// Beginning
				if (i = 0)
				{
					if (invert)
						vbuffer_add_triangle(p2, points[i], p1, t2, t3, t1)
					else
						vbuffer_add_triangle(p1, points[i], p2, t1, t3, t2)
				}
				
				// End
				if (i = (array_length(points) - 2))
				{
					t1[X] += (1/3)
					t2[X] += (1/3)
					t3[X] += (1/3)
					
					if (invert)
						vbuffer_add_triangle(p3, points[i + 1], p4, t1, t3, t2)
					else
						vbuffer_add_triangle(p4, points[i + 1], p3, t2, t3, t1)
				}
			}
			
			p1 = p2
			p3 = p4
			n1 = n2
			n3 = n4
		}
		
	}
	
	return vbuffer_done()
}
