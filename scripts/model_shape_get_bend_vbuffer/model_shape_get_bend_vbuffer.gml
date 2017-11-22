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

	var invertsign, size, sizefix, sizefill, pmid, nmid;
	var sqrtlen, backnormal;
	var pmidtex, nmidtex, pedgetex, nedgetex, nbacktex, pbacktex;
	invertsign = negate(invert)
	size = point3D_sub(to_noscale, from_noscale)
	backnormal = array(null, null)
	sqrtlen = sqrt(2 - abs(90 - angle) / 90)
	
	// Artifact fix with CPU rendering
	sizefix = point3D_sub(size, vec3(1 / 64))

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
					pmidtex = point2D_add(uv, point2D(size[X] + to_noscale[Y], midtexy)) // East middle
					nmidtex = point2D_add(uv, point2D(-to_noscale[Y], midtexy)) // West middle
					if (anglesign * partsign > 0)
					{
						pedgetex = point2D_add(uv, point2D(size[X] + sizefix[Y], midtexy)) // East right middle
						pbacktex = pedgetex // Back left middle
						nedgetex = point2D_add(uv, point2D(-sizefix[Y], midtexy)) // West left middle
						nbacktex = point2D_add(pbacktex, point2D(sizefix[X], 0)) // Back right middle
					}
					else
					{
						pedgetex = point2D_add(uv, point2D(size[X], midtexy)) // East left middle
						pbacktex = pedgetex // Front right middle
						nedgetex = point2D_add(uv, point2D(0, midtexy)) // West right middle
						nbacktex = nedgetex // Front left middle
					}
				}
				else // 3D plane
				{
					pmidtex = point2D_add(uv, point2D(size[X], midtexy))
					nmidtex = point2D_add(uv, point2D(0, midtexy))
					pedgetex = point2D_copy(pmidtex)
					pbacktex = point2D_copy(pmidtex)
					nedgetex = point2D_copy(nmidtex)
					nbacktex = point2D_copy(nmidtex)
				}
			}
		
			// Y+ or Y- half being bent (block only)
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
				pmidtex = point2D_add(uv, point2D(size[X] + midtexx, to_noscale[Z])) // East middle
				nmidtex = point2D_add(uv, point2D(-midtexx, to_noscale[Z])) // West middle
				if (anglesign * partsign > 0)
				{
					pedgetex = point2D_add(uv, point2D(size[X] + midtexx, 0)) // East middle top
					pbacktex = point2D_add(uv, point2D(sizefix[X], -midtexx)) // Top right middle
					nedgetex = point2D_add(uv, point2D(-midtexx, 0)) // West middle top
					nbacktex = point2D_add(uv, point2D(0, -midtexx)) // Top left middle
				}
				else
				{
					pedgetex = point2D_add(uv, point2D(size[X] + midtexx, sizefix[Z])) // East middle bottom
					pbacktex = point2D_add(uv, point2D(size[X] + sizefix[X], -midtexx)) // Bottom right middle
					nedgetex = point2D_add(uv, point2D(-midtexx, sizefix[Z])) // West middle bottom
					nbacktex = point2D_add(uv, point2D(sizefix[X], -midtexx)) // Bottom left middle
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
				if (type = "block")
				{
					pmidtex = point2D_add(uv, point2D(-from_noscale[X], midtexy)) // South middle
					nmidtex = point2D_add(uv, point2D(size[X] + size[Y] - from_noscale[X], midtexy)) // North middle
					if (anglesign * partsign > 0)
					{
						pedgetex = point2D_add(uv, point2D(sizefix[X], midtexy)) // South right middle
						pbacktex = pedgetex // East left middle
						nedgetex = point2D_add(uv, point2D(size[X] + sizefix[Y], midtexy)) // East right middle
						nbacktex = nedgetex // North left middle
					}
					else
					{
						pedgetex = point2D_add(uv, point2D(0, midtexy)) // South left middle
						pbacktex = pedgetex // West right middle
						nedgetex = point2D_add(uv, point2D(size[X] + size[Y] + sizefix[X], midtexy)) // North right middle
						nbacktex = point2D_add(uv, point2D(-sizefix[Y], midtexy)) // West left middle
					}
				}
				else // 3D plane
				{
					pmidtex = point2D_add(uv, point2D(-from_noscale[X], midtexy))
					if (anglesign * partsign > 0)
						pedgetex = point2D_add(uv, point2D(size[X] - 1 / 256, midtexy))
					else
						pedgetex = point2D_add(uv, point2D(1 / 256, midtexy))
					nmidtex = point2D_copy(pmidtex)
					pbacktex = point2D_copy(pedgetex)
					nedgetex = point2D_copy(pedgetex)
					nbacktex = point2D_copy(pedgetex)
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
				var midtexx = size[X] - (to[X] - (bend_offset - position[X])) / scale[X];
				if (type = "block")
				{
					pmidtex = point2D_add(uv, point2D(midtexx, to_noscale[Z])) // South middle
					nmidtex = point2D_add(uv, point2D(size[X] + size[Y] + size[X] - midtexx, to_noscale[Z])) // North middle
					if (anglesign * partsign > 0)
					{
						pedgetex = point2D_add(uv, point2D(midtexx, sizefix[Z])) // South middle bottom
						pbacktex = point2D_add(uv, point2D(size[X] + midtexx, 0)) // Bottom middle bottom
						nedgetex = point2D_add(uv, point2D(size[X] + size[Y] + size[X] - midtexx, sizefix[Z])) // North middle bottom
						nbacktex = point2D_add(uv, point2D(size[X] + midtexx, -sizefix[Y])) // Bottom middle top
					}
					else
					{
						pedgetex = point2D_add(uv, point2D(midtexx, 0)) // South middle top
						pbacktex = pedgetex // Top middle bottom
						nedgetex = point2D_add(uv, point2D(size[X] + size[Y] + size[X] - midtexx, 0)) // North middle top
						nbacktex = point2D_add(uv, point2D(midtexx, -sizefix[Y])) // Top middle top
					}
				}
				else // 3D plane
				{
					pmidtex = point2D_add(uv, point2D(midtexx, to_noscale[Z]))
					if (anglesign * partsign > 0)
						pedgetex = point2D_add(uv, point2D(midtexx, size[Z] - 1 / 256))
					else
						pedgetex = point2D_add(uv, point2D(midtexx, 0))
					nmidtex = point2D_copy(pmidtex)
					pbacktex = point2D_copy(pedgetex)
					nedgetex = point2D_copy(pedgetex)
					nbacktex = point2D_copy(pedgetex)
				}
			}
		
			// Invalid
			else
				return null
			
			break
		}
	
		case Z:
		{
			// Y+ or Y- half being bent (block only)
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
				pmidtex = point2D_add(uv, point2D(-from_noscale[Z], -size[Y] + midtexy)) // Top middle
				nmidtex = point2D_add(uv, point2D(size[X] - from_noscale[Z], -size[Y] + midtexy)) // Bottom middle
				if (anglesign * partsign > 0)
				{
					pedgetex = point2D_add(uv, point2D(size[X], -size[Y] + midtexy)) // Top right middle
					pbacktex = point2D_add(uv, point2D(size[X] + size[Y] - midtexy, 0)) // East middle top
					nedgetex = point2D_add(uv, point2D(size[X] + size[X], -size[Y] + midtexy)) // Bottom right middle
					nbacktex = point2D_add(uv, point2D(size[X] + size[Y] - midtexy, sizefix[Z])) // East middle bottom
				}
				else
				{
					pedgetex = point2D_add(uv, point2D(0, -size[Y] + midtexy)) // Top left middle
					pbacktex = point2D_add(uv, point2D(-size[Y] + midtexy, 0)) // West middle top
					nedgetex = point2D_add(uv, point2D(size[X], -size[Y] + midtexy)) // Bottom left middle
					nbacktex = point2D_add(uv, point2D(-size[Y] + midtexy, sizefix[Z])) // West middle bottom
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
				var midtexx = size[X] - (to[X] - (bend_offset - position[X])) / scale[X];
				if (type = "block")
				{
					pmidtex = point2D_add(uv, point2D(midtexx, -size[Y] - from_noscale[Y])) // Top middle
					nmidtex = point2D_add(uv, point2D(size[X] + midtexx, -size[Y] - from_noscale[Y])) // Bottom middle
					if (anglesign * partsign > 0)
					{
						pedgetex = point2D_add(uv, point2D(midtexx, 0)) // Top middle bottom
						pbacktex = pedgetex // South middle top
						nedgetex = point2D_add(uv, point2D(size[X] + midtexx, 0)) // Bottom middle bottom
						nbacktex = point2D_add(uv, point2D(midtexx, size[Z])) // South middle bottom
					}
					else
					{
						pedgetex = point2D_add(uv, point2D(midtexx, -sizefix[Y])) // Top middle top
						pbacktex = point2D_add(uv, point2D(size[X] + size[Y] + size[X] - midtexx, 0)) // North middle top
						nedgetex = point2D_add(uv, point2D(size[X] + midtexx, -sizefix[Y])) // Bottom middle top
						nbacktex = point2D_add(uv, point2D(size[X] + size[Y] + size[X] - midtexx, sizefix[Z])) // North middle bottom
					}
				}
				else // 3D plane
				{
					pmidtex = point2D_add(uv, point2D(midtexx, 0))
					nmidtex = point2D_add(uv, point2D(midtexx, size[Z]))
					pedgetex = point2D_copy(pmidtex)
					pbacktex = point2D_copy(pmidtex)
					nedgetex = point2D_copy(nmidtex)
					nbacktex = point2D_copy(nmidtex)
				}
			}
		
			// Invalid
			else
				return null
		
			break
		}
	}

	// Mirror
	if (texture_mirror)
	{
		if (type = "block") // Blocks switch positive and negative sides (TODO: this is UNFINISHED, only works well for arms/legs atm)
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
		else // Planes
		{
			nbacktex[X] = (size[X] - (nbacktex[X] - uv[X])) + uv[X]
			pbacktex[X] = (size[X] - (pbacktex[X] - uv[X])) + uv[X]
			nedgetex[X] = (size[X] - (nedgetex[X] - uv[X])) + uv[X]
			pedgetex[X] = (size[X] - (pedgetex[X] - uv[X])) + uv[X]
			nmidtex[X] = (size[X] - (nmidtex[X] - uv[X])) + uv[X]
			pmidtex[X] = (size[X] - (pmidtex[X] - uv[X])) + uv[X]
		}
	}

	// No flicker
	var pedgetex2, nedgetex2, pbacktex2, nbacktex2;
	pedgetex2 = point2D_add(pedgetex, point2D(1 / 512, 1 / 512))
	pbacktex2 = point2D_add(pbacktex, point2D(1 / 512, 1 / 512))
	nedgetex2 = point2D_add(nedgetex, point2D(1 / 512, 1 / 512))
	nbacktex2 = point2D_add(nbacktex, point2D(1 / 512, 1 / 512))

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
			if (!is3d || bend_axis = Y)
			{
				vbuffer_add_triangle(pmidsca, pcursca, pnextsca, pmidtex, pedgetex, pedgetex2, null, color_blend, color_alpha, (anglesign * invertsign > 0)) // +
				vbuffer_add_triangle(ncursca, nmidsca, nnextsca, nedgetex, nmidtex, nedgetex2, null, color_blend, color_alpha, (anglesign * invertsign > 0)) // -
			}
			vbuffer_add_triangle(pcursca, ncursca, nnextsca, pbacktex, nbacktex, nbacktex2, backnormal[a > 0.5], color_blend, color_alpha, (anglesign * invertsign > 0)) // Back 1
			vbuffer_add_triangle(pcursca, nnextsca, pnextsca, pbacktex, nbacktex2, pbacktex2, backnormal[a > 0.5], color_blend, color_alpha, (anglesign * invertsign > 0)) // Back 2
			
			// 3D planes
			if (is3d && alphaarr != null)
			{
				switch (bend_axis)
				{
					case X:
					{
						if (bend_part = e_part.UPPER || bend_part = e_part.LOWER)
						{
							// Array Y location
							var ay = floor((to[Z] - (bend_offset - position[Z])) / scale[Z]);
							if (ay < 0 && ay >= size[Z])
								break
							
							var px = from[X];
							for (var xx = 0; xx < size[X]; xx++)
							{
								// Array X location
								var ax = xx;
								if (texture_mirror)
									ax = ceil(size[X]) - 1 - xx
								
								// Pixel X size
								var pxs;
								if (ax = ceil(size[X]) - 1 && frac(size[X]) > 0)
									pxs = frac(size[X])
								else
									pxs = 1
								pxs *= scale[X]
								
								// Pixel is transparent, continue
								if (alphaarr[@ ax, ay] < 1)
								{
									px += pxs
									continue
								}
								
								// Calculate which faces to add, continue if none are visible
								var eface, wface;
								eface = (ax = ceil(size[X]) - 1 || alphaarr[@ ax + 1, ay] < 1)
								wface = (ax = 0 || alphaarr[@ ax - 1, ay] < 1)
								
								if (texture_mirror)
								{
									var tmp = eface;
									eface = wface
									wface = tmp
								}
								
								if (!eface && !wface)
								{
									px += pxs
									continue
								}
								
								// Set texture
								var ptex, psize, t1, t2, t3;
								ptex = point2D(uv[X] + ax, uv[Y] + ay)
								psize = 1// - 1 / 256
								t1 = ptex
								t2 = point2D(ptex[X] + psize, ptex[Y])
								t3 = point2D(ptex[X], ptex[Y] + psize)
						
								// Conver coordinates to 0-1
								t1 = vec2_div(t1, texture_size)
								t2 = vec2_div(t2, texture_size)
								t3 = vec2_div(t3, texture_size)
		
								var p1, p2, p3, p4;
						
								// East
								if (eface)
								{
									p1 = point3D(px + pxs, pmidsca[Y], pmidsca[Z])
									p2 = point3D((px + pxs) * scacur, pcursca[Y], pcursca[Z])
									p3 = point3D((px + pxs) * scanext, pnextsca[Y], pnextsca[Z])
									vbuffer_add_triangle(p1, p2, p3, t1, t2, t3, null, color_blend, color_alpha, (anglesign * invertsign > 0))
								}
						
								// West
								if (wface)
								{
									p1 = point3D(px * scacur, ncursca[Y], ncursca[Z])
									p2 = point3D(px, nmidsca[Y], nmidsca[Z])
									p3 = point3D(px * scanext, nnextsca[Y], nnextsca[Z])
									vbuffer_add_triangle(p1, p2, p3, t1, t2, t3, null, color_blend, color_alpha, (anglesign * invertsign > 0))
								}
						
								px += pxs
							}
						}
						
						break
					}
					
					case Y:
					{
						if (bend_part = e_part.UPPER || bend_part = e_part.LOWER)
						{
							// Texture Y location
							var ay = floor((to[Z] - (bend_offset - position[Z])) / scale[Z]);
							if (ay < 0 && ay >= size[Z])
								break
							
							// Find out texture start and end
							var px, xxstart, xxend;
							if (anglesign * partsign > 0) // Middle to end
							{
								px = 0
								xxstart = floor(-from_noscale[X])
								xxend = size[X]
							}
							else // Start to middle
							{
								px = from[X]
								xxstart = 0
								xxend = floor(-from_noscale[X])
							}
								
							for (var xx = xxstart; xx < xxend; xx++)
							{
								// Texture X location
								var ax = xx;
								if (texture_mirror)
									ax = ceil(size[X]) - 1 - xx
								
								// Pixel X size
								var pxs = 1;
								if (!texture_mirror)
								{
									if (xx = floor(-from_noscale[X])) // Middle
										pxs = 1 - frac(-from_noscale[X])
									else if (xx = floor(-from_noscale[X]) - 1 && frac(-from_noscale[X]) > 0) // Next is middle
										pxs = frac(-from_noscale[X])
								}
								else
								{
									if (xx = floor(-from_noscale[X]) && frac(to_noscale[X]) > 0) // Middle
										pxs = frac(to_noscale[X])
									else if (xx = floor(-from_noscale[X]) - 1) // Next is middle
										pxs = 1 - frac(-from_noscale[X])
								}
								if (ax = ceil(size[X]) - 1 && frac(size[X]) > 0) // End
									pxs = frac(size[X])
								pxs *= scale[X]
						
								// Pixel is transparent, continue
								if (alphaarr[@ ax, ay] < 1)
								{
									px += pxs
									continue
								}
								
								// Calculate which faces to add, continue if none are visible
								var eface, wface;
								eface = (ax = ceil(size[X]) - 1 || alphaarr[@ ax + 1, ay] < 1)
								wface = (ax = 0 || alphaarr[@ ax - 1, ay] < 1)
								
								if (texture_mirror)
								{
									var tmp = eface;
									eface = wface
									wface = tmp
								}
								
								if (!eface && !wface)
								{
									px += pxs
									continue
								}
								
								// Set texture
								var ptex, psize, t1, t2, t3, t4;
								ptex = point2D(uv[X] + ax, uv[Y] + ay)
								psize = 1// - 1 / 256
								t1 = ptex
								t2 = point2D(ptex[X] + psize, ptex[Y])
								t3 = point2D(ptex[X] + psize, ptex[Y] + psize)
								t4 = point2D(ptex[X], ptex[Y] + psize)
						
								// Convert coordinates to 0-1
								t1 = vec2_div(t1, texture_size)
								t2 = vec2_div(t2, texture_size)
								t3 = vec2_div(t3, texture_size)
								t4 = vec2_div(t4, texture_size)
		
								var perccur, percnext, p1, p2, p3, p4;
								
								// Percentage of shape complete
								if (anglesign * partsign > 0)
								{
									perccur = (px / to[X])
									percnext = ((px + pxs) / to[X])
								}
								else
								{
									perccur = -(px / -from[X])
									percnext = -((px + pxs) / -from[X])
								}
								
								// East face
								if (eface)
								{
									p1 = point3D(pmidsca[X] + percnext * pcursca[X], pmidsca[Y], pmidsca[Z] + percnext * pcursca[Z])
									p2 = point3D(pmidsca[X] + percnext * pcursca[X], nmidsca[Y], pmidsca[Z] + percnext * pcursca[Z])
									p3 = point3D(pmidsca[X] + percnext * pnextsca[X], nmidsca[Y], pmidsca[Z] + percnext * pnextsca[Z])
									p4 = point3D(pmidsca[X] + percnext * pnextsca[X], pmidsca[Y], pmidsca[Z] + percnext * pnextsca[Z])
									vbuffer_add_triangle(p1, p2, p3, t1, t2, t3, null, color_blend, color_alpha, (partsign * invertsign > 0))
									vbuffer_add_triangle(p3, p4, p1, t3, t4, t1, null, color_blend, color_alpha, (partsign * invertsign > 0))
								}
						
								// West face
								if (wface)
								{
									p1 = point3D(pmidsca[X] + perccur * pnextsca[X], pmidsca[Y], pmidsca[Z] + perccur * pnextsca[Z])
									p2 = point3D(pmidsca[X] + perccur * pnextsca[X], nmidsca[Y], pmidsca[Z] + perccur * pnextsca[Z])
									p3 = point3D(pmidsca[X] + perccur * pcursca[X], nmidsca[Y], pmidsca[Z] + perccur * pcursca[Z])
									p4 = point3D(pmidsca[X] + perccur * pcursca[X], pmidsca[Y], pmidsca[Z] + perccur * pcursca[Z])
									vbuffer_add_triangle(p1, p2, p3, t1, t2, t3, null, color_blend, color_alpha, (partsign * invertsign > 0))
									vbuffer_add_triangle(p3, p4, p1, t3, t4, t1, null, color_blend, color_alpha, (partsign * invertsign > 0))
								}
						
								px += pxs
							}
						}
						else if (bend_part = e_part.RIGHT || bend_part = e_part.LEFT)
						{
							// Get texture middle X
							var ax = floor(size[X] - (to[X] - (bend_offset - position[X])) / scale[X]);
							if (texture_mirror)
								ax = floor((to[X] - (bend_offset - position[X])) / scale[X])
								
							if (ax < 0 && ax >= size[X])
								break
							
							// Find out texture start and end
							var pz, aystart, ayend;
							if (anglesign * partsign > 0) // Bottom to middle
							{
								pz = from[Z]
								aystart = ceil(size[Z]) - 1
								ayend = floor(to_noscale[Z])
							}
							else // Middle to top
							{
								pz = 0
								aystart = floor(to_noscale[Z]) - 1
								ayend = 0
							}
							
							for (var ay = aystart; ay >= ayend; ay--)
							{
								// Get size of pixel
								var pzs = 1;
								if (anglesign * partsign > 0) // Bottom to middle
								{
									if (ay = aystart && frac(size[Z]) > 0)
										pzs = frac(size[Z])
									if (ay - 1 < ayend)
										pzs = 1 - frac(to_noscale[Z])
								}
								else // Middle to top
								{
									if (ay = aystart && frac(to_noscale[Z]) > 0)
										pzs = frac(to_noscale[Z])
								}
								pzs *= scale[Z]
								
								// Pixel is transparent, continue
								if (alphaarr[@ ax, ay] < 1)
								{
									pz += pzs
									continue
								}
								
								// Calculate which faces to add, continue if none are visible
								var aface, bface;
								aface = (ay = 0 || alphaarr[@ ax, ay - 1] < 1)
								bface = (ay = ceil(size[Z]) - 1 || alphaarr[@ ax, ay + 1] < 1)
								
								if (!aface && !bface)
								{
									pz += pzs
									continue
								}
								
								// Set texture
								var ptex, psize, t1, t2, t3, t4;
								ptex = point2D(uv[X] + ax, uv[Y] + ay)
								psize = 1// - 1 / 256
								t1 = ptex
								t2 = point2D(ptex[X] + psize, ptex[Y])
								t3 = point2D(ptex[X] + psize, ptex[Y] + psize)
								t4 = point2D(ptex[X], ptex[Y] + psize)
						
								// Convert coordinates to 0-1
								t1 = vec2_div(t1, texture_size)
								t2 = vec2_div(t2, texture_size)
								t3 = vec2_div(t3, texture_size)
								t4 = vec2_div(t4, texture_size)
		
								var perccur, percnext, p1, p2, p3, p4;
								
								// Percentage of shape complete
								if (anglesign * partsign > 0) // Bottom to middle
								{
									perccur = -(pz / -from[Z])
									percnext = -((pz + pzs) / -from[Z])
								}
								else // Middle to top
								{
									perccur = (pz / to[Z])
									percnext = ((pz + pzs) / to[Z])
								}
								
								// Above triangle
								if (aface)
								{
									p1 = point3D(pmidsca[X] + percnext * pcursca[X], pmidsca[Y], pmidsca[Z] + percnext * pcursca[Z])
									p2 = point3D(pmidsca[X] + percnext * pcursca[X], nmidsca[Y], pmidsca[Z] + percnext * pcursca[Z])
									p3 = point3D(pmidsca[X] + percnext * pnextsca[X], nmidsca[Y], pmidsca[Z] + percnext * pnextsca[Z])
									p4 = point3D(pmidsca[X] + percnext * pnextsca[X], pmidsca[Y], pmidsca[Z] + percnext * pnextsca[Z])
									vbuffer_add_triangle(p2, p1, p3, t2, t1, t3, null, color_blend, color_alpha, (partsign * invertsign > 0))
									vbuffer_add_triangle(p4, p3, p1, t4, t3, t1, null, color_blend, color_alpha, (partsign * invertsign > 0))
								}
						
								// Below triangle
								if (bface)
								{
									p1 = point3D(pmidsca[X] + perccur * pnextsca[X], pmidsca[Y], pmidsca[Z] + perccur * pnextsca[Z])
									p2 = point3D(pmidsca[X] + perccur * pnextsca[X], nmidsca[Y], pmidsca[Z] + perccur * pnextsca[Z])
									p3 = point3D(pmidsca[X] + perccur * pcursca[X], nmidsca[Y], pmidsca[Z] + perccur * pcursca[Z])
									p4 = point3D(pmidsca[X] + perccur * pcursca[X], pmidsca[Y], pmidsca[Z] + perccur * pcursca[Z])
									vbuffer_add_triangle(p2, p1, p3, t2, t1, t3, null, color_blend, color_alpha, (partsign * invertsign > 0))
									vbuffer_add_triangle(p4, p3, p1, t4, t3, t1, null, color_blend, color_alpha, (partsign * invertsign > 0))
								}
						
								pz += pzs
							}
						}
						
						break
					}
					
					case Z:
					{
						if (bend_part = e_part.RIGHT || bend_part = e_part.LEFT)
						{
							// Array X location
							var ax = floor(size[X] - (to[X] - (bend_offset - position[X])) / scale[X]);
							if (texture_mirror)
								ax = floor((to[X] - (bend_offset - position[X])) / scale[X])
							
							if (ax < 0 && ax >= size[X])
								break
								
							var pz = to[Z];
							for (var ay = 0; ay < size[Z]; ay++)
							{
								// Pixel Z size
								var pzs = scale[Z];
								if (ay = ceil(size[Z]) - 1 && frac(size[Z]) > 0)
									pzs = frac(size[Z]) * scale[Z]
						
								// Pixel is transparent, continue
								if (alphaarr[@ ax, ay] < 1)
								{
									pz -= pzs
									continue
								}
								
								// Calculate which faces to add, continue if none are visible
								var bface, aface;
								bface = (ay = ceil(size[Z]) - 1 || alphaarr[@ ax, ay + 1] < 1)
								aface = (ay = 0 || alphaarr[@ ax, ay - 1] < 1)
								
								if (!bface && !aface)
								{
									pz -= pzs
									continue
								}
						
								// Set texture
								var ptex, psize, t1, t2, t3;
								ptex = point2D(uv[X] + ax, uv[Y] + ay)
								psize = 1// - 1 / 256
								t1 = ptex
								t2 = point2D(ptex[X] + psize, ptex[Y])
								t3 = point2D(ptex[X] + psize, ptex[Y] + psize)
						
								// Convert coordinates to 0-1
								t1 = vec2_div(t1, texture_size)
								t2 = vec2_div(t2, texture_size)
								t3 = vec2_div(t3, texture_size)
		
								var p1, p2, p3, p4;
						
								// Below triangle
								if (bface)
								{
									p1 = point3D(pcursca[X], pcursca[Y], (pz - pzs) * scacur)
									p2 = point3D(pmidsca[X], pmidsca[Y], pz - pzs)
									p3 = point3D(pnextsca[X], pnextsca[Y], (pz - pzs) * scanext)
									vbuffer_add_triangle(p1, p2, p3, t1, t2, t3, null, color_blend, color_alpha, (anglesign * invertsign > 0))
								}
						
								// Above triangle
								if (aface)
								{
									p1 = point3D(nmidsca[X], nmidsca[Y], pz)
									p2 = point3D(ncursca[X], ncursca[Y], pz * scacur)
									p3 = point3D(nnextsca[X], nnextsca[Y], pz * scanext)
									vbuffer_add_triangle(p1, p2, p3, t1, t2, t3, null, color_blend, color_alpha, (anglesign * invertsign > 0))
								}
						
								pz -= pzs
							}
						}
						
						break
					}
				}
			}
		}
		
		pcur = pnext
		ncur = nnext
		scacur = scanext
		pcursca = pnextsca
		ncursca = nnextsca
	}
	
	vertex_brightness = 0

	return vbuffer_done()
}