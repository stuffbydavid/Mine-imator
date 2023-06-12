/// model_shape_generate_plane(bend)
/// @arg bend
/// @desc Generates a plane shape transformed by a bend vector.

function model_shape_generate_plane(bend)
{
	// Plane dimensions
	var x1, x2, y1, z1, z2, size, scalef;
	x1 = from[X];	y1 = from[Y];	z1 = from[Z]
	x2 = to[X];						z2 = to[Z]
	size = point3D_sub(to, from)
	scalef = 0.005
	
	// Find whether the shape is bent
	var isbent = !vec3_equals(bend, vec3(0)) && bend_shape;
	
	// Axis to split up the plane
	var segaxis = Z;
	if (isbent)
	{
		if (bend_part = e_part.LEFT || bend_part = e_part.RIGHT)
			segaxis = X
		else if (bend_part = e_part.BACK || bend_part = e_part.FRONT)
			segaxis = Z
		else if (bend_part = e_part.LOWER || bend_part = e_part.UPPER)
			segaxis = Z
	}
	
	// Define texture coordinates to use
	var texsize, texuv;
	texsize = point3D_sub(to_noscale, from_noscale)
	
	// Convert to 0-1
	texsize = vec3(texsize[X] / texture_size[X], texsize[Y] / texture_size[Y], texsize[Z] / texture_size[Y])
	texuv = vec2_div(uv, texture_size)
	
	// Plane texture mapping
	var tex1, tex2, tex3, tex4;
	tex1 = point2D_copy(texuv)
	tex2 = point2D_add(tex1, point2D(texsize[X], 0))
	tex3 = point2D_add(tex1, point2D(texsize[X], texsize[Z]))
	tex4 = point2D_add(tex1, point2D(0, texsize[Z]))
	
	// Mirror texture on X
	if (texture_mirror)
	{
		// Switch left/right points
		var tmp;
		tmp = tex2; tex2 = tex1; tex1 = tmp;
		tmp = tex3; tex3 = tex4; tex4 = tmp;
	}
	
	// Start position and bounds
	var detail = 2;
	var sharpbend, bendsize, bendstart, bendend, bendsegsize, invangle;
	sharpbend = app.project_bend_style = "blocky" && bend_size = null && ((bend_axis[X] && !bend_axis[Y] && !bend_axis[Z]) || (!bend_axis[X] && bend_axis[Y] && !bend_axis[Z]) || (!bend_axis[X] && !bend_axis[Y] && bend_axis[Z]))
	bendsize = (bend_size = null ? (app.project_bend_style = "realistic" ? 4 : 1) : bend_size)
	detail = (sharpbend ? 2 : real(max(bendsize, 2)))
	
	if ((bend_size != null && bend_size >= 1) && scale[segaxis] > .5)
		detail /= scale[segaxis]
	
	bendsegsize = bendsize / detail;
	invangle = (bend_part = e_part.LOWER || bend_part = e_part.BACK || bend_part = e_part.LEFT)
	
	var p1, p2, n1, n2;
	var texp1;
	
	if (segaxis = X)
	{
		bendstart = (bend_offset - (position[X] + x1)) - bendsize / 2
		bendend = (bend_offset - (position[X] + x1)) + bendsize / 2
		p1 = point3D(x1, y1, z2)
		p2 = point3D(x1, y1, z1)
		texp1 = tex1[X]
	}
	else if (segaxis = Z || segaxis = Y)
	{
		bendstart = (bend_offset - (position[Z] + z1)) - bendsize / 2
		bendend = (bend_offset - (position[Z] + z1)) + bendsize / 2
		p1 = point3D(x1, y1, z1)
		p2 = point3D(x2, y1, z1)
		texp1 = tex3[Y]
	}
	
	// Apply transform
	var mat;
	if (isbent) // Apply start bend
	{
		// Angle
		var startp, bendvec;
		if (bendstart > 0) // Below bend, no angle
			startp = 0
		else if (bendend < 0) // Above bend, apply full angle
			startp = 1
		else // Start inside bend, apply partial angle
			startp = (1 - bendend / bendsize)
		
		if (invangle)
			startp = 1 - startp
		
		bendvec = model_shape_get_bend(bend, startp)
		
		// Blocky bending
		var startscale = vec3(0);
		if (sharpbend)
			startscale = model_shape_get_bend_scale(bendstart, bendend, startp, true, 0, bend)
		
		mat = model_part_get_bend_matrix(id, bendvec, vec3(0), vec3_add(startscale, vec3(1 + (startp * 0))))
	}
	else // Apply rotation only
		mat = matrix_build(0, 0, 0, rotation[X], rotation[Y], rotation[Z], 1, 1, 1)
	
	p1 = point3D_mul_matrix(p1, mat)
	p2 = point3D_mul_matrix(p2, mat)
	n1 = vec3_normalize(vec3_mul_matrix(vec3(0, 1, 0), mat))
	n2 = vec3_normalize(vec3_mul_matrix(vec3(0, -1, 0), mat))
	
	// Create triangles
	vbuffer_start()
	
	vertex_emissive = color_emissive
	vertex_wave = wind_wave
	vertex_wave_zmin = wind_wave_zmin
	vertex_wave_zmax = wind_wave_zmax
	
	var segpos = 0;
	while (segpos < size[segaxis])
	{
		var segsize;
		var np1, np2;
		var nn1, nn2;
		var ntexp1;
		
		// Find segment size
		if (!isbent || segpos >= bendend) // No/Above bend
			segsize = size[segaxis] - segpos
		else if (segpos < bendstart) // Below bend
			segsize = min(size[segaxis] - segpos, bendstart)
		else // Within bend
		{
			segsize = bendsegsize
			
			if (segpos = 0) // Start inside bend, apply partial size
				segsize -= (from[segaxis] - bendstart) % bendsegsize
			
			segsize = min(size[segaxis] - segpos, segsize)
		}
		
		// Advance
		segpos += max(segsize, 0.005)
		if (segaxis = X)
		{
			// Right points
			np1 = point3D(x1 + segpos, y1, z2)
			np2 = point3D(x1 + segpos, y1, z1)
			var toff = (segpos / size[X]) * texsize[X] * negate(texture_mirror);
			ntexp1 = tex1[X] + toff
		}
		else if (segaxis = Z)
		{
			// Upper points
			np1 = point3D(x1, y1, z1 + segpos)
			np2 = point3D(x2, y1, z1 + segpos)
			var toff = (segpos / size[Z]) * texsize[Z];
			ntexp1 = tex3[Y] - toff
		}
		
		// Apply transform
		if (isbent) // Apply segment bend
		{
			var segp, bendvec;
			if (segpos < bendstart) // Below bend, no angle
				segp = 0
			else if (segpos >= bendend) // Above bend, apply full angle
				segp = 1
			else // Inside bend, apply partial angle
				segp = (1 - (bendend - segpos) / bendsize)
			
			if (invangle)
				segp = 1 - segp
			
			bendvec = model_shape_get_bend(bend, segp)
			
			// Blocky bending
			var bendscale = vec3(0);
			if (sharpbend)
				startscale = model_shape_get_bend_scale(bendstart, bendend, segp, true, segpos, bend)
			
			mat = model_part_get_bend_matrix(id, bendvec, vec3(0), vec3_add(bendscale, vec3(1)))
		}
		else // Apply rotation only
			mat = matrix_build(0, 0, 0, rotation[X], rotation[Y], rotation[Z], 1, 1, 1)
		
		np1 = point3D_mul_matrix(np1, mat)
		np2 = point3D_mul_matrix(np2, mat)
		nn1 = vec3_normalize(vec3_mul_matrix(vec3(0, 1, 0), mat))
		nn2 = vec3_normalize(vec3_mul_matrix(vec3(0, -1, 0), mat))
		
		// Sharp lighting
		if (sharpbend)
		{
			n1 = null
			n2 = null
			
			nn1 = null
			nn2 = null
		}
		
		// Add faces
		var t1, t2, t3, t4;
		if (segaxis = X)
		{
			t1 = vec2(texp1, tex1[Y])
			t2 = vec2(ntexp1, tex1[Y])
			t3 = vec2(ntexp1, tex3[Y])
			t4 = vec2(texp1, tex3[Y])
			
			// South
			if (!hide_front)
			{
				vbuffer_add_triangle(p1, np1, np2, t1, t2, t3, n1, nn1, nn1, invert)
				vbuffer_add_triangle(np2, p2, p1, t3, t4, t1, nn1, n1, n1, invert)
			}
			
			// North
			if (!hide_back)
			{
				vbuffer_add_triangle(np1, p1, np2, t2, t1, t3, nn2, n2, nn2, invert)
				vbuffer_add_triangle(p2, np2, p1, t4, t3, t1, n2, nn2, n2, invert)
			}
		}
		else if (segaxis = Z)
		{
			t1 = vec2(tex1[X], ntexp1)
			t2 = vec2(tex2[X], ntexp1)
			t3 = vec2(tex2[X], texp1)
			t4 = vec2(tex1[X], texp1)
			
			// South
			if (!hide_front)
			{
				vbuffer_add_triangle(np1, np2, p2, t1, t2, t3, nn1, nn1, n1, invert)
				vbuffer_add_triangle(p2, p1, np1, t3, t4, t1, n1, n1, nn1, invert)
			}
			
			// North
			if (!hide_back)
			{
				vbuffer_add_triangle(np2, np1, p2, t2, t1, t3, nn2, nn2, n2, invert)
				vbuffer_add_triangle(p1, p2, np1, t4, t3, t1, n2, n2, nn2, invert)
			}
		}
		
		p1 = np1; p2 = np2;
		n1 = nn1; n2 = nn2;
		texp1 = ntexp1
	}
	
	vertex_emissive = 0
	vertex_wave = e_vertex_wave.NONE
	vertex_wave_zmin = null
	vertex_wave_zmax = null
	
	return vbuffer_done()
}
