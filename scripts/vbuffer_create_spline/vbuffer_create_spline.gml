/// vbuffer_create_spline(points, radius, detail, closed, rail, texlength)
/// @arg points
/// @arg radius
/// @arg detail
/// @arg closed
/// @arg rail
/// @arg texlength

function vbuffer_create_spline(points, radius, detail, closed, rail, texlength)
{
	vbuffer_start()
	
	var pointdir, smoothdir, p0;
	pointdir = []
	smoothdir = []
	
	// Pre-calculate vectors between points
	for (var i = 0; i < array_length(points) - 1; i++)
		pointdir[i] = vec3_normalize(point3D_sub(points[i + 1], points[i]))
	
	for (var i = 0; i < array_length(points); i++)
	{
		if (closed)
		{
			p0 = mod_fix(i - 1, array_length(points) - 1)
			p1 = mod_fix(i,     array_length(points) - 1)
		}
		else
		{
			p0 = clamp(i - 1, 0, array_length(points) - 2)
			p1 = clamp(i,     0, array_length(points) - 2)
		}
		
		smoothdir[i] = vec3_normalize(vec3_add(pointdir[p0], pointdir[p1]))
	}
	
	var p1, p2, p3, p4;
	var n1, n2, n3, n4;
	var t1, t2, t3, t4;
	var jp, j;
	var length, plength;
	length = 0
	plength = 0
	
	for (var i = 0; i < array_length(smoothdir) - 1; i++)
	{
		if (!rail)
		{
			jp = 0
			j = 1/detail
		}
		else
			jp = .75 // Left side of rail
		
		plength = length
		length += point3D_distance(points[i], points[i + 1])
		
		// p1 - current point's segment
		n1 = vec3_tangent(smoothdir[i], (jp * 360) + points[i][W])
		p1 = point3D_add(vec3_mul(n1, radius * points[i][4]), points[i])
		
		// p3 - next point's segment
		n3 = vec3_tangent(smoothdir[i + 1], (jp * 360) + points[i + 1][W])
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
				j = 0.25 // Right side of rail
			
			// Next segment
			n2 = vec3_tangent(smoothdir[i], (j * 360) + points[i][W])
			p2 = point3D_add(vec3_mul(n2, radius * points[i][4]), points[i])
			
			// Next segment
			n4 = vec3_tangent(smoothdir[i + 1], (j * 360) + points[i + 1][W])
			p4 = point3D_add(vec3_mul(n4, radius * points[i + 1][4]), points[i + 1])
			
			if (rail)
			{
				t1 = vec2(0, plength / texlength)
				t2 = vec2(1, plength / texlength)
				t3 = vec2(0, length / texlength)
				t4 = vec2(1, length / texlength)
				
				n1 = vec3_tangent(smoothdir[i], points[i][W])
				n2 = n1
				n3 = vec3_tangent(smoothdir[i + 1], points[i + 1][W])
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
			
			vbuffer_add_triangle(p4, p1, p2, t4, t1, t2, n4, n1, n2)
			vbuffer_add_triangle(p4, p3, p1, t4, t3, t1, n4, n3, n1)
			
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
				
				if (i = 0)
					vbuffer_add_triangle(p1, points[i], p2, t1, t3, t2)
				
				if (i = (array_length(points) - 2))
				{
					t1[X] += (1/3)
					t2[X] += (1/3)
					t3[X] += (1/3)
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
