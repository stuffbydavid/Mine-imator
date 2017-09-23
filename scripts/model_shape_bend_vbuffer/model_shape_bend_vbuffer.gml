/// model_shape_bend_vbuffer(shape, angle, round)
/// @arg shape
/// @arg angle
/// @arg round
/// @desc Returns an "in-between" mesh that connects the two halves of the given shape.

var shape, angle, roundbend;
shape = argument0
angle = argument1
roundbend = argument2

if (shape.type != "block" || shape.bend_mode != e_shape_bend.BEND)
	return null

var anglesign, partsign, detail;

// Limit angle
if (shape.bend_direction = e_bend.FORWARD)
	angle = min(0, -angle)
else if (shape.bend_direction = e_bend.BACKWARD)
	angle = max(0, angle)
	
anglesign = sign(angle)
angle = abs(angle)
detail = test(roundbend, app.setting_bend_detail, 2)

if (shape.bend_part = e_part.LEFT || shape.bend_part = e_part.BACK || shape.bend_part = e_part.LOWER)
	partsign = -1
else
	partsign = 1

var size, sizefill, pmidp, nmidp, pcurp, ncurp;
var sqrtlen, backnormal;
var pmidtex, nmidtex, pedgetex, nedgetex, nbacktex, pbacktex;

size = point3D_sub(shape.to, shape.from)
backnormal = array(null, null)
sqrtlen = sqrt(2 - abs(90 - angle) / 90)

