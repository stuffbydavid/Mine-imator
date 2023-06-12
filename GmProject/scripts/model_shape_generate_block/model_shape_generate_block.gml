/// model_shape_generate_block(bend)
/// @arg bend
/// @desc Generates a block shape transformed by a bend vector.

function model_shape_generate_block(bend)
{
	// Block dimensions
	var x1, x2, y1, y2, z1, z2, size, scalef;
	x1 = from[X];	y1 = from[Y];	z1 = from[Z]
	x2 = to[X];		y2 = to[Y];		z2 = to[Z]
	size = point3D_sub(to, from)
	scalef = 0.005 // Used to combat Z-fighting
	
	// Find whether the shape is bent
	var isbent = !vec3_equals(bend, vec3(0)) && bend_shape;
	
	// Axis to split up the block
	var segaxis = Z;
	if (isbent)
	{
		if (bend_part = e_part.LEFT || bend_part = e_part.RIGHT)
			segaxis = X
		else if (bend_part = e_part.BACK || bend_part = e_part.FRONT)
			segaxis = Y
		else if (bend_part = e_part.LOWER || bend_part = e_part.UPPER)
			segaxis = Z
	}
	
	// Define texture coordinates to use
	var texsize, texsizefix, texuv;
	texsize = point3D_sub(to_noscale, from_noscale)
	texsizefix = point3D_sub(texsize, vec3(1 / 256)) // Artifact fix with CPU rendering
	
	// Convert to 0-1
	texsize = vec3(texsize[X] / texture_size[X], texsize[Y] / texture_size[Y], texsize[Z] / texture_size[Y])
	texsizefix = vec3(texsizefix[X] / texture_size[X], texsizefix[Y] / texture_size[Y], texsizefix[Z] / texture_size[Y])
	texuv = vec2_div(uv, texture_size)
	
	// Block face texture mapping
	var texeast1, texeast2, texeast3, texeast4;
	var texwest1, texwest2, texwest3, texwest4;
	var texsouth1, texsouth2, texsouth3, texsouth4;
	var texnorth1, texnorth2, texnorth3, texnorth4;
	var texstart1, texstart2, texstart3, texstart4;
	var texend1, texend2, texend3, texend4;
	var texup1, texup2, texup3, texup4;
	var texdown1, texdown2, texdown3, texdown4;
	
	texeast1 = point2D_add(texuv, point2D(texsize[X], 0))
	texeast2 = point2D_add(texeast1, point2D(texsizefix[Y], 0))
	texeast3 = point2D_add(texeast1, point2D(texsizefix[Y], texsizefix[Z]))
	texeast4 = point2D_add(texeast1, point2D(0, texsizefix[Z]))
	
	texwest1 = point2D_sub(texuv, point2D(texsize[Y], 0))
	texwest2 = point2D_add(texwest1, point2D(texsizefix[Y], 0))
	texwest3 = point2D_add(texwest1, point2D(texsizefix[Y], texsizefix[Z]))
	texwest4 = point2D_add(texwest1, point2D(0, texsizefix[Z]))
	
	texsouth1 = point2D_copy(texuv)
	texsouth2 = point2D_add(texsouth1, point2D(texsizefix[X], 0))
	texsouth3 = point2D_add(texsouth1, point2D(texsizefix[X], texsizefix[Z]))
	texsouth4 = point2D_add(texsouth1, point2D(0, texsizefix[Z]))
	
	texnorth1 = point2D_add(texeast1, point2D(texsize[Y], 0))
	texnorth2 = point2D_add(texnorth1, point2D(texsizefix[X], 0))
	texnorth3 = point2D_add(texnorth1, point2D(texsizefix[X], texsizefix[Z]))
	texnorth4 = point2D_add(texnorth1, point2D(0, texsizefix[Z]))
	
	texup1 = point2D_sub(texuv, point2D(0, texsize[Y]))
	texup2 = point2D_add(texup1, point2D(texsizefix[X], 0))
	texup3 = point2D_add(texup1, point2D(texsizefix[X], texsizefix[Y]))
	texup4 = point2D_add(texup1, point2D(0, texsizefix[Y]))
	
	texdown4 = point2D_add(texup1, point2D(texsize[X], 0)) // Down is flipped vertically
	texdown3 = point2D_add(texdown4, point2D(texsizefix[X], 0))
	texdown2 = point2D_add(texdown4, point2D(texsizefix[X], texsizefix[Y]))
	texdown1 = point2D_add(texdown4, point2D(0, texsizefix[Y]))
	
	// Mirror texture on X
	if (texture_mirror)
	{
		// Switch east/west sides
		var tmp1, tmp2, tmp3, tmp4;
		tmp1 = texeast1; tmp2 = texeast2; tmp3 = texeast3; tmp4 = texeast4;
		texeast1 = texwest1; texeast2 = texwest2; texeast3 = texwest3; texeast4 = texwest4;
		texwest1 = tmp1; texwest2 = tmp2; texwest3 = tmp3; texwest4 = tmp4;
		
		// Switch left/right points
		tmp1 = texeast1; texeast1 = texeast2; texeast2 = tmp1
		tmp1 = texeast3; texeast3 = texeast4; texeast4 = tmp1
		tmp1 = texwest1; texwest1 = texwest2; texwest2 = tmp1
		tmp1 = texwest3; texwest3 = texwest4; texwest4 = tmp1
		tmp1 = texsouth1; texsouth1 = texsouth2; texsouth2 = tmp1
		tmp1 = texsouth3; texsouth3 = texsouth4; texsouth4 = tmp1
		tmp1 = texnorth1; texnorth1 = texnorth2; texnorth2 = tmp1
		tmp1 = texnorth3; texnorth3 = texnorth4; texnorth4 = tmp1
		tmp1 = texup1; texup1 = texup2; texup2 = tmp1
		tmp1 = texup3; texup3 = texup4; texup4 = tmp1
		tmp1 = texdown1; texdown1 = texdown2; texdown2 = tmp1
		tmp1 = texdown3; texdown3 = texdown4; texdown4 = tmp1
	}
	
	// Start position and bounds
	var sharpbend, bendsize, detail, bendstart, bendend, bendsegsize, invangle;
	sharpbend = app.project_bend_style = "blocky" && bend_size = null && ((bend_axis[X] && !bend_axis[Y] && !bend_axis[Z]) || (!bend_axis[X] && bend_axis[Y] && !bend_axis[Z]) || (!bend_axis[X] && !bend_axis[Y] && bend_axis[Z]))
	bendsize = (bend_size = null ? (app.project_bend_style = "realistic" ? 4 : 1) : bend_size)
	detail = (sharpbend ? 2 : real(max(bendsize, 2)))
	
	if ((bend_size != null && bend_size >= 1) && scale[segaxis] > .5)
		detail /= scale[segaxis]
	
	bendsegsize = bendsize / detail;
	invangle = (bend_part = e_part.LOWER || bend_part = e_part.BACK || bend_part = e_part.LEFT)
	
	// Find start points/normals
	var p1, p2, p3, p4;
	var n1, n2, n3, n4;
	var texp1, texp2, texp3;
	switch (segaxis)
	{
		case X:
		{
			bendstart = (bend_offset - (position[X] + x1)) - bendsize / 2
			bendend = (bend_offset - (position[X] + x1)) + bendsize / 2
			p1 = point3D(x1, y1, z2)
			p2 = point3D(x1, y2, z2)
			p3 = point3D(x1, y2, z1)
			p4 = point3D(x1, y1, z1)
			n1 = vec3(0, 1, 0)
			n2 = vec3(0, -1, 0)
			n3 = vec3(0, 0, 1)
			n4 = vec3(0, 0, -1)
			texp1 = texsouth1[X] // South/Above X
			texp2 = texnorth2[X] // North X
			texp3 = texdown4[X] // Below X
			texstart1 = texwest1; texstart2 = texwest2; texstart3 = texwest3; texstart4 = texwest4;
			texend1 = texeast1; texend2 = texeast2; texend3 = texeast3; texend4 = texeast4;
			break
		}
		
		case Y:
		{
			bendstart = (bend_offset - (position[Y] + y1)) - bendsize / 2
			bendend = (bend_offset - (position[Y] + y1)) + bendsize / 2
			p1 = point3D(x2, y1, z2)
			p2 = point3D(x1, y1, z2)
			p3 = point3D(x1, y1, z1)
			p4 = point3D(x2, y1, z1)
			n1 = vec3(1, 0, 0)
			n2 = vec3(-1, 0, 0)
			n3 = vec3(0, 0, 1)
			n4 = vec3(0, 0, -1)
			texp1 = texeast2[X] // East X
			texp2 = texwest1[X] // West X
			texp3 = texup1[Y] // Above/Below Y
			texstart1 = texnorth1; texstart2 = texnorth2; texstart3 = texnorth3; texstart4 = texnorth4;
			texend1 = texsouth1; texend2 = texsouth2; texend3 = texsouth3; texend4 = texsouth4;
			break
		}
		
		case Z:
		{
			bendstart = (bend_offset - (position[Z] + z1)) - bendsize / 2
			bendend = (bend_offset - (position[Z] + z1)) + bendsize / 2
			p1 = point3D(x1, y2, z1)
			p2 = point3D(x2, y2, z1)
			p3 = point3D(x2, y1, z1)
			p4 = point3D(x1, y1, z1)
			n1 = vec3(1, 0, 0)
			n2 = vec3(-1, 0, 0)
			n3 = vec3(0, 1, 0)
			n4 = vec3(0, -1, 0)
			texp1 = texsouth3[Y] // East/South/West/North Y
			texstart1 = texdown1; texstart2 = texdown2; texstart3 = texdown3; texstart4 = texdown4;
			texend1 = texup1; texend2 = texup2; texend3 = texup3; texend4 = texup4;
			break
		}
	}
	
	// Apply transform
	var mat;
	if (isbent) // Apply start bend
	{
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
		
		mat = model_part_get_bend_matrix(id, bendvec, vec3(0), vec3_add(vec3(1), startscale))
	}
	else // Apply rotation only
		mat = matrix_build(0, 0, 0, rotation[X], rotation[Y], rotation[Z], 1, 1, 1)
	
	p1 = point3D_mul_matrix(p1, mat)
	p2 = point3D_mul_matrix(p2, mat)
	p3 = point3D_mul_matrix(p3, mat)
	p4 = point3D_mul_matrix(p4, mat)
	n1 = vec3_normalize(vec3_mul_matrix(n1, mat))
	n2 = vec3_normalize(vec3_mul_matrix(n2, mat))
	n3 = vec3_normalize(vec3_mul_matrix(n3, mat))
	n4 = vec3_normalize(vec3_mul_matrix(n4, mat))
	
	// Create triangles
	vbuffer_start()
	
	vertex_emissive = color_emissive
	vertex_wave = wind_wave
	vertex_wave_zmin = wind_wave_zmin
	vertex_wave_zmax = wind_wave_zmax
	
	var segpos = 0;
	while (true)
	{
		// End face
		if (segpos >= size[segaxis] - 0.0001)
		{
			switch (segaxis)
			{
				case X: case Y:
				{
					// Flip left/right positions
					vbuffer_add_triangle(p2, p1, p4, texend1, texend2, texend3, null, null, null, invert)
					vbuffer_add_triangle(p4, p3, p2, texend3, texend4, texend1, null, null, null, invert)
					break
				}
				
				case Z:
				{
					// Flip top/bottom positions
					vbuffer_add_triangle(p4, p3, p2, texend1, texend2, texend3, null, null, null, invert)
					vbuffer_add_triangle(p2, p1, p4, texend3, texend4, texend1, null, null, null, invert)
					break
				}
			}
			break
		}
		
		// Start face
		if (segpos = 0)
		{
			vbuffer_add_triangle(p1, p2, p3, texstart1, texstart2, texstart3, null, null, null, invert)
			vbuffer_add_triangle(p3, p4, p1, texstart3, texstart4, texstart1, null, null, null, invert)
		}
		
		var segsize;
		var np1, np2, np3, np4;
		var nn1, nn2, nn3, nn4;
		var ntexp1, ntexp2, ntexp3;
		
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
		
		// Find next points/normals
		switch (segaxis)
		{
			case X:
			{
				// West points
				np1 = point3D(x1 + segpos, y1, z2)
				np2 = point3D(x1 + segpos, y2, z2)
				np3 = point3D(x1 + segpos, y2, z1)
				np4 = point3D(x1 + segpos, y1, z1)
				nn1 = vec3(0, 1, 0)
				nn2 = vec3(0, -1, 0)
				nn3 = vec3(0, 0, 1)
				nn4 = vec3(0, 0, -1)
				var toff = (segpos / size[X]) * texsizefix[X] * negate(texture_mirror);
				ntexp1 = texsouth1[X] + toff // South/Above X
				ntexp2 = texnorth2[X] - toff // North X
				ntexp3 = texdown4[X] + toff // Below X
				break
			}
			
			case Y:
			{
				// South points
				np1 = point3D(x2, y1 + segpos, z2)
				np2 = point3D(x1, y1 + segpos, z2)
				np3 = point3D(x1, y1 + segpos, z1)
				np4 = point3D(x2, y1 + segpos, z1)
				nn1 = vec3(1, 0, 0)
				nn2 = vec3(-1, 0, 0)
				nn3 = vec3(0, 0, 1)
				nn4 = vec3(0, 0, -1)
				var toff = (segpos / size[Y]) * texsizefix[Y];
				ntexp1 = texeast2[X] - toff * negate(texture_mirror) // East X
				ntexp2 = texwest1[X] + toff * negate(texture_mirror) // West X
				ntexp3 = texup1[Y] + toff // Above/Below Y
				break
			}
			
			case Z:
			{
				// Upper points
				np1 = point3D(x1, y2, z1 + segpos)
				np2 = point3D(x2, y2, z1 + segpos)
				np3 = point3D(x2, y1, z1 + segpos)
				np4 = point3D(x1, y1, z1 + segpos)
				nn1 = vec3(1, 0, 0)
				nn2 = vec3(-1, 0, 0)
				nn3 = vec3(0, 1, 0)
				nn4 = vec3(0, -1, 0)
				var toff = (segpos / size[Z]) * texsizefix[Z];
				ntexp1 = texsouth3[Y] - toff // East/South/West/North Y
				break
			}
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
			{
				bendscale = model_shape_get_bend_scale(bendstart, bendend, segp, false, segpos, bend)
				bendvec = vec3_mul(bend, segp)
			}
			
			mat = model_part_get_bend_matrix(id, bendvec, vec3(0), vec3_add(vec3_add(vec3(1), bendscale), vec3(segp * scalef)))
		}
		else // Apply rotation only
			mat = matrix_build(0, 0, 0, rotation[X], rotation[Y], rotation[Z], 1, 1, 1)
		
		np1 = point3D_mul_matrix(np1, mat)
		np2 = point3D_mul_matrix(np2, mat)
		np3 = point3D_mul_matrix(np3, mat)
		np4 = point3D_mul_matrix(np4, mat)
		
		// Sharp lighting
		if (sharpbend)
		{
			n1 = null
			n2 = null
			n3 = null
			n4 = null
			
			nn1 = null
			nn2 = null
			nn3 = null
			nn4 = null
		}
		else
		{
			nn1 = vec3_normalize(vec3_mul_matrix(nn1, mat))
			nn2 = vec3_normalize(vec3_mul_matrix(nn2, mat))
			nn3 = vec3_normalize(vec3_mul_matrix(nn3, mat))
			nn4 = vec3_normalize(vec3_mul_matrix(nn4, mat))
		}
		
		// Add surrounding faces
		var t1, t2, t3, t4;
		switch (segaxis)
		{
			case X:
			{
				// South
				t1 = vec2(texp1, texsouth1[Y])
				t2 = vec2(ntexp1, texsouth1[Y])
				t3 = vec2(ntexp1, texsouth3[Y])
				t4 = vec2(texp1, texsouth3[Y])
				vbuffer_add_triangle(p2, np2, np3, t1, t2, t3, n1, nn1, nn1, invert)
				vbuffer_add_triangle(np3, p3, p2, t3, t4, t1, nn1, n1, n1, invert)
				
				// North
				t1 = vec2(ntexp2, texnorth1[Y])
				t2 = vec2(texp2, texnorth1[Y])
				t3 = vec2(texp2, texnorth3[Y])
				t4 = vec2(ntexp2, texnorth3[Y])
				vbuffer_add_triangle(np1, p1, p4, t1, t2, t3, nn2, n2, n2, invert)
				vbuffer_add_triangle(p4, np4, np1, t3, t4, t1, n2, nn2, nn2, invert)
				
				// Up
				t1 = vec2(texp1, texup1[Y])
				t2 = vec2(ntexp1, texup1[Y])
				t3 = vec2(ntexp1, texup3[Y])
				t4 = vec2(texp1, texup3[Y])
				vbuffer_add_triangle(p1, np1, np2, t1, t2, t3, n3, nn3, nn3, invert)
				vbuffer_add_triangle(np2, p2, p1, t3, t4, t1, nn3, n3, n3, invert)
				
				// Down
				t1 = vec2(texp3, texdown1[Y])
				t2 = vec2(ntexp3, texdown1[Y])
				t3 = vec2(ntexp3, texdown3[Y])
				t4 = vec2(texp3, texdown3[Y])
				vbuffer_add_triangle(p3, np3, np4, t1, t2, t3, n4, nn4, nn4, invert)
				vbuffer_add_triangle(np4, p4, p3, t3, t4, t1, nn4, n4, n4, invert)
				
				texp1 = ntexp1; texp2 = ntexp2; texp3 = ntexp3;
				break
			}
			
			case Y:
			{
				// East
				t1 = vec2(ntexp1, texeast1[Y])
				t2 = vec2(texp1, texeast1[Y])
				t3 = vec2(texp1, texeast3[Y])
				t4 = vec2(ntexp1, texeast3[Y])
				vbuffer_add_triangle(np1, p1, p4, t1, t2, t3, nn1, n1, n1, invert)
				vbuffer_add_triangle(p4, np4, np1, t3, t4, t1, n1, nn1, nn1, invert)
				
				// West
				t1 = vec2(texp2, texwest1[Y])
				t2 = vec2(ntexp2, texwest1[Y])
				t3 = vec2(ntexp2, texwest3[Y])
				t4 = vec2(texp2, texwest3[Y])
				vbuffer_add_triangle(p2, np2, np3, t1, t2, t3, n2, nn2, nn2, invert)
				vbuffer_add_triangle(np3, p3, p2, t3, t4, t1, nn2, n2, n2, invert)
				
				// Up
				t1 = vec2(texup1[X], texp3)
				t2 = vec2(texup2[X], texp3)
				t3 = vec2(texup2[X], ntexp3)
				t4 = vec2(texup1[X], ntexp3)
				vbuffer_add_triangle(p2, p1, np1, t1, t2, t3, n3, n3, nn3, invert)
				vbuffer_add_triangle(np1, np2, p2, t3, t4, t1, nn3, nn3, n3, invert)
				
				// Down
				t1 = vec2(texdown1[X], ntexp3)
				t2 = vec2(texdown2[X], ntexp3)
				t3 = vec2(texdown2[X], texp3)
				t4 = vec2(texdown1[X], texp3)
				vbuffer_add_triangle(np3, np4, p4, t1, t2, t3, nn4, nn4, n4, invert)
				vbuffer_add_triangle(p4, p3, np3, t3, t4, t1, n4, n4, nn4, invert)
				
				texp1 = ntexp1; texp2 = ntexp2; texp3 = ntexp3;
				break
			}
			
			case Z:
			{
				// East
				t1 = vec2(texeast1[X], ntexp1)
				t2 = vec2(texeast2[X], ntexp1)
				t3 = vec2(texeast2[X], texp1)
				t4 = vec2(texeast1[X], texp1)
				vbuffer_add_triangle(np2, np3, p3, t1, t2, t3, nn1, nn1, n1, invert)
				vbuffer_add_triangle(p3, p2, np2, t3, t4, t1, n1, n1, nn1, invert)
				
				// West
				t1 = vec2(texwest1[X], ntexp1)
				t2 = vec2(texwest2[X], ntexp1)
				t3 = vec2(texwest2[X], texp1)
				t4 = vec2(texwest1[X], texp1)
				vbuffer_add_triangle(np4, np1, p1, t1, t2, t3, nn2, nn2, n2, invert)
				vbuffer_add_triangle(p1, p4, np4, t3, t4, t1, n2, n2, nn2, invert)
				
				// South
				t1 = vec2(texsouth1[X], ntexp1)
				t2 = vec2(texsouth2[X], ntexp1)
				t3 = vec2(texsouth2[X], texp1)
				t4 = vec2(texsouth1[X], texp1)
				vbuffer_add_triangle(np1, np2, p2, t1, t2, t3, nn3, nn3, n3, invert)
				vbuffer_add_triangle(p2, p1, np1, t3, t4, t1, n3, n3, nn3, invert)
				
				// North
				t1 = vec2(texnorth1[X], ntexp1)
				t2 = vec2(texnorth2[X], ntexp1)
				t3 = vec2(texnorth2[X], texp1)
				t4 = vec2(texnorth1[X], texp1)
				vbuffer_add_triangle(np3, np4, p4, t1, t2, t3, nn4, nn4, n4, invert)
				vbuffer_add_triangle(p4, p3, np3, t3, t4, t1, n4, n4, nn4, invert)
				
				texp1 = ntexp1
				break
			}
		}
		
		p1 = np1; p2 = np2; p3 = np3; p4 = np4;
		n1 = nn1; n2 = nn2; n3 = nn3; n4 = nn4;
	}
	
	vertex_emissive = 0
	vertex_wave = e_vertex_wave.NONE
	vertex_wave_zmin = null
	vertex_wave_zmax = null
	
	return vbuffer_done()
}
