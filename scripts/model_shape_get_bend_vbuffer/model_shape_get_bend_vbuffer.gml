/// model_shape_get_bend_vbuffer(shape, angle, round)
/// @arg shape
/// @arg angle
/// @arg round
/// @desc Returns an "in-between" mesh that connects the two halves of the given shape.

var shape, angle, roundbend;
shape = argument0
angle = tl_value_clamp(e_value.BEND_ANGLE, argument1)
roundbend = argument2

with (shape)
{
	if (type != "block" || bend_mode != e_shape_bend.BEND)
		return null

	var anglesign, partsign, detail;

	// Invert angle
	if (bend_invert)
		angle = -angle

	// Limit angle
	if (bend_direction = e_bend.FORWARD)
		angle = min(0, -angle)
	else if (bend_direction = e_bend.BACKWARD)
		angle = max(0, angle)
	
	anglesign = sign(angle)
	angle = abs(angle)
	detail = test(roundbend, app.setting_bend_detail, 2)

	if (bend_part = e_part.LEFT || bend_part = e_part.BACK || bend_part = e_part.LOWER)
		partsign = -1
	else
		partsign = 1

	var invertsign, texsize, sizefill, pmidp, nmidp, pcurp, ncurp;
	var sqrtlen, backnormal;
	var pmidtex, nmidtex, pedgetex, nedgetex, nbacktex, pbacktex;
	
	invertsign = negate(invert)
	texsize = point3D_sub(to_noscale, from_noscale)
	backnormal = array(null, null)
	sqrtlen = sqrt(2 - abs(90 - angle) / 90)

	switch (bend_axis)
	{
		case X:
		{
			// Z+ or Z- half being bent
			if (bend_part = e_part.UPPER || bend_part = e_part.LOWER)
			{
				// Middle position
				sizefill = test(anglesign * partsign < 0, to[Y], -from[Y])
				pmidp = point3D(to[X], 0, bend_offset - position[Z])
				nmidp = point3D(from[X], pmidp[Y], pmidp[Z])
		
				// Normal
				if (roundbend)
				{
					backnormal[0] = vec3(0, dcos(0) * anglesign * (-partsign), dsin(0) * partsign)
					backnormal[1] = vec3(0, dcos(angle * 0.75) * anglesign * (-partsign), dsin(angle * 0.75) * partsign)
				}
			
				// Texture
				var midtexy = (to[Z] - (bend_offset - position[Z])) / scale[Z] ;
				pmidtex = point2D_add(uv, point2D(texsize[X] + to_noscale[Y], midtexy)) // East middle
				nmidtex = point2D_add(uv, point2D(-to_noscale[Y], midtexy)) // West middle
				if (anglesign * partsign > 0)
				{
					pedgetex = point2D_add(uv, point2D(texsize[X] + texsize[Y], midtexy)) // East right middle
					pbacktex = pedgetex // Back left middle
					nedgetex = point2D_add(uv, point2D(-texsize[Y], midtexy)) // West left middle
					nbacktex = point2D_add(pbacktex, point2D(texsize[X], 0)) // Back right middle
				}
				else
				{
					pedgetex = point2D_add(uv, point2D(texsize[X], midtexy)) // East left middle
					pbacktex = pedgetex // Front right middle
					nedgetex = point2D_add(uv, point2D(0, midtexy)) // West right middle
					nbacktex = nedgetex // Front left middle
				}
			}
		
			// Y+ or Y- half being bent
			else if (bend_part = e_part.FRONT || bend_part = e_part.BACK)
			{
				// Middle position
				sizefill = test(anglesign * partsign > 0, to[Z], -from[Z])
				pmidp = point3D(to[X], bend_offset - position[Y], 0)
				nmidp = point3D(from[X], pmidp[Y], pmidp[Z])
			
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
					pbacktex = point2D_add(uv, point2D(texsize[X], -midtexx)) // Top right middle
					nedgetex = point2D_add(uv, point2D(-midtexx, 0)) // West middle top
					nbacktex = point2D_add(uv, point2D(0, -midtexx)) // Top left middle
				}
				else
				{
					pedgetex = point2D_add(uv, point2D(texsize[X] + midtexx, texsize[Z])) // East middle bottom
					pbacktex = point2D_add(uv, point2D(texsize[X] + texsize[X], -midtexx)) // Bottom right middle
					nedgetex = point2D_add(uv, point2D(-midtexx, texsize[Z])) // West middle bottom
					nbacktex = point2D_add(uv, point2D(texsize[X], -midtexx)) // Bottom left middle
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
				pmidp = point3D(0, to[Y], bend_offset - position[Z])
				nmidp = point3D(pmidp[X], from[Y], pmidp[Z])
			
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
					pedgetex = point2D_add(uv, point2D(texsize[X], midtexy)) // South right middle
					pbacktex = pedgetex // East left middle
					nedgetex = point2D_add(uv, point2D(texsize[X] + texsize[Y], midtexy)) // East right middle
					nbacktex = nedgetex // North left middle
				}
				else
				{
					pedgetex = point2D_add(uv, point2D(0, midtexy)) // South left middle
					pbacktex = pedgetex // West right middle
					nedgetex = point2D_add(uv, point2D(texsize[X] + texsize[Y] + texsize[X], midtexy)) // North right middle
					nbacktex = point2D_add(uv, point2D(-texsize[Y], midtexy)) // West left middle
				}
			}
		
			// X+ or X- half being bent
			else if (bend_part = e_part.RIGHT || bend_part = e_part.LEFT)
			{
				// Middle position
				sizefill = test(anglesign * partsign < 0, to[Z], -from[Z])
				pmidp = point3D(bend_offset - position[X], to[Y], 0)
				nmidp = point3D(pmidp[X], from[Y], pmidp[Z])
			
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
					pedgetex = point2D_add(uv, point2D(midtexx, texsize[Z])) // South middle bottom
					pbacktex = point2D_add(uv, point2D(texsize[X] + midtexx, 0)) // Bottom middle bottom
					nedgetex = point2D_add(uv, point2D(texsize[X] + texsize[Y] + texsize[X] - midtexx, texsize[Z])) // North middle bottom
					nbacktex = point2D_add(uv, point2D(texsize[X] + midtexx, -texsize[Y])) // Bottom middle top
				}
				else
				{
					pedgetex = point2D_add(uv, point2D(midtexx, 0)) // South middle top
					pbacktex = pedgetex // Top middle bottom
					nedgetex = point2D_add(uv, point2D(texsize[X] + texsize[Y] + texsize[X] - midtexx, 0)) // North middle top
					nbacktex = point2D_add(uv, point2D(midtexx, -texsize[Y])) // Top middle top
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
				pmidp = point3D(0, bend_offset - position[Y], to[Z])
				nmidp = point3D(pmidp[X], pmidp[Y], from[Z])
			
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
					nbacktex = point2D_add(uv, point2D(texsize[X] + texsize[Y] - midtexy, texsize[Z])) // East middle bottom
				}
				else
				{
					pedgetex = point2D_add(uv, point2D(0, -texsize[Y] + midtexy)) // Top left middle
					pbacktex = point2D_add(uv, point2D(-texsize[Y] + midtexy, 0)) // West middle top
					nedgetex = point2D_add(uv, point2D(texsize[X], -texsize[Y] + midtexy)) // Bottom left middle
					nbacktex = point2D_add(uv, point2D(-texsize[Y] + midtexy, texsize[Z])) // West middle bottom
				}
			}
		
			// X+ or X- half being bent
			else if (bend_part = e_part.RIGHT || bend_part = e_part.LEFT)
			{
				// Middle position
				sizefill = test(anglesign * partsign > 0, to[Y], -from[Y])
				pmidp = point3D(bend_offset - position[X], 0, to[Z])
				nmidp = point3D(pmidp[X], pmidp[Y], from[Z])
		
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
					pedgetex = point2D_add(uv, point2D(midtexx, -texsize[Y])) // Top middle top
					pbacktex = point2D_add(uv, point2D(texsize[X] + texsize[Y] + texsize[X] - midtexx, 0)) // North middle top
					nedgetex = point2D_add(uv, point2D(texsize[X] + midtexx, -texsize[Y])) // Bottom middle top
					nbacktex = point2D_add(uv, point2D(texsize[X] + texsize[Y] + texsize[X] - midtexx, texsize[Z])) // North middle bottom
				}
			}
		
			// Invalid
			else
				return null
		
			break
		}
	}

	// Mirror (switch positive and negative) (todo: this is UNFINISHED, only works well for arms/legs atm)
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

	vbuffer_start()

	for (var a = 0; a <= 1; a += 1 / detail)
	{
		var len = 1;
		if (!roundbend && a < 1)
			len = sqrtlen
	
		var dista, distb, pnextp, nnextp;
		dista = min(1, dcos(angle * a) * len) * sizefill * anglesign * partsign
		distb = dsin(angle * a) * len * sizefill * partsign
	
		// Find the next vertex
		switch (bend_axis)
		{
			case X:
			{
				if (bend_part = e_part.UPPER || bend_part = e_part.LOWER)
					pnextp = point3D(pmidp[X], -dista, distb + pmidp[Z])
				else // FRONT or BACK
					pnextp = point3D(pmidp[X], distb + pmidp[Y], dista)
		
				nnextp = point3D(nmidp[X], pnextp[Y], pnextp[Z])
				break
			}
		
			case Y:
			{
				if (bend_part = e_part.UPPER || bend_part = e_part.LOWER)
					pnextp = point3D(dista, pmidp[Y], distb + pmidp[Z])
				else // RIGHT or LEFT
					pnextp = point3D(distb + pmidp[X], pmidp[Y], -dista)
			
				nnextp = point3D(pnextp[X], nmidp[Y], pnextp[Z])
				break
			}
		
			case Z:
			{
				if (bend_part = e_part.FRONT || bend_part = e_part.BACK)
					pnextp = point3D(-dista, distb + pmidp[Y], pmidp[Z])
				else // RIGHT or LEFT
					pnextp = point3D(distb + pmidp[X], dista, pmidp[Z])
			
				nnextp = point3D(pnextp[X], pnextp[Y], nmidp[Z])
				break
			}
		}
	
		if (a > 0)
		{
			if (anglesign * invertsign > 0)
			{
				vbuffer_add_triangle(pcurp, pmidp, pnextp, pedgetex, pmidtex, pedgetex2) // +
				vbuffer_add_triangle(nmidp, ncurp, nnextp, nmidtex, nedgetex, nedgetex2) // -
				vbuffer_add_triangle(ncurp, pcurp, nnextp, nbacktex, pbacktex, nbacktex2, backnormal[a > 0.5]) // Back 1
				vbuffer_add_triangle(nnextp, pcurp, pnextp, nbacktex2, pbacktex, pbacktex2, backnormal[a > 0.5]) // Back 2
			}
			else // Invert
			{
				vbuffer_add_triangle(pmidp, pcurp, pnextp, pmidtex, pedgetex, pedgetex2) // +
				vbuffer_add_triangle(ncurp, nmidp, nnextp, nedgetex, nmidtex, nedgetex2) // -
				vbuffer_add_triangle(pcurp, ncurp, nnextp, pbacktex, nbacktex, nbacktex2, backnormal[a > 0.5]) // Back 1
				vbuffer_add_triangle(pcurp, nnextp, pnextp, pbacktex, nbacktex2, pbacktex2, backnormal[a > 0.5]) // Back 2
			}
		}
			
		pcurp = pnextp
		ncurp = nnextp
	}

	return vbuffer_done()
}