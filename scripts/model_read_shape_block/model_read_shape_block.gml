/// model_read_shape_block([bend])
/// @arg [bend]
/// @desc Generates a block shape, bend is supplied if this is the bended half.

var bend, mat, size;
if (argument_count > 0)
	bend = argument[0]
else
	bend = false
mat = vertex_matrix
size = point3D_sub(to, from)

var x1, x2, y1, y2, z1, z2;
var p1, p2, p3, p4;
var xptex, xntex, yptex, yntex, zptex, zntex;
var xpadd, xnadd, ypadd, ynadd, zpadd, znadd;

x1 = 0;	   y1 = 0;	   z1 = 0
x2 = size[X]; y2 = size[Y]; z2 = size[Z]

// Define texture coordinates to use (clockwise, starting at top-left)

xptex[0] = point2D_add(uv, point2D(size[X], 0))
xptex[1] = point2D_add(xptex[0], point2D(size[Y], 0))
xptex[2] = point2D_add(xptex[0], point2D(size[Y], size[Z]))
xptex[3] = point2D_add(xptex[0], point2D(0, size[Z]))

xntex[0] = point2D_sub(uv, point2D(size[Y], 0))
xntex[1] = point2D_add(xntex[0], point2D(size[Y], 0))
xntex[2] = point2D_add(xntex[0], point2D(size[Y], size[Z]))
xntex[3] = point2D_add(xntex[0], point2D(0, size[Z]))

yptex[0] = uv
yptex[1] = point2D_add(yptex[0], point2D(size[X], 0))
yptex[2] = point2D_add(yptex[0], point2D(size[X], size[Z]))
yptex[3] = point2D_add(yptex[0], point2D(0, size[Z]))

yntex[0] = point2D_add(xptex[0], point2D(size[Y], 0))
yntex[1] = point2D_add(yntex[0], point2D(size[X], 0))
yntex[2] = point2D_add(yntex[0], point2D(size[X], size[Z]))
yntex[3] = point2D_add(yntex[0], point2D(0, size[Z]))

zptex[0] = point2D_sub(uv, point2D(0, size[Y]))
zptex[1] = point2D_add(zptex[0], point2D(size[X], 0))
zptex[2] = point2D_add(zptex[0], point2D(size[X], size[Y]))
zptex[3] = point2D_add(zptex[0], point2D(0, size[Y]))

zntex[0] = point2D_add(zptex[0], point2D(size[X], 0))
zntex[1] = point2D_add(zntex[0], point2D(0, size[Y]))
zntex[2] = point2D_add(zntex[0], point2D(size[X], size[Y]))
zntex[3] = point2D_add(zntex[0], point2D(size[X], 0))

// Set to add
xpadd = true
xnadd = true
ypadd = true
ynadd = true
zpadd = true
znadd = true

// Adjust by bending
if (bend_part != null)
{
	if (bend) // Bent half
	{
		switch (bend_part)
		{
			case e_part.UPPER:
			{
				z2 = size[Z] - bend_offset + from[Z]
				znadd = false
				
				var texoff = point2D(0, -(bend_offset - from[Z]))
				xptex[2] = point2D_add(xptex[2], texoff)
				xptex[3] = point2D_add(xptex[3], texoff)
				xntex[2] = point2D_add(xntex[2], texoff)
				xntex[3] = point2D_add(xntex[3], texoff)
				yptex[2] = point2D_add(yptex[2], texoff)
				yptex[3] = point2D_add(yptex[3], texoff)
				yntex[2] = point2D_add(yntex[2], texoff)
				yntex[3] = point2D_add(yntex[3], texoff)
				
				mat = matrix_create(point3D(from[X], from[Y], 0), vec3(0), scale)
				break
			}
			
			case e_part.LOWER:
			{
				z2 = 0
				z1 = -(bend_offset - from[Z])
				zpadd = false
				
				var texoff = point2D(0, (bend_offset - from[Z]))
				xptex[0] = point2D_add(xptex[0], texoff)
				xptex[1] = point2D_add(xptex[1], texoff)
				xntex[0] = point2D_add(xntex[0], texoff)
				xntex[1] = point2D_add(xntex[1], texoff)
				yptex[0] = point2D_add(yptex[0], texoff)
				yptex[1] = point2D_add(yptex[1], texoff)
				yntex[0] = point2D_add(yntex[0], texoff)
				yntex[1] = point2D_add(yntex[1], texoff)
				
				mat = matrix_create(point3D(from[X], from[Y], 0), vec3(0), scale)
				break
			}
		}
	}
	else
	{
		switch (bend_part)
		{
			case e_part.UPPER:
			{
				z2 = (bend_offset - from[Z]) / scale[Z]
				zpadd = false
				
				var texoff = point2D(0, (bend_offset - from[Z]))
				xptex[0] = point2D_add(xptex[0], texoff)
				xptex[1] = point2D_add(xptex[1], texoff)
				xntex[0] = point2D_add(xntex[0], texoff)
				xntex[1] = point2D_add(xntex[1], texoff)
				yptex[0] = point2D_add(yptex[0], texoff)
				yptex[1] = point2D_add(yptex[1], texoff)
				yntex[0] = point2D_add(yntex[0], texoff)
				yntex[1] = point2D_add(yntex[1], texoff)
				break
			}
				
			case e_part.LOWER:
			{
				z1 = (bend_offset - from[Z]) / scale[Z]
				znadd = false
				
				var texoff = point2D(0, -(bend_offset - from[Z]))
				xptex[2] = point2D_add(xptex[2], texoff)
				xptex[3] = point2D_add(xptex[3], texoff)
				xntex[2] = point2D_add(xntex[2], texoff)
				xntex[3] = point2D_add(xntex[3], texoff)
				yptex[2] = point2D_add(yptex[2], texoff)
				yptex[3] = point2D_add(yptex[3], texoff)
				yntex[2] = point2D_add(yntex[2], texoff)
				yntex[3] = point2D_add(yntex[3], texoff)
				break
			}
		}
	}
}

