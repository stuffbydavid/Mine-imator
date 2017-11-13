/// model_shape_get_bend_vbuffer(shape, angle, round, alphaarraymap)
/// @arg shape
/// @arg angle
/// @arg round
/// @arg alphaarraymap
/// @desc Returns an "in-between" mesh that connects the two halves of the given shape.

var shape, angle, roundbend, alphaarrmap, alphaarr;
shape = argument0
angle = tl_value_clamp(e_value.BEND_ANGLE, argument1)
roundbend = argument2
alphaarrmap = argument3

if (alphaarrmap != null && !is_undefined(alphaarrmap[?shape]))
	alphaarr = alphaarrmap[?shape]
else
	alphaarr = null

with (shape)
{
	if (bend_mode != e_shape_bend.BEND)
		return null
	
	vertex_brightness = shape.color_brightness
	
	// Invert angle
	if (bend_invert)
		angle = -angle

	// Limit angle
	if (bend_direction = e_bend.FORWARD)
		angle = min(0, -angle)
	else if (bend_direction = e_bend.BACKWARD)
		angle = max(0, angle)
	
	var anglesign, partsign, detail;
	anglesign = sign(angle)
	angle = abs(angle)
	detail = test(roundbend, app.setting_bend_detail, 2)

	if (bend_part = e_part.LEFT || bend_part = e_part.BACK || bend_part = e_part.LOWER)
		partsign = -1
	else
		partsign = 1

	var invertsign, texsize, texsizefix, sizefill, pmid, nmid;
	var sqrtlen, backnormal;
	var pmidtex, nmidtex, pedgetex, nedgetex, nbacktex, pbacktex;
	invertsign = negate(invert)
	texsize = point3D_sub(to_noscale, from_noscale)
	backnormal = array(null, null)
	sqrtlen = sqrt(2 - abs(90 - angle) / 90)
	
	// Artifact fix with CPU rendering
	texsizefix = point3D_sub(texsize, vec3(1 / 64))

	switch (bend_axis)
	{
		case X:
		{
			// Z+ or Z- half being bent
			if (bend_part = e_part.UPPER || bend_part = e_part.LOWER)
			{
				// Middle position
				sizefill = test(anglesign * partsign < 0, to[Y], -from[Y])
				pmid = point3D(to[X], 0, 0)
				nmid = point3D(from[X], pmid[Y], pmid[Z])
		
				// Normal
				if (roundbend)
				{
					backnormal[0] = vec3(0, dcos(0) * anglesign * (-partsign), dsin(0) * partsign)
					backnormal[1] = vec3(0, dcos(angle * 0.75) * anglesign * (-partsign), dsin(angle * 0.75) * partsign)
				}
			
				// Texture
				var midtexy = (to[Z] - (bend_offset - position[Z])) / scale[Z];
				if (type = "block")
				{
					pmidtex = point2D_add(uv, point2D(texsize[X] + to_noscale[Y], midtexy)) // East middle
					nmidtex = point2D_add(uv, point2D(-to_noscale[Y], midtexy)) // West middle
					if (anglesign * partsign > 0)
					{
						pedgetex = point2D_add(uv, point2D(texsize[X] + texsizefix[Y], midtexy)) // East right middle
						pbacktex = pedgetex // Back left middle
						nedgetex = point2D_add(uv, point2D(-texsizefix[Y], midtexy)) // West left middle
						nbacktex = point2D_add(pbacktex, point2D(texsizefix[X], 0)) // Back right middle
					}
					else
					{
						pedgetex = point2D_add(uv, point2D(texsize[X], midtexy)) // East left middle
						pbacktex = pedgetex // Front right middle
						nedgetex = point2D_add(uv, point2D(0, midtexy)) // West right middle
						nbacktex = nedgetex // Front left middle
					}
				}
				else
				{
					pmidtex = point2D_add(uv, point2D(texsize[X], midtexy))
					nmidtex = point2D_add(uv, point2D(0, midtexy))
					pedgetex = pmidtex
					pbacktex = pmidtex
					nedgetex = nmidtex
					nbacktex = nmidtex
				}
			}
		
			// Y+ or Y- half being bent
			else if (bend_part = e_part.FRONT || bend_part = e_part.BACK)
			{
				// Middle position
				sizefill = test(anglesign * partsign > 0, to[Z], -from[Z])
				pmid = point3D(to[X], 0, 0)
				nmid = point3D(from[X], pmid[Y], pmid[Z])
			
				// Normal
				if (roundbend)
				{
					backnormal[0] = vec3(0, dsin(0) * partsign, dcos(0) * anglesign * partsign)
					backnormal[1] = vec3(0, dsin(angle * 0.75) * partsign, dcos(angle * 0.75) * anglesign * partsign)
				}
			
				// Texture
				var midtexx = (to[Y] - (bend_offset - position[Y])) / scale[Y];
				pmidtex = point2D_add(uv, point2D(texsize[X] + midtexx, to_noscale[Z])) // East middle
				nmidtex = point2D_add(uv, point2D(-midtexx, to_noscale[Z])) // West middle
				if (anglesign * partsign > 0)
				{
					pedgetex = point2D_add(uv, point2D(texsize[X] + midtexx, 0)) // East middle top
					pbacktex = point2D_add(uv, point2D(texsizefix[X], -midtexx)) // Top right middle
					nedgetex = point2D_add(uv, point2D(-midtexx, 0)) // West middle top
					nbacktex = point2D_add(uv, point2D(0, -midtexx)) // Top left middle
				}
				else
				{
					pedgetex = point2D_add(uv, point2D(texsize[X] + midtexx, texsizefix[Z])) // East middle bottom
					pbacktex = point2D_add(uv, point2D(texsize[X] + texsizefix[X], -midtexx)) // Bottom right middle
					nedgetex = point2D_add(uv, point2D(-midtexx, texsizefix[Z])) // West middle bottom
					nbacktex = point2D_add(uv, point2D(texsizefix[X], -midtexx)) // Bottom left middle
				}
			}
		
			// Invalid
			else
				return null
		
			break
		}
	
		case Y:
		{
			// Z+ or Z- half being bent
			if (bend_part = e_part.UPPER || bend_part = e_part.LOWER)
			{
				// Middle position
				sizefill = test(anglesign * partsign > 0, to[X], -from[X])
				pmid = point3D(0, to[Y], 0)
				nmid = point3D(pmid[X], from[Y], pmid[Z])
			
				// Normal
				if (roundbend)
				{
					backnormal[0] = vec3(dcos(0) * anglesign * partsign, 0, dsin(0) * partsign)
					backnormal[1] = vec3(dcos(angle * 0.75) * anglesign * partsign, 0, dsin(angle * 0.75) * partsign)
				}
			
				// Texture
				var midtexy = (to[Z] - (bend_offset - position[Z])) / scale[Z];
				pmidtex = point2D_add(uv, point2D(-from_noscale[X], midtexy)) // South middle
				nmidtex = point2D_add(uv, point2D(texsize[X] + texsize[Y] - from_noscale[X], midtexy)) // North middle
				if (anglesign * partsign > 0)
				{
					pedgetex = point2D_add(uv, point2D(texsizefix[X], midtexy)) // South right middle
					pbacktex = pedgetex // East left middle
					nedgetex = point2D_add(uv, point2D(texsize[X] + texsizefix[Y], midtexy)) // East right middle
					nbacktex = nedgetex // North left middle
				}
				else
				{
					pedgetex = point2D_add(uv, point2D(0, midtexy)) // South left middle
					pbacktex = pedgetex // West right middle
					nedgetex = point2D_add(uv, point2D(texsize[X] + texsize[Y] + texsizefix[X], midtexy)) // North right middle
					nbacktex = point2D_add(uv, point2D(-texsizefix[Y], midtexy)) // West left middle
				}
			}
		
			// X+ or X- half being bent
			else if (bend_part = e_part.RIGHT || bend_part = e_part.LEFT)
			{
				// Middle position
				sizefill = test(anglesign * partsign < 0, to[Z], -from[Z])
				pmid = point3D(0, to[Y], 0)
				nmid = point3D(pmid[X], from[Y], pmid[Z])
			
				// Normal
				if (roundbend)
				{
					backnormal[0] = vec3(dsin(0) * partsign, 0, -dcos(0) * anglesign * partsign)
					backnormal[1] = vec3(dsin(angle * 0.75) * partsign, 0, -dcos(angle * 0.75) * anglesign * partsign)
				}
			
				// Texture
				var midtexx = texsize[X] - (to[X] - (bend_offset - position[X])) / scale[X];
				pmidtex = point2D_add(uv, point2D(midtexx, to_noscale[Z])) // South middle
				nmidtex = point2D_add(uv, point2D(texsize[X] + texsize[Y] + texsize[X] - midtexx, to_noscale[Z])) // North middle
				if (anglesign * partsign > 0)
				{
					pedgetex = point2D_add(uv, point2D(midtexx, texsizefix[Z])) // South middle bottom
					pbacktex = point2D_add(uv, point2D(texsize[X] + midtexx, 0)) // Bottom middle bottom
					nedgetex = point2D_add(uv, point2D(texsize[X] + texsize[Y] + texsize[X] - midtexx, texsizefix[Z])) // North middle bottom
					nbacktex = point2D_add(uv, point2D(texsize[X] + midtexx, -texsizefix[Y])) // Bottom middle top
				}
				else
				{
					pedgetex = point2D_add(uv, point2D(midtexx, 0)) // South middle top
					pbacktex = pedgetex // Top middle bottom
					nedgetex = point2D_add(uv, point2D(texsize[X] + texsize[Y] + texsize[X] - midtexx, 0)) // North middle top
					nbacktex = point2D_add(uv, point2D(midtexx, -texsizefix[Y])) // Top middle top
				}
			}
		
			// Invalid
			else
				return null
			
			break
		}
	
		case Z:
		{
			// Y+ or Y- half being bent
			if (bend_part = e_part.FRONT || bend_part = e_part.BACK)
			{
				// Middle position
				sizefill = test(anglesign * partsign < 0, to[X], -from[X])
				pmid = point3D(0, 0, to[Z])
				nmid = point3D(pmid[X], pmid[Y], from[Z])
			
				// Normal
				if (roundbend)
				{
					backnormal[0] = vec3(-dcos(0) * anglesign * partsign, dsin(0) * partsign, 0)
					backnormal[1] = vec3(-dcos(angle * 0.75) * anglesign * partsign, dsin(angle * 0.75) * partsign, 0)
				}
			
				// Texture
				var midtexy = (to[Y] - (bend_offset - position[Y])) / scale[Y];
				pmidtex = point2D_add(uv, point2D(-from_noscale[Z], -texsize[Y] + midtexy)) // Top middle
				nmidtex = point2D_add(uv, point2D(texsize[X] - from_noscale[Z], -texsize[Y] + midtexy)) // Bottom middle
				if (anglesign * partsign > 0)
				{
					pedgetex = point2D_add(uv, point2D(texsize[X], -texsize[Y] + midtexy)) // Top right middle
					pbacktex = point2D_add(uv, point2D(texsize[X] + texsize[Y] - midtexy, 0)) // East middle top
					nedgetex = point2D_add(uv, point2D(texsize[X] + texsize[X], -texsize[Y] + midtexy)) // Bottom right middle
					nbacktex = point2D_add(uv, point2D(texsize[X] + texsize[Y] - midtexy, texsizefix[Z])) // East middle bottom
				}
				else
				{
					pedgetex = point2D_add(uv, point2D(0, -texsize[Y] + midtexy)) // Top left middle
					pbacktex = point2D_add(uv, point2D(-texsize[Y] + midtexy, 0)) // West middle top
					nedgetex = point2D_add(uv, point2D(texsize[X], -texsize[Y] + midtexy)) // Bottom left middle
					nbacktex = point2D_add(uv, point2D(-texsize[Y] + midtexy, texsizefix[Z])) // West middle bottom
				}
			}
		
			// X+ or X- half being bent
			else if (bend_part = e_part.RIGHT || bend_part = e_part.LEFT)
			{
				// Middle position
				sizefill = test(anglesign * partsign > 0, to[Y], -from[Y])
				pmid = point3D(0, 0, to[Z])
				nmid = point3D(pmid[X], pmid[Y], from[Z])
		
				// Normal
				if (roundbend)
				{
					backnormal[0] = vec3(dsin(0) * partsign, dcos(0) * anglesign * partsign, 0)
					backnormal[1] = vec3(dsin(angle * 0.75) * partsign, dcos(angle * 0.75) * anglesign * partsign, 0)
				}
			
				// Texture
				var midtexx = texsize[X] - (to[X] - (bend_offset - position[X])) / scale[X];
				pmidtex = point2D_add(uv, point2D(midtexx, -texsize[Y] - from_noscale[Y])) // Top middle
				nmidtex = point2D_add(uv, point2D(texsize[X] + midtexx, -texsize[Y] - from_noscale[Y])) // Bottom middle
				if (anglesign * partsign > 0)
				{
					pedgetex = point2D_add(uv, point2D(midtexx, 0)) // Top middle bottom
					pbacktex = pedgetex // South middle top
					nedgetex = point2D_add(uv, point2D(texsize[X] + midtexx, 0)) // Bottom middle bottom
					nbacktex = point2D_add(uv, point2D(midtexx, texsize[Z])) // South middle bottom
				}
				else
				{
					pedgetex = point2D_add(uv, point2D(midtexx, -texsizefix[Y])) // Top middle top
					pbacktex = point2D_add(uv, point2D(texsize[X] + texsize[Y] + texsize[X] - midtexx, 0)) // North middle top
					nedgetex = point2D_add(uv, point2D(texsize[X] + midtexx, -texsizefix[Y])) // Bottom middle top
					nbacktex = point2D_add(uv, point2D(texsize[X] + texsize[Y] + texsize[X] - midtexx, texsizefix[Z])) // North middle bottom
				}
			}
		
			// Invalid
			else
				return null
		
			break
		}
	}

	// Mirror (switch positive and negative) (TODO: this is UNFINISHED, only works well for arms/legs atm)
	if (texture_mirror)
	{
		var tmp = nbacktex;
		nbacktex = pbacktex
		pbacktex = tmp
	
		tmp = nedgetex
		nedgetex = pedgetex
		pedgetex = tmp
	
		tmp = nmidtex
		nmidtex = pmidtex
		pmidtex = tmp
	}

	// No flicker
	var pedgetex2, nedgetex2, pbacktex2, nbacktex2;
	pedgetex2 = point2D_add(pedgetex, point2D(1 / 512, 0))
	pbacktex2 = point2D_add(pbacktex, point2D(1 / 512, 0))
	nedgetex2 = point2D_add(nedgetex, point2D(1 / 512, 0))
	nbacktex2 = point2D_add(nbacktex, point2D(1 / 512, 0))

	// Transform texture to 0-1
	pmidtex = vec2_div(pmidtex, texture_size)
	pedgetex = vec2_div(pedgetex, texture_size)
	pedgetex2 = vec2_div(pedgetex2, texture_size)
	pbacktex = vec2_div(pbacktex, texture_size)
	pbacktex2 = vec2_div(pbacktex2, texture_size)
	nmidtex = vec2_div(nmidtex, texture_size)
	nedgetex = vec2_div(nedgetex, texture_size)
	nedgetex2 = vec2_div(nedgetex2, texture_size)
	nbacktex = vec2_div(nbacktex, texture_size)
	nbacktex2 = vec2_div(nbacktex2, texture_size)
	
	// Apply scale for anti-Z-fighting
	var pmidsca, nmidsca;
	pmidsca = point3D_mul(pmid, app.setting_bend_scale)
	nmidsca = point3D_mul(nmid, app.setting_bend_scale)

	var temptex = vec2(1 - 1 / 64, 0);
	vbuffer_start()

	var scacur, pcur, ncur, pcursca, ncursca;
	for (var a = 0; a <= 1; a += 1 / detail)
	{
		var len = 1;
		if (!roundbend && a < 1)
			len = sqrtlen
	
		var dista, distb, pnext, nnext;
		dista = min(1, dcos(angle * a) * len) * sizefill * anglesign * partsign
		distb = dsin(angle * a) * len * sizefill * partsign
	
		// Find the next vertex
		switch (bend_axis)
		{
			case X:
			{
				if (bend_part = e_part.UPPER || bend_part = e_part.LOWER)
					pnext = point3D(pmid[X], -dista, distb + pmid[Z])
				else // FRONT or BACK
					pnext = point3D(pmid[X], distb + pmid[Y], dista)
		
				nnext = point3D(nmid[X], pnext[Y], pnext[Z])
				break
			}
		
			case Y:
			{
				if (bend_part = e_part.UPPER || bend_part = e_part.LOWER)
					pnext = point3D(dista, pmid[Y], distb + pmid[Z])
				else // RIGHT or LEFT
					pnext = point3D(distb + pmid[X], pmid[Y], -dista)
			
				nnext = point3D(pnext[X], nmid[Y], pnext[Z])
				break
			}
		
			case Z:
			{
				if (bend_part = e_part.FRONT || bend_part = e_part.BACK)
					pnext = point3D(-dista, distb + pmid[Y], pmid[Z])
				else // RIGHT or LEFT
					pnext = point3D(distb + pmid[X], dista, pmid[Z])
			
				nnext = point3D(pnext[X], pnext[Y], nmid[Z])
				break
			}
		}
	
		// Apply scale for anti-Z-fighting
		var scanext, pnextsca, nnextsca;
		scanext = 1 + (app.setting_bend_scale - 1) * a
		pnextsca = point3D_mul(pnext, scanext)
		nnextsca = point3D_mul(nnext, scanext)
		
		if (a > 0)
		{
			if (anglesign * invertsign > 0)
			{
				if (!is3d)
				{
					vbuffer_add_triangle(pcursca, pmidsca, pnextsca, pedgetex, pmidtex, pedgetex2, null, color_blend, color_alpha) // +
					vbuffer_add_triangle(nmidsca, ncursca, nnextsca, nmidtex, nedgetex, nedgetex2, null, color_blend, color_alpha) // -
				}
				vbuffer_add_triangle(ncursca, pcursca, nnextsca, nbacktex, pbacktex, nbacktex2, backnormal[a > 0.5], color_blend, color_alpha) // Back 1
				vbuffer_add_triangle(nnextsca, pcursca, pnextsca, nbacktex2, pbacktex, pbacktex2, backnormal[a > 0.5], color_blend, color_alpha) // Back 2
			}
			else // Invert
			{
				if (!is3d)
				{
					vbuffer_add_triangle(pmidsca, pcursca, pnextsca, pmidtex, pedgetex, pedgetex2, null, color_blend, color_alpha) // +
					vbuffer_add_triangle(ncursca, nmidsca, nnextsca, nedgetex, nmidtex, nedgetex2, null, color_blend, color_alpha) // -
				}
				vbuffer_add_triangle(pcursca, ncursca, nnextsca, pbacktex, nbacktex, nbacktex2, backnormal[a > 0.5], color_blend, color_alpha) // Back 1
				vbuffer_add_triangle(pcursca, nnextsca, pnextsca, pbacktex, nbacktex2, pbacktex2, backnormal[a > 0.5], color_blend, color_alpha) // Back 2
			}
			
			// 3D planes
			/*if (is3d && alphaarr != null)
			{
				if (true)
				{
					var ay, px;
					ay = floor(pmidtex[Y])
					px = from[X]
					if (ay >= 0 && ay < texsize[Z])
					{
						for (var ax = 0; ax < texsize[X]; ax++)
						{
							var pxs = scale[X];
						
							if (alphaarr[@ ax, ay] < 1)
							{
								px += pxs
								continue
							}
						
							var ptex, psize, t1, t2, t3;
							ptex = point2D(uv[X] + ax, ay)
							psize = 1 - 1 / 256
							t1 = ptex
							t2 = point2D(ptex[X] + psize, ptex[Y])
							t3 = point2D(ptex[X], ptex[Y] + psize)
						
							// Conver coordinates to 0-1
							t1 = vec2_div(t1, texture_size)
							t2 = vec2_div(t2, texture_size)
							t3 = vec2_div(t3, texture_size)
		
							var p1, p2, p3, p4;
						
							// East
							if (ax = texsize[X] - 1 || alphaarr[@ ax + 1, ay] < 1)
							{
								p1 = point3D((px + pxs) * scacur, pcursca[Y], pcursca[Z])
								p2 = point3D((px + pxs) * scanext, pnextsca[Y], pnextsca[Z])
								p3 = point3D(px + pxs, pmidsca[Y], pmidsca[Z])
								vbuffer_add_triangle(p1, p2, p3, t1, t2, t3, null, color_blend, color_alpha)
							}
						
							// West
							if (ax = 0 || alphaarr[@ ax - 1, ay] < 1)
							{
								p1 = point3D(px * scanext, nnextsca[Y], nnextsca[Z])
								p2 = point3D(px * scacur, ncursca[Y], ncursca[Z])
								p3 = point3D(px, nmidsca[Y], nmidsca[Z])
								vbuffer_add_triangle(p1, p2, p3, t1, t2, t3, null, color_blend, color_alpha)
							}
						
							px += pxs
						}
					}
				}
				
				if (a = 1 && is3d)
				{
					// Top face
					vbuffer_add_triangle(nnextsca, nmidsca, pmidsca, nbacktex, nmidtex, pmidtex, null, color_blend, color_alpha)
					vbuffer_add_triangle(pnextsca, nnextsca, pmidsca, pbacktex, nbacktex, pmidtex, null, color_blend, color_alpha)
				}
			}*/
		}
		
		pcur = pnext
		ncur = nnext
		scacur = scanext
		pcursca = pnextsca
		ncursca = nnextsca
	}

	return vbuffer_done()
	
	vertex_brightness = 0
}