switch (shape.bend_axis)
{
	case X:
	{
		// Z+ or Z- half being bent
		if (shape.bend_part = e_part.UPPER || shape.bend_part = e_part.LOWER)
		{
			// Middle position
			sizefill = test(anglesign * partsign < 0, shape.to[Y], -shape.from[Y]) * shape.scale[Y]
			pmidp = point3D(shape.to[X] * shape.scale[X], 0, shape.bend_offset - shape.position[Z])
			nmidp = point3D(shape.from[X] * shape.scale[X], pmidp[Y], pmidp[Z])
		
			// Normal
			if (roundbend)
			{
				backnormal[0] = vec3(0, dcos(0) * anglesign * (-partsign), dsin(0) * partsign)
				backnormal[1] = vec3(0, dcos(angle * 0.75) * anglesign * (-partsign), dsin(angle * 0.75) * partsign)
			}
			
			// Texture
			var midtexy = shape.to[Z] - (shape.bend_offset - shape.position[Z]);
			pmidtex = point2D_add(shape.uv, point2D(size[X] + shape.to[Y], midtexy)) // East middle
			nmidtex = point2D_add(shape.uv, point2D(-shape.to[Y], midtexy)) // West middle
			if (anglesign * partsign > 0)
			{
				pedgetex = point2D_add(shape.uv, point2D(size[X] + size[Y], midtexy)) // East right middle
				pbacktex = pedgetex // Back left middle
				nedgetex = point2D_add(shape.uv, point2D(-size[Y], midtexy)) // West left middle
				nbacktex = point2D_add(pbacktex, point2D(size[X], 0)) // Back right middle
			}
			else
			{
				pedgetex = point2D_add(shape.uv, point2D(size[X], midtexy)) // East left middle
				pbacktex = pedgetex // Front right middle
				nedgetex = point2D_add(shape.uv, point2D(0, midtexy)) // West right middle
				nbacktex = nedgetex // Front left middle
			}
		}
		
		// Y+ or Y- half being bent
		else if (shape.bend_part = e_part.FRONT || shape.bend_part = e_part.BACK)
		{
			// Middle position
			sizefill = test(anglesign * partsign > 0, shape.to[Z], -shape.from[Z]) * shape.scale[Z]
			pmidp = point3D(shape.to[X] * shape.scale[X], shape.bend_offset - shape.position[Y], 0)
			nmidp = point3D(shape.from[X] * shape.scale[X], pmidp[Y], pmidp[Z])
			
			// Normal
			if (roundbend)
			{
				backnormal[0] = vec3(0, dsin(0) * partsign, dcos(0) * anglesign * partsign)
				backnormal[1] = vec3(0, dsin(angle * 0.75) * partsign, dcos(angle * 0.75) * anglesign * partsign)
			}
			
			// Texture
			var midtexx = shape.to[Y] - (shape.bend_offset - shape.position[Y]);
			pmidtex = point2D_add(shape.uv, point2D(size[X] + midtexx, shape.to[Z])) // East middle
			nmidtex = point2D_add(shape.uv, point2D(-midtexx, shape.to[Z])) // West middle
			if (anglesign * partsign > 0)
			{
				pedgetex = point2D_add(shape.uv, point2D(size[X] + midtexx, 0)) // East middle top
				pbacktex = point2D_add(shape.uv, point2D(size[X], -midtexx)) // Top right middle
				nedgetex = point2D_add(shape.uv, point2D(-midtexx, 0)) // West middle top
				nbacktex = point2D_add(shape.uv, point2D(0, -midtexx)) // Top left middle
			}
			else
			{
				pedgetex = point2D_add(shape.uv, point2D(size[X] + midtexx, size[Z])) // East middle bottom
				pbacktex = point2D_add(shape.uv, point2D(size[X] + size[X], -midtexx)) // Bottom right middle
				nedgetex = point2D_add(shape.uv, point2D(-midtexx, size[Z])) // West middle bottom
				nbacktex = point2D_add(shape.uv, point2D(size[X], -midtexx)) // Bottom left middle
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
		if (shape.bend_part = e_part.UPPER || shape.bend_part = e_part.LOWER)
		{
			// Middle position
			sizefill = test(anglesign * partsign > 0, shape.to[X], -shape.from[X]) * shape.scale[X]
			pmidp = point3D(0, shape.to[Y] * shape.scale[Y], shape.bend_offset - shape.position[Z])
			nmidp = point3D(pmidp[X], shape.from[Y] * shape.scale[Y], pmidp[Z])
			
			// Normal
			if (roundbend)
			{
				backnormal[0] = vec3(dcos(0) * anglesign * partsign, 0, dsin(0) * partsign)
				backnormal[1] = vec3(dcos(angle * 0.75) * anglesign * partsign, 0, dsin(angle * 0.75) * partsign)
			}
			
			// Texture
			var midtexy = shape.to[Z] - (shape.bend_offset - shape.position[Z]);
			pmidtex = point2D_add(shape.uv, point2D(-shape.from[X], midtexy)) // South middle
			nmidtex = point2D_add(shape.uv, point2D(size[X] + size[Y] - shape.from[X], midtexy)) // North middle
			if (anglesign * partsign > 0)
			{
				pedgetex = point2D_add(shape.uv, point2D(size[X], midtexy)) // South right middle
				pbacktex = pedgetex // East left middle
				nedgetex = point2D_add(shape.uv, point2D(size[X] + size[Y], midtexy)) // East right middle
				nbacktex = nedgetex // North left middle
			}
			else
			{
				pedgetex = point2D_add(shape.uv, point2D(0, midtexy)) // South left middle
				pbacktex = pedgetex // West right middle
				nedgetex = point2D_add(shape.uv, point2D(size[X] + size[Y] + size[X], midtexy)) // North right middle
				nbacktex = point2D_add(shape.uv, point2D(-size[Y], midtexy)) // West left middle
			}
		}
		
		// X+ or X- half being bent
		else if (shape.bend_part = e_part.RIGHT || shape.bend_part = e_part.LEFT)
		{
			// Middle position
			sizefill = test(anglesign * partsign < 0, shape.to[Z], -shape.from[Z]) * shape.scale[Z]
			pmidp = point3D(shape.bend_offset - shape.position[X], shape.to[Y] * shape.scale[Y], 0)
			nmidp = point3D(pmidp[X], shape.from[Y] * shape.scale[Y], pmidp[Z])
			
			// Normal
			if (roundbend)
			{
				backnormal[0] = vec3(dsin(0) * partsign, 0, -dcos(0) * anglesign * partsign)
				backnormal[1] = vec3(dsin(angle * 0.75) * partsign, 0, -dcos(angle * 0.75) * anglesign * partsign)
			}
			
			// Texture
			var midtexx = size[X] - (shape.to[X] - (shape.bend_offset - shape.position[X]));
			pmidtex = point2D_add(shape.uv, point2D(midtexx, shape.to[Z])) // South middle
			nmidtex = point2D_add(shape.uv, point2D(size[X] + size[Y] + size[X] - midtexx, shape.to[Z])) // North middle
			if (anglesign * partsign > 0)
			{
				pedgetex = point2D_add(shape.uv, point2D(midtexx, size[Z])) // South middle bottom
				pbacktex = point2D_add(shape.uv, point2D(size[X] + midtexx, 0)) // Bottom middle bottom
				nedgetex = point2D_add(shape.uv, point2D(size[X] + size[Y] + size[X] - midtexx, size[Z])) // North middle bottom
				nbacktex = point2D_add(shape.uv, point2D(size[X] + midtexx, -size[Y])) // Bottom middle top
			}
			else
			{
				pedgetex = point2D_add(shape.uv, point2D(midtexx, 0)) // South middle top
				pbacktex = pedgetex // Top middle bottom
				nedgetex = point2D_add(shape.uv, point2D(size[X] + size[Y] + size[X] - midtexx, 0)) // North middle top
				nbacktex = point2D_add(shape.uv, point2D(midtexx, -size[Y])) // Top middle top
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
		if (shape.bend_part = e_part.FRONT || shape.bend_part = e_part.BACK)
		{
			// Middle position
			sizefill = test(anglesign * partsign < 0, shape.to[X], -shape.from[X]) * shape.scale[X]
			pmidp = point3D(0, shape.bend_offset - shape.position[Y], shape.to[Z] * shape.scale[Z])
			nmidp = point3D(pmidp[X], pmidp[Y], shape.from[Z] * shape.scale[Z])
			
			// Normal
			if (roundbend)
			{
				backnormal[0] = vec3(-dcos(0) * anglesign * partsign, dsin(0) * partsign, 0)
				backnormal[1] = vec3(-dcos(angle * 0.75) * anglesign * partsign, dsin(angle * 0.75) * partsign, 0)
			}
			
			// Texture
			var midtexy = shape.to[Y] - (shape.bend_offset - shape.position[Y]);
			pmidtex = point2D_add(shape.uv, point2D(-shape.from[Z], -size[Y] + midtexy)) // Top middle
			nmidtex = point2D_add(shape.uv, point2D(size[X] - shape.from[Z], -size[Y] + midtexy)) // Bottom middle
			if (anglesign * partsign > 0)
			{
				pedgetex = point2D_add(shape.uv, point2D(size[X], -size[Y] + midtexy)) // Top right middle
				pbacktex = point2D_add(shape.uv, point2D(size[X] + size[Y] - midtexy, 0)) // East middle top
				nedgetex = point2D_add(shape.uv, point2D(size[X] + size[X], -size[Y] + midtexy)) // Bottom right middle
				nbacktex = point2D_add(shape.uv, point2D(size[X] + size[Y] - midtexy, size[Z])) // East middle bottom
			}
			else
			{
				pedgetex = point2D_add(shape.uv, point2D(0, -size[Y] + midtexy)) // Top left middle
				pbacktex = point2D_add(shape.uv, point2D(-size[Y] + midtexy, 0)) // West middle top
				nedgetex = point2D_add(shape.uv, point2D(size[X], -size[Y] + midtexy)) // Bottom left middle
				nbacktex = point2D_add(shape.uv, point2D(-size[Y] + midtexy, size[Z])) // West middle bottom
			}
		}
		
		// X+ or X- half being bent
		else if (shape.bend_part = e_part.RIGHT || shape.bend_part = e_part.LEFT)
		{
			// Middle position
			sizefill = test(anglesign * partsign > 0, shape.to[Y], -shape.from[Y]) * shape.scale[Y]
			pmidp = point3D(shape.bend_offset - shape.position[X], 0, shape.to[Z] * shape.scale[Z])
			nmidp = point3D(pmidp[X], pmidp[Y], shape.from[Z] * shape.scale[Z])
		
			// Normal
			if (roundbend)
			{
				backnormal[0] = vec3(dsin(0) * partsign, dcos(0) * anglesign * partsign, 0)
				backnormal[1] = vec3(dsin(angle * 0.75) * partsign, dcos(angle * 0.75) * anglesign * partsign, 0)
			}
			
			// Texture
			var midtexx = size[X] - (shape.to[X] - (shape.bend_offset - shape.position[X]));
			pmidtex = point2D_add(shape.uv, point2D(midtexx, -size[Y] - shape.from[Y])) // Top middle
			nmidtex = point2D_add(shape.uv, point2D(size[X] + midtexx, -size[Y] - shape.from[Y])) // Bottom middle
			if (anglesign * partsign > 0)
			{
				pedgetex = point2D_add(shape.uv, point2D(midtexx, 0)) // Top middle bottom
				pbacktex = pedgetex // South middle top
				nedgetex = point2D_add(shape.uv, point2D(size[X] + midtexx, 0)) // Bottom middle bottom
				nbacktex = point2D_add(shape.uv, point2D(midtexx, size[Z])) // South middle bottom
			}
			else
			{
				pedgetex = point2D_add(shape.uv, point2D(midtexx, -size[Y])) // Top middle top
				pbacktex = point2D_add(shape.uv, point2D(size[X] + size[Y] + size[X] - midtexx, 0)) // North middle top
				nedgetex = point2D_add(shape.uv, point2D(size[X] + midtexx, -size[Y])) // Bottom middle top
				nbacktex = point2D_add(shape.uv, point2D(size[X] + size[Y] + size[X] - midtexx, size[Z])) // North middle bottom
			}
		}
		
		// Invalid
		else
			return null
		
		break
	}
}

// No flicker
var pedgetex2, nedgetex2, pbacktex2, nbacktex2;
pedgetex2 = point2D_add(pedgetex, point2D(1 / 256, 1 / 256))
pbacktex2 = point2D_add(pbacktex, point2D(1 / 256, 1 / 256))
nedgetex2 = point2D_add(nedgetex, point2D(1 / 256, 1 / 256))
nbacktex2 = point2D_add(nbacktex, point2D(1 / 256, 1 / 256))

// Transform texture to 0-1
pmidtex = vec2_div(pmidtex, shape.texture_size)
pedgetex = vec2_div(pedgetex, shape.texture_size)
pedgetex2 = vec2_div(pedgetex2, shape.texture_size)
pbacktex = vec2_div(pbacktex, shape.texture_size)
pbacktex2 = vec2_div(pbacktex2, shape.texture_size)
nmidtex = vec2_div(nmidtex, shape.texture_size)
nedgetex = vec2_div(nedgetex, shape.texture_size)
nedgetex2 = vec2_div(nedgetex2, shape.texture_size)
nbacktex = vec2_div(nbacktex, shape.texture_size)
nbacktex2 = vec2_div(nbacktex2, shape.texture_size)

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
	switch (shape.bend_axis)
	{
		case X:
		{
			if (shape.bend_part = e_part.UPPER || shape.bend_part = e_part.LOWER)
				pnextp = point3D(pmidp[X], -dista, distb + pmidp[Z])
			else // FRONT or BACK
				pnextp = point3D(pmidp[X], distb + pmidp[Y], dista)
		
			nnextp = point3D(nmidp[X], pnextp[Y], pnextp[Z])
			break
		}
		
		case Y:
		{
			if (shape.bend_part = e_part.UPPER || shape.bend_part = e_part.LOWER)
				pnextp = point3D(dista, pmidp[Y], distb + pmidp[Z])
			else // RIGHT or LEFT
				pnextp = point3D(distb + pmidp[X], pmidp[Y], -dista)
			
			nnextp = point3D(pnextp[X], nmidp[Y], pnextp[Z])
			break
		}
		
		case Z:
		{
			if (shape.bend_part = e_part.FRONT || shape.bend_part = e_part.BACK)
				pnextp = point3D(-dista, distb + pmidp[Y], pmidp[Z])
			else // RIGHT or LEFT
				pnextp = point3D(distb + pmidp[X], dista, pmidp[Z])
			
			nnextp = point3D(pnextp[X], pnextp[Y], nmidp[Z])
			break
		}
	}
	
	if (a > 0)
	{
		if (anglesign > 0)
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