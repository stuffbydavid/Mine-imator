/// model_shape_bend_vbuffer(shape, angle, round)
/// @arg shape
/// @arg angle
/// @arg round
/// @desc Returns an "in-between" mesh that connects the two halves of the given shape.

var shape, angle, roundbend;
shape = argument0
angle = argument1
roundbend = argument2

if (shape.type != "block")
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

// TODO support scale

switch (shape.bend_axis)
{
	case X:
	{
		// Z+ or Z- half being bent
		if (shape.bend_part = e_part.UPPER || shape.bend_part = e_part.LOWER)
		{
			// Middle position
			sizefill = test(anglesign < 0, shape.to[Y], -shape.from[Y])
			pmidp = point3D(shape.to[X], 0, shape.bend_offset)
			nmidp = point3D(shape.from[X], pmidp[Y], pmidp[Z])
		
			// Normal
			if (roundbend)
			{
				backnormal[0] = vec3(0, dcos(0) * anglesign * (-partsign), dsin(0) * partsign)
				backnormal[1] = vec3(0, dcos(angle * 0.75) * anglesign * (-partsign), dsin(angle * 0.75) * partsign)
			}
			
			// Texture
			var midtexy = shape.to[Z] - shape.bend_offset;
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
			sizefill = test(anglesign < 0, shape.to[Z], -shape.from[Z])
			pmidp = point3D(shape.to[X], shape.bend_offset, 0)
			nmidp = point3D(shape.from[X], pmidp[Y], pmidp[Z])
			
			// Normal
			if (roundbend)
			{
				backnormal[0] = vec3(0, dsin(0) * partsign, dcos(0) * anglesign * partsign)
				backnormal[1] = vec3(0, dsin(angle * 0.75) * partsign, dcos(angle * 0.75) * anglesign * partsign)
			}
			
			// Texture
			var midtexx = shape.to[Y] - shape.bend_offset;
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
		pmidtex = shape.uv
		nmidtex = shape.uv
		pedgetex = shape.uv
		pbacktex = shape.uv
		nedgetex = shape.uv
		nbacktex = shape.uv
		
		// Z+ or Z- half being bent
		if (shape.bend_part = e_part.UPPER || shape.bend_part = e_part.LOWER)
		{
			// Middle position
			sizefill = test(anglesign > 0, shape.to[X], -shape.from[X])
			pmidp = point3D(0, shape.to[Y], shape.bend_offset)
			nmidp = point3D(pmidp[X], shape.from[Y], pmidp[Z])
		
		}
		
		// X+ or X- half being bent
		else if (shape.bend_part = e_part.RIGHT || shape.bend_part = e_part.LEFT)
		{
			// Middle position
			sizefill = test(anglesign > 0, shape.to[Z], -shape.from[Z])
			pmidp = point3D(shape.bend_offset, shape.to[Y], 0)
			nmidp = point3D(pmidp[X], shape.from[Y], pmidp[Z])
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
		}
		
		// X+ or X- half being bent
		else if (shape.bend_part = e_part.RIGHT || shape.bend_part = e_part.LEFT)
		{
		
		}
		
		// Invalid
		else
			return null
		
		break
	}
}

// No flicker
var pedgetex2, nedgetex2, pbacktex2, nbacktex2;
pedgetex2 = point2D_add(pedgetex, point2D(0, 1 / 16))
pbacktex2 = point2D_add(pbacktex, point2D(0, 1 / 16))
nedgetex2 = point2D_add(nedgetex, point2D(0, 1 / 16))
nbacktex2 = point2D_add(nbacktex, point2D(0, 1 / 16))

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

var a = 0;
while (a <= 1)
{
	var len = 1;
	if (!roundbend && a < 1)
		len = sqrtlen
	
	var pnextp, nnextp;
	switch (shape.bend_axis)
	{
		case X:
		{
			if (shape.bend_part = e_part.UPPER || shape.bend_part = e_part.LOWER)
			{
				pnextp = point3D(shape.to[X],
								 min(1, dcos(angle * a) * len) * sizefill * anglesign * (-partsign),
								 shape.bend_offset + dsin(angle * a) * len * sizefill * partsign)
			}
			else // FRONT or BACK
			{
				pnextp = point3D(shape.to[X],
								 shape.bend_offset + dsin(angle * a) * len * sizefill * partsign,
								 min(1, dcos(angle * a) * len) * sizefill * anglesign * partsign)
			}
		
			nnextp = point3D(shape.from[X], pnextp[Y], pnextp[Z])
			break
		}
		
		case Y:
		{
			if (shape.bend_part = e_part.UPPER || shape.bend_part = e_part.LOWER)
			{
				pnextp = point3D(min(1, dcos(angle * a) * len) * sizefill * anglesign * partsign,
								 shape.to[Y],
								 shape.bend_offset + dsin(angle * a) * len * sizefill * partsign)
			}
			else // RIGHT or LEFT
			{
				pnextp = point3D(shape.bend_offset + dsin(angle * a) * len * sizefill * partsign,
								 shape.to[Y],
								 min(1, dcos(angle * a) * len) * sizefill * anglesign * (-partsign))
			}
			
			nnextp = point3D(pnextp[X], shape.from[Y], pnextp[Z])
			break
		}
		
		case Z:
		{
			if (shape.bend_part = e_part.FRONT || shape.bend_part = e_part.BACK)
			{
				
			}
			else // RIGHT or LEFT
			{
				
			}
			
			nnextp = point3D(pnextp[X], pnextp[Y], shape.from[Z])
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
	
	a += 1 / detail
}

return vbuffer_done()