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

// TEMPORARY TEXTURE
var temptex;
temptex[0] = vec2_div(point2D(10, 10), shape.texture_size)
temptex[1] = vec2_div(point2D(11, 10), shape.texture_size)
temptex[2] = vec2_div(point2D(10, 11), shape.texture_size)

vbuffer_start()

switch (shape.bend_part)
{
	case e_part.LOWER:
		partsign = -1
		
	case e_part.UPPER:
	{
		var size = shape.to[Y];	// Y Size
		var midy = 0;					// Middle Y
		var midz = shape.bend_offset;	// Middle Z
		var cury = size * anglesign * (-partsign); // Current Y
		var curz = shape.bend_offset;				// Current Z
		var nexty, nextz, len, backnormal, a = 0;
		
		backnormal = array(null, null)
		
		if (roundbend)
		{
			backnormal[0] = vec3(0, dcos(0) * anglesign * (-partsign), dsin(0) * partsign)
			backnormal[1] = vec3(0, dcos(angle * 0.75) * anglesign * (-partsign), dsin(angle * 0.75) * partsign)
		}
		
		while (a < 1)
		{
			a += 1 / detail
			if (!roundbend && a < 1)
				len = sqrt(2 - abs(90 - angle) / 90)
			else
				len = 1
			
			nexty = min(1, dcos(angle * a) * len) * size * anglesign * (-partsign)
			nextz = shape.bend_offset + dsin(angle * a) * len * size * partsign
			
			var nmidp = point3D(shape.from[X], midy, midz);
			var ncurp = point3D(shape.from[X], cury, curz);
			var nnextp = point3D(shape.from[X], nexty, nextz);
			var pmidp = point3D(shape.to[X], midy, midz);
			var pcurp = point3D(shape.to[X], cury, curz);
			var pnextp = point3D(shape.to[X], nexty, nextz);
			
			if (anglesign > 0)
			{
				vbuffer_add_triangle(nmidp, ncurp, nnextp, temptex[0], temptex[1], temptex[2]) // -
				vbuffer_add_triangle(pcurp, pmidp, pnextp, temptex[0], temptex[1], temptex[2]) // +
				vbuffer_add_triangle(ncurp, pcurp, nnextp, temptex[0], temptex[1], temptex[2], backnormal[a > 0.5]) // Back 1
				vbuffer_add_triangle(nnextp, pcurp, pnextp, temptex[0], temptex[1], temptex[2], backnormal[a > 0.5]) // Back 2
			}
			else // Invert
			{
				vbuffer_add_triangle(ncurp, nmidp, nnextp, temptex[0], temptex[1], temptex[2]) // -
				vbuffer_add_triangle(pmidp, pcurp, pnextp, temptex[0], temptex[1], temptex[2]) // +
				vbuffer_add_triangle(pcurp, ncurp, nnextp, temptex[0], temptex[1], temptex[2], backnormal[a > 0.5]) // Back 1
				vbuffer_add_triangle(pcurp, nnextp, pnextp, temptex[0], temptex[1], temptex[2], backnormal[a > 0.5]) // Back 2
			}
					
			cury = nexty
			curz = nextz
		}
		
		break
	}
}

return vbuffer_done()