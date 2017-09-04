/// model_shape_bend_vbuffer(shape, angle, round)
/// @arg shape
/// @arg angle
/// @arg round
/// @desc Returns an "in-between" mesh that connects the two halves of the given shape.

var shape, angle, roundbend, anglesign, partsign, detail;
shape = argument0
angle = argument1
roundbend = argument2

if (shape.type != "block")
	return null

// Limit angle
if (shape.bend_direction = e_bend.FORWARD)
	angle = min(0, -angle)
else if (shape.bend_direction = e_bend.BACKWARD)
	angle = max(0, angle)
	
anglesign = sign(angle)
angle = abs(angle)
partsign = 1
detail = test(roundbend, app.setting_bend_detail, 2)

var size, sizefill, midy, midz, cury, curz, nexty, nextz, len, backnormal;
var pmidtex, nmidtex, pedgetex, nedgetex, nbacktex, pbacktex;

size = point3D_sub(shape.to, shape.from)
backnormal = array(null, null)

switch (shape.bend_axis)
{
	case X:
	{
		if (shape.bend_part = e_part.LOWER || shape.bend_part = e_part.UPPER)
		{
			if (shape.bend_part = e_part.LOWER)
				partsign = -1
			
			// Position
			sizefill = shape.to[Y]
			midy = 0
			midz = shape.bend_offset
			cury = sizefill * anglesign * (-partsign)
			curz = shape.bend_offset
		
			// Normal
			if (roundbend)
			{
				backnormal[0] = vec3(0, dcos(0) * anglesign * (-partsign), dsin(0) * partsign)
				backnormal[1] = vec3(0, dcos(angle * 0.75) * anglesign * (-partsign), dsin(angle * 0.75) * partsign)
			}
			
			// Texture
			var midytex = shape.to[Z] - shape.bend_offset;
			pmidtex = point2D_add(shape.uv, point2D(size[X] + shape.to[Y], midytex))
			nmidtex = point2D_add(shape.uv, point2D(-shape.to[Y], midytex))
			if (anglesign * partsign > 0)
			{
				log("1")
				pedgetex = point2D_add(shape.uv, point2D(size[X] + size[Y], midytex))
				pbacktex = pedgetex
				nedgetex = point2D_add(shape.uv, point2D(-size[Y], midytex))
				nbacktex = point2D_add(pbacktex, point2D(size[X], 0))
			}
			else
			{
				log("2")
				pedgetex = point2D_add(shape.uv, point2D(size[X], midytex))
				pbacktex = pedgetex
				nedgetex = point2D_add(shape.uv, point2D(0, midytex))
				nbacktex = nedgetex
			}
		}
		
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
while (a < 1)
{
	a += 1 / detail
	if (!roundbend && a < 1)
		len = sqrt(2 - abs(90 - angle) / 90)
	else
		len = 1
			
	// TODO check part
	nexty = min(1, dcos(angle * a) * len) * sizefill * anglesign * (-partsign)
	nextz = shape.bend_offset + dsin(angle * a) * len * sizefill * partsign
			
	var pmidp = point3D(shape.to[X], midy, midz);
	var pcurp = point3D(shape.to[X], cury, curz);
	var pnextp = point3D(shape.to[X], nexty, nextz);
	var nmidp = point3D(shape.from[X], midy, midz);
	var ncurp = point3D(shape.from[X], cury, curz);
	var nnextp = point3D(shape.from[X], nexty, nextz);
			
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
					
	cury = nexty
	curz = nextz
}

return vbuffer_done()