/// model_shape_generate_plane_3d(bend, alphaarray)
/// @arg bend
/// @arg alphaarray
/// @desc Generates a 3D plane shape from an array of alpha values, transformed by a bend vector.

function model_shape_generate_plane_3d(bend, alpha)
{
	if (!is_array(alpha))
		return null
	
	// Plane dimensions
	var x1, x2, y1, y2, z1, z2, size, scalef;
	x1 = from[X];	y1 = from[Y];			 z1 = from[Z]
	x2 = to[X];		y2 = to[Y];				 z2 = to[Z]
	size = point3D_sub(to, from)
	scalef = 0.005 // Used to combat Z-fighting
	
	// Find whether the shape is bent
	var isbent = !vec3_equals(bend, vec3(0)) && bend_shape;
	
	// Axis to split up the plane
	var segouteraxis, seginneraxis, arrouteraxis, arrinneraxis;
	if (isbent)
	{
		if (bend_part = e_part.LEFT || bend_part = e_part.RIGHT)
		{
			segouteraxis = Z; seginneraxis = X;
			arrouteraxis = Y; arrinneraxis = X;
		}
		else if (bend_part = e_part.LOWER || bend_part = e_part.UPPER)
		{
			segouteraxis = X; seginneraxis = Z;
			arrouteraxis = X; arrinneraxis = Y;
		}
		else
		{
			segouteraxis = X; seginneraxis = Z;
			arrouteraxis = X; arrinneraxis = Y;
		}
	}
	else
	{
		segouteraxis = X; seginneraxis = Z;
		arrouteraxis = X; arrinneraxis = Y;
	}
	
	// Define texture coordinates to use
	var texsize, texuv, samplesize, texscale, texsizescale, ptexsize;
	texsize = point3D_sub(to_noscale, from_noscale)
	texuv = vec2_div(uv, texture_size)
	samplesize = vec2(array_length(alpha), array_length(alpha[0]))
	texscale = vec2(ceil(texsize[X]) / samplesize[X], ceil(texsize[Z]) / samplesize[Y])
	texsizescale = vec2_div(texture_size, texscale)
	ptexsize = vec2_div(vec2(1 - 1 / 256), texsizescale)
	
	// Start position and bounds
	var sharpbend, bendsize, bendstart, bendend, invangle;
	sharpbend = app.project_bend_style = "blocky" && bend_size = null && ((bend_axis[X] && !bend_axis[Y] && !bend_axis[Z]) || (!bend_axis[X] && bend_axis[Y] && !bend_axis[Z]) || (!bend_axis[X] && !bend_axis[Y] && bend_axis[Z]))
	bendsize = (bend_size = null ? (app.project_bend_style = "realistic" ? 4 : 1) : bend_size)
	invangle = (bend_part = e_part.LOWER || bend_part = e_part.BACK || bend_part = e_part.LEFT)
	
	if (segouteraxis = X)
	{
		bendstart = (bend_offset - (position[Z] + z1)) - bendsize / 2
		bendend = (bend_offset - (position[Z] + z1)) + bendsize / 2
	}
	else if (segouteraxis = Z)
	{
		bendstart = (bend_offset - (position[X] + x1)) - bendsize / 2
		bendend = (bend_offset - (position[X] + x1)) + bendsize / 2
	}
	
	// Precalculate points
	var y1p, y2p;
	var segouterpos = 0;
	var inflateouter = (inflate[X] / samplesize[arrouteraxis]) * 2;
	var inflateinner = (inflate[X] / samplesize[arrinneraxis]) * 2;
	for (var outer = 0; outer <= samplesize[arrouteraxis]; outer++)
	{
		var seginnerpos = 0;
		var seginnersize = 1;
		for (var inner = 0; inner <= samplesize[arrinneraxis]; inner++)
		{
			var p1, p2;
			if (seginneraxis = X)
			{
				p1 = point3D(x1 + seginnerpos, y1, z1 + segouterpos)
				p2 = point3D(x1 + seginnerpos, y2, z1 + segouterpos)
			}
			else if (seginneraxis = Z)
			{
				p1 = point3D(x1 + segouterpos, y1, z1 + seginnerpos)
				p2 = point3D(x1 + segouterpos, y2, z1 + seginnerpos)
			}
			
			// Apply transform
			var mat;
			if (isbent) // Apply segment bending
			{
				var segp, bendvec;
				if (seginnerpos < bendstart) // No/below bend, no angle
					segp = 0
				else if (seginnerpos >= bendend) // Above bend, apply full angle
					segp = 1
				else // Inside bend, apply partial angle
					segp = (1 - (bendend - seginnerpos) / bendsize)
				
				if (invangle)
					segp = 1 - segp
				
				bendvec = model_shape_get_bend(bend, segp)
				
				// Blocky bending
				var bendscale = vec3(0);
				if (sharpbend)
				{	
					if (abs(segp - 0.5) > 0.001)
						segp = round(segp)
					
					bendscale = model_shape_get_bend_scale(bendstart, bendend, segp, false, seginnerpos, bend)
					bendvec = vec3_mul(bend, segp)
				}
				
				mat = model_part_get_bend_matrix(id, bendvec, vec3(0), vec3_add(vec3_add(vec3(1), bendscale), vec3(segp * scalef)))
			}
			else // Apply rotation only
				mat = matrix_build(0, 0, 0, rotation[X], rotation[Y], rotation[Z], 1, 1, 1)
			
			p1 = point3D_mul_matrix(p1, mat)
			p2 = point3D_mul_matrix(p2, mat)
			
			y1p[outer, inner] = p1
			y2p[outer, inner] = p2
			
			// Pixel size
			seginnersize = 1;
			if (arrinneraxis = X)
			{
				if (inner = (texture_mirror ? 0 : samplesize[X] - 1) && frac(texsize[X]) > 0)
					seginnersize = frac(texsize[X])
			}
			else if (arrinneraxis = Y)
			{
				if (inner = samplesize[Y] - 1 && frac(texsize[Z]) > 0)
					seginnersize = frac(texsize[Z])
			}
			seginnerpos += (seginnersize + inflateinner) * scale[seginneraxis] * texscale[arrinneraxis]
		}
		
		// Pixel size
		var segoutersize = 1;
		if (arrouteraxis = X)
		{
			if (outer = (texture_mirror ? 0 : samplesize[X] - 1) && frac(texsize[X]) > 0)
				segoutersize = frac(texsize[X])
		}
		else if (arrouteraxis = Y)
		{
			if (outer = samplesize[Y] - 1 && frac(texsize[Z]) > 0)
				segoutersize = frac(texsize[Z])
		}
		segouterpos += (seginnersize + inflateouter) * scale[segouteraxis] * texscale[arrouteraxis]
	}
	
	// Create triangles
	vbuffer_start()
	
	vertex_emissive = color_emissive
	vertex_wave = wind_wave
	vertex_wave_zmin = wind_wave_zmin
	vertex_wave_zmax = wind_wave_zmax
	
	// Create triangles
	for (var outer = 0; outer < samplesize[arrouteraxis]; outer++)
	{
		// Inner loop
		for (var inner = 0; inner < samplesize[arrinneraxis]; inner++)
		{
			// Array location
			var ax, ay;
			if (seginneraxis = X)
			{
				ax = inner
				ay = samplesize[Y] - 1 - outer
			}
			else if (seginneraxis = Z)
			{
				ax = outer
				ay = samplesize[Y] - 1 - inner
			}
			
			if (texture_mirror)
				ax = samplesize[X] - 1 - ax
			
			// Transparent pixel found, continue
			if (alpha[@ ax, ay] < 1)
				continue
			
			// Calculate which faces to add, continue if none are visible
			var wface, eface, aface, bface;
			wface = (ax = 0 || alpha[@ ax - 1, ay] < 1)
			eface = (ax = samplesize[X] - 1 || alpha[@ ax + 1, ay] < 1)
			aface = (ay = 0 || alpha[@ ax, ay - 1] < 1)
			bface = (ay = samplesize[Y] - 1 || alpha[@ ax, ay + 1] < 1)
			
			// Switch east/west face when mirrored
			if (texture_mirror)
			{
				var tmp = wface;
				wface = eface
				eface = tmp
			}
			
			// Texture
			var ptex, t1, t2, t3, t4;
			ptex = point2D(texuv[X] + ax / texsizescale[X], texuv[Y] + ay / texsizescale[Y])
			t1 = ptex
			t2 = point2D(ptex[X] + ptexsize[X], ptex[Y])
			t3 = point2D(ptex[X] + ptexsize[X], ptex[Y] + ptexsize[Y])
			t4 = point2D(ptex[X], ptex[Y] + ptexsize[Y])
			
			// Create faces
			var p1, p2, p3, p4, np1, np2, np3, np4;
			if (seginneraxis = X)
			{
				p1 = y1p[outer + 1, inner]
				p2 = y2p[outer + 1, inner]
				p3 = y2p[outer, inner]
				p4 = y1p[outer, inner]
				np1 = y1p[outer + 1, inner + 1]
				np2 = y2p[outer + 1, inner + 1]
				np3 = y2p[outer, inner + 1]
				np4 = y1p[outer, inner + 1]
				
				// East face
				if (eface)
				{
					vbuffer_add_triangle(np2, np1, np4, t1, t2, t3, null, null, null, invert)
					vbuffer_add_triangle(np4, np3, np2, t3, t4, t1, null, null, null, invert)
				}
				
				// West face
				if (wface)
				{
					vbuffer_add_triangle(p1, p2, p3, t1, t2, t3, null, null, null, invert)
					vbuffer_add_triangle(p3, p4, p1, t3, t4, t1, null, null, null, invert)
				}
				
				// South face
				if (!hide_front)
				{
					vbuffer_add_triangle(p2, np2, np3, t2, t1, t4, null, null, null, invert)
					vbuffer_add_triangle(np3, p3, p2, t4, t3, t2, null, null, null, invert)
				}
				
				// North face
				if (!hide_back)
				{
					vbuffer_add_triangle(np1, p1, p4, t2, t1, t4, null, null, null, invert)
					vbuffer_add_triangle(p4, np4, np1, t4, t3, t2, null, null, null, invert)
				}
				
				// Above face
				if (aface)
				{
					vbuffer_add_triangle(p1, np1, np2, t1, t2, t3, null, null, null, invert)
					vbuffer_add_triangle(np2, p2, p1, t3, t4, t1, null, null, null, invert)
				}
				
				// Below face
				if (bface)
				{
					vbuffer_add_triangle(p3, np3, np4, t1, t2, t3, null, null, null, invert)
					vbuffer_add_triangle(np4, p4, p3, t3, t4, t1, null, null, null, invert)
				}
			}
			else
			{
				p1 = y1p[outer, inner]
				p2 = y1p[outer + 1, inner]
				p3 = y2p[outer + 1, inner]
				p4 = y2p[outer, inner]
				np1 = y1p[outer, inner + 1]
				np2 = y1p[outer + 1, inner + 1]
				np3 = y2p[outer + 1, inner + 1]
				np4 = y2p[outer, inner + 1]
				
				// East face
				if (eface)
				{
					vbuffer_add_triangle(np3, np2, p2, t1, t2, t3, null, null, null, invert)
					vbuffer_add_triangle(p2, p3, np3, t3, t4, t1, null, null, null, invert)
				}
				
				// West face
				if (wface)
				{
					vbuffer_add_triangle(np1, np4, p4, t1, t2, t3, null, null, null, invert)
					vbuffer_add_triangle(p4, p1, np1, t3, t4, t1, null, null, null, invert)
				}
				
				// South face
				if (!hide_front)
				{
					vbuffer_add_triangle(np4, np3, p3, t2, t1, t4, null, null, null, invert)
					vbuffer_add_triangle(p3, p4, np4, t4, t3, t2, null, null, null, invert)
				}
				
				// North face
				if (!hide_back)
				{
					vbuffer_add_triangle(np2, np1, p1, t2, t1, t4, null, null, null, invert)
					vbuffer_add_triangle(p1, p2, np2, t4, t3, t2, null, null, null, invert)
				}
				
				// Above face
				if (aface)
				{
					vbuffer_add_triangle(np1, np2, np3, t1, t2, t3, null, null, null, invert)
					vbuffer_add_triangle(np3, np4, np1, t3, t4, t1, null, null, null, invert)
				}
				
				// Below face
				if (bface)
				{
					vbuffer_add_triangle(p4, p3, p2, t1, t2, t3, null, null, null, invert)
					vbuffer_add_triangle(p2, p1, p4, t3, t4, t1, null, null, null, invert)
				}
			}
		}
	}
	
	vertex_emissive = 0
	vertex_wave = e_vertex_wave.NONE
	vertex_wave_zmin = null
	vertex_wave_zmax = null
	
	return vbuffer_done()
}