// Transform to values between 0-1
for (var t = 0; t < 4; t++)
{
	xptex[t] = vec2_div(xptex[t], texture_size)
	xntex[t] = vec2_div(xntex[t], texture_size)
	yptex[t] = vec2_div(yptex[t], texture_size)
	yntex[t] = vec2_div(yntex[t], texture_size)
	zptex[t] = vec2_div(zptex[t], texture_size)
	zntex[t] = vec2_div(zntex[t], texture_size)
}

// X+
if (xpadd)
{
	p1 = point3D(x2, y2, z2)
	p2 = point3D(x2, y1, z2)
	p3 = point3D(x2, y1, z1)
	p4 = point3D(x2, y2, z1)
	vbuffer_add_triangle(p1, p2, p3, xptex[0], xptex[1], xptex[2], mat)
	vbuffer_add_triangle(p3, p4, p1, xptex[2], xptex[3], xptex[0], mat)
}

// X-
if (xnadd)
{ 
	p1 = point3D(x1, y1, z2)
	p2 = point3D(x1, y2, z2)
	p3 = point3D(x1, y2, z1)
	p4 = point3D(x1, y1, z1)
	vbuffer_add_triangle(p1, p2, p3, xntex[0], xntex[1], xntex[2], mat)
	vbuffer_add_triangle(p3, p4, p1, xntex[2], xntex[3], xntex[0], mat)
}

// Y+
if (ypadd)
{
	p1 = point3D(x1, y2, z2)
	p2 = point3D(x2, y2, z2)
	p3 = point3D(x2, y2, z1)
	p4 = point3D(x1, y2, z1)
	vbuffer_add_triangle(p1, p2, p3, yptex[0], yptex[1], yptex[2], mat)
	vbuffer_add_triangle(p3, p4, p1, yptex[2], yptex[3], yptex[0], mat)
}

// Y-
if (ynadd)
{
	p1 = point3D(x2, y1, z2)
	p2 = point3D(x1, y1, z2)
	p3 = point3D(x1, y1, z1)
	p4 = point3D(x2, y1, z1)
	vbuffer_add_triangle(p1, p2, p3, yntex[0], yntex[1], yntex[2], mat)
	vbuffer_add_triangle(p3, p4, p1, yntex[2], yntex[3], yntex[0], mat)
}

// Z+
if (zpadd)
{
	p1 = point3D(x1, y1, z2)
	p2 = point3D(x2, y1, z2)
	p3 = point3D(x2, y2, z2)
	p4 = point3D(x1, y2, z2)
	vbuffer_add_triangle(p1, p2, p3, zptex[0], zptex[1], zptex[2], mat)
	vbuffer_add_triangle(p3, p4, p1, zptex[2], zptex[3], zptex[0], mat)
}

// Z-
if (znadd)
{
	p1 = point3D(x1, y1, z1)
	p2 = point3D(x1, y2, z1)
	p3 = point3D(x2, y2, z1)
	p4 = point3D(x2, y1, z1)
	vbuffer_add_triangle(p1, p2, p3, zntex[0], zntex[1], zntex[2], mat)
	vbuffer_add_triangle(p3, p4, p1, zntex[2], zntex[3], zntex[0], mat)
}

// Update bounds
if (!bend)
{
	var startpos, endpos;
	startpos = point3D_mul_matrix(point3D(0, 0, 0), vertex_matrix);
	endpos   = point3D_mul_matrix(size, vertex_matrix);
	bounds_start[X] = min(bounds_start[X], startpos[X], endpos[X])
	bounds_start[Y] = min(bounds_start[Y], startpos[Y], endpos[Y])
	bounds_start[Z] = min(bounds_start[Z], startpos[Z], endpos[Z])
	bounds_end[X]	= max(bounds_end[X], startpos[X], endpos[X])
	bounds_end[Y]	= max(bounds_end[Y], startpos[Y], endpos[Y])
	bounds_end[Z]	= max(bounds_end[Z], startpos[Z], endpos[Z])
}