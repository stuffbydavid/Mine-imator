/// CppGen vec planebend
/// @desc Generates a plane shape transformed by a bend vector.

function model_shape_generate_plane(planebend, usegpu = true)
{
	// Plane dimensions
	var x1, x2, y1, z1, z2, size;
	x1 = from[X];	y1 = from[Y];	z1 = from[Z]
	x2 = to[X];						z2 = to[Z]
	size = point3D_sub(to, from)
	
	// Find whether the shape is bent
	var gpubend = usegpu && is_cpp() && bend_shape && bend_part != null;
	var isbent = gpubend || (!vec3_equals(planebend, vec3(0)) && bend_shape);
	
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
	
	if (floor_box_uvs)
	{
		for (var i = X; i <= Z; i++)
			texsize[i] = (frac(texsize[i]) ? floor(texsize[i] + 0.000001) : floor(texsize[i]))
	}
	
	// Convert to 0-1
	texsize = vec3(texsize[X] / texture_size[X], texsize[Y] / texture_size[Y], texsize[Z] / texture_size[Y])
	texuv = vec2_div(floor_box_uvs ? [ floor(uv[X]), floor(uv[Y]) ] : uv, texture_size)
	
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
	var detail;
	var sharpbend, bendsize, bendstart, bendend, bendsegsize, invangle;
	sharpbend = app.project_bend_style = "blocky" && bend_size = null && ((bend_axis[X] && !bend_axis[Y] && !bend_axis[Z]) || (!bend_axis[X] && bend_axis[Y] && !bend_axis[Z]) || (!bend_axis[X] && !bend_axis[Y] && bend_axis[Z]))
	bendsize = (bend_size = null ? (app.project_bend_style = "realistic" ? 4 : 1) : bend_size)
	detail = (sharpbend ? 2 : real(max(bendsize, 2)))
	
	if ((bend_size != null && bend_size >= 1) && scale[segaxis] > .5)
		detail /= scale[segaxis]
	
	bendsegsize = bendsize / detail
	invangle = (bend_part = e_part.LOWER || bend_part = e_part.BACK || bend_part = e_part.LEFT)

	var segextent = size[segaxis];
	var segfrom = from[segaxis];
	var mirrorfactor = negate(texture_mirror);
	var smoothnormals = !sharpbend && !has_vertex_offsets;
	var offsetnormals = !sharpbend && has_vertex_offsets;
	var basen1 = vec3(0, 1, 0);
	var basen2 = vec3(0, -1, 0);
	
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
	
	var offset1, offset2, delta1, delta2;
	if (segaxis = X)
	{
		offset1 = point3D_copy(vertex_offsets[2])
		offset2 = point3D_copy(vertex_offsets[0])
		delta1 = vec3_sub(vertex_offsets[3], offset1)
		delta2 = vec3_sub(vertex_offsets[1], offset2)
	}
	else
	{
		offset1 = point3D_copy(vertex_offsets[0])
		offset2 = point3D_copy(vertex_offsets[1])
		delta1 = vec3_sub(vertex_offsets[2], offset1)
		delta2 = vec3_sub(vertex_offsets[3], offset2)
	}
	p1 = vec3_add(p1, offset1)
	p2 = vec3_add(p2, offset2)

	// Apply transform
	var mat;
	if (isbent && !gpubend) // Apply start bend
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
		
		var startweight = ease("easeinoutquint", startp);
		bendvec = vec3(planebend[X] * startweight, planebend[Y] * startweight, planebend[Z] * startp)
		
		// Blocky bending
		var startscale = vec3(0);
		if (sharpbend && 0 > bendstart && 0 < bendend)
		{
			var pinchaxis, pinchangle, pinchfactor, startpinch;
			if (vec3_equals(bend_axis, vec3(true, false, false)))
				pinchaxis = X
			else if (vec3_equals(bend_axis, vec3(false, true, false)))
				pinchaxis = Y
			else if (vec3_equals(bend_axis, vec3(false, false, true)))
				pinchaxis = Z
			pinchangle = abs(planebend[pinchaxis])
			if (pinchangle > 90)
				pinchangle -= (pinchangle - 90) * 2
			pinchfactor = clamp(percent(pinchangle, 0, 90), 0, 1)
			startpinch = (startp <= 0.5 ? startp * 2 : (1 - startp) * 2)
			startpinch *= pinchfactor
			startpinch = ease("easeincubic", startpinch) / 2.5
			startscale = vec3(pinchaxis = X ? 0 : startpinch, pinchaxis = Y ? 0 : startpinch, pinchaxis = Z ? 0 : startpinch)
		}
		
		mat = model_part_get_bend_matrix(id, bendvec, vec3(0), vec3_add(startscale, vec3(1 + (startp * 0))))
	}
	else // Apply rotation only
		mat = matrix_build(0, 0, 0, rotation[X], rotation[Y], rotation[Z], 1, 1, 1)
	
	p1 = point3D_mul_matrix(p1, mat)
	p2 = point3D_mul_matrix(p2, mat)
	if (gpubend)
	{
		p1 = model_shape_bend_point(p1, 0, bendstart, bendsize, invangle, true)
		p2 = model_shape_bend_point(p2, 0, bendstart, bendsize, invangle, true)
	}
	if (smoothnormals)
	{
		n1 = vec3_normalize(vec3_mul_matrix(basen1, mat))
		n2 = vec3_normalize(vec3_mul_matrix(basen2, mat))
	}
	else
	{
		n1 = null; n2 = null;
	}
	
	// Create triangles
	vbuffer_start()
	if (gpubend)
		model_shape_bend_configure(2, sharpbend)
	
	vertex_emissive = color_emissive
	vertex_wave = wind_wave
	vertex_wave_zmin = wind_wave_zmin
	vertex_wave_zmax = wind_wave_zmax
	
	var segpos = 0;
	while (segpos < segextent)
	{
		var segsize;
		var np1, np2;
		var nn1, nn2;
		var ntexp1;
		
		// Find segment size
		if (!isbent || segpos >= bendend) // No/Above bend
			segsize = segextent - segpos
		else if (segpos < bendstart) // Below bend
			segsize = min(segextent - segpos, bendstart)
		else // Within bend
		{
			segsize = bendsegsize
			
			if (segpos = 0) // Start inside bend, apply partial size
				segsize -= (segfrom - bendstart) % bendsegsize
			
			segsize = min(segextent - segpos, segsize)
		}
		
		// Advance
		segpos += max(segsize, 0.005)
		if (segaxis = X)
		{
			// Right points
			np1 = point3D(x1 + segpos, y1, z2)
			np2 = point3D(x1 + segpos, y1, z1)
			var toff = (segpos / size[X]) * texsize[X] * mirrorfactor;
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
		
		var offsetamount = segpos / segextent;
		np1 = vec3(
			np1[X] + (offset1[X] + delta1[X] * offsetamount),
			np1[Y] + (offset1[Y] + delta1[Y] * offsetamount),
			np1[Z] + (offset1[Z] + delta1[Z] * offsetamount)
		)
		np2 = vec3(
			np2[X] + (offset2[X] + delta2[X] * offsetamount),
			np2[Y] + (offset2[Y] + delta2[Y] * offsetamount),
			np2[Z] + (offset2[Z] + delta2[Z] * offsetamount)
		)

		// Apply transform
		if (isbent && !gpubend) // Apply segment bend
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
			
			// Flat planes retain eased angles even for sharp segments
			var segweight = ease("easeinoutquint", segp);
			bendvec = vec3(planebend[X] * segweight, planebend[Y] * segweight, planebend[Z] * segp)
			
			// Segment pinching was disabled in the original plane generator
			mat = model_part_get_bend_matrix(id, bendvec, vec3(0), vec3(1))
		}
		np1 = point3D_mul_matrix(np1, mat)
		np2 = point3D_mul_matrix(np2, mat)
		if (gpubend)
		{
			np1 = model_shape_bend_point(np1, segpos, bendstart, bendsize, invangle)
			np2 = model_shape_bend_point(np2, segpos, bendstart, bendsize, invangle)
		}
		if (smoothnormals)
		{
			nn1 = vec3_normalize(vec3_mul_matrix(basen1, mat))
			nn2 = vec3_normalize(vec3_mul_matrix(basen2, mat))
		}
		
		if (offsetnormals)
		{
			var normal1, normal2;
			if (segaxis = X)
			{
				normal1 = vec3_cross(vec3_sub(np1, p1), vec3_sub(np2, p1))
				normal2 = vec3_cross(vec3_sub(p2, np2), vec3_sub(p1, np2))
			}
			else
			{
				normal1 = vec3_cross(vec3_sub(np2, np1), vec3_sub(p2, np1))
				normal2 = vec3_cross(vec3_sub(p1, p2), vec3_sub(np1, p2))
			}

			nn1 = vec3_normalize(vec3_add(normal1, normal2))
			nn2 = vec3_mul(nn1, -1)
			if (gpubend)
			{
				// Retain front/back orientation even when the rest quad has zero area
				nn1 = vec4(nn1[X], nn1[Y], nn1[Z], 1)
				nn2 = vec4(nn2[X], nn2[Y], nn2[Z], -1)
			}
			n1 = nn1
			n2 = nn2
		}

		// Sharp lighting
		if (sharpbend)
		{
			n1 = null
			n2 = null
			
			nn1 = null
			nn2 = null
		}
		
		if (gpubend && offsetnormals)
			vertex_bend_quad(vbuffer_current, p1, np1, np2, p2)

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
				vbuffer_add_triangle_bend(p1, np1, np2, t1, t2, t3, n1, nn1, nn1, invert)
				vbuffer_add_triangle_bend(np2, p2, p1, t3, t4, t1, nn1, n1, n1, invert)
			}
			
			// North
			if (!hide_back)
			{
				vbuffer_add_triangle_bend(np1, p1, np2, t2, t1, t3, nn2, n2, nn2, invert)
				vbuffer_add_triangle_bend(p2, np2, p1, t4, t3, t1, n2, nn2, n2, invert)
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
				vbuffer_add_triangle_bend(np1, np2, p2, t1, t2, t3, nn1, nn1, n1, invert)
				vbuffer_add_triangle_bend(p2, p1, np1, t3, t4, t1, n1, n1, nn1, invert)
			}
			
			// North
			if (!hide_back)
			{
				vbuffer_add_triangle_bend(np2, np1, p2, t2, t1, t3, nn2, nn2, n2, invert)
				vbuffer_add_triangle_bend(p1, p2, np1, t4, t3, t1, n2, n2, nn2, invert)
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
	
	var vbuf = vbuffer_done();
	if (gpubend)
		vertex_bend_update(vbuf, planebend)
	return vbuf
}
