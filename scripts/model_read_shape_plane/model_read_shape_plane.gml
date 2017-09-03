/// model_read_shape_plane([bend])
/// @arg [bend]
/// @desc Generates a plane shape, bend is supplied if this is the bended half.

var bend, mat, size;
if (argument_count > 0)
	bend = argument[0]
else
	bend = false
mat = vertex_matrix
size = point3D_sub(to, from)

var x1, x2, z1, z2;
x1 = 0;		  z1 = 0
x2 = size[X]; z2 = size[Z]

// Define texture coordinates to use (clockwise, starting at top-left)
var tex;
tex[0] = uv
tex[1] = point2D_add(tex[0], point2D(size[X], 0))
tex[2] = point2D_add(tex[0], point2D(size[X], size[Z]))
tex[3] = point2D_add(tex[0], point2D(0, size[Z]))

// Adjust by bending
if (bend_part != null)
{
	var texoff;
	if (bend) // Bent half
	{
		switch (bend_part)
		{
			case e_part.RIGHT: // X+
			{
				x2 = size[X] - bend_offset + from[X]
				mat = matrix_create(point3D(0, from[Y], from[Z]), vec3(0), scale)
				
				texoff = point2D((bend_offset - from[X]), 0)
				tex[0] = point2D_add(tex[0], texoff)
				tex[3] = point2D_add(tex[3], texoff)
				break
			}
			
			case e_part.LEFT: // X-
			{
				x1 = -(bend_offset - from[X])
				x2 = 0
				mat = matrix_create(point3D(0, from[Y], from[Z]), vec3(0), scale)
				
				texoff = point2D(-(size[X] - bend_offset + from[X]), 0)
				tex[1] = point2D_add(tex[1], texoff)
				tex[2] = point2D_add(tex[2], texoff)
				break
			}
			
			case e_part.UPPER: // Z+
			{
				z2 = size[Z] - bend_offset + from[Z]
				mat = matrix_create(point3D(from[X], from[Y], 0), vec3(0), scale)
				
				texoff = point2D(0, -(bend_offset - from[Z]))
				tex[2] = point2D_add(tex[2], texoff)
				tex[3] = point2D_add(tex[3], texoff)
				break
			}
			
			case e_part.LOWER: // Z-
			{
				z1 = -(bend_offset - from[Z])
				z2 = 0
				mat = matrix_create(point3D(from[X], from[Y], 0), vec3(0), scale)
				
				texoff = point2D(0, (size[Z] - bend_offset + from[Z]))
				tex[0] = point2D_add(tex[0], texoff)
				tex[1] = point2D_add(tex[1], texoff)
				break
			}
		}	
	}
	else
	{
		switch (bend_part)
		{
			case e_part.RIGHT: // X+
			{
				x2 = (bend_offset - from[X]) / scale[X]
				
				texoff = point2D(-(size[X] - bend_offset + from[X]), 0)
				tex[1] = point2D_add(tex[1], texoff)
				tex[2] = point2D_add(tex[2], texoff)
				break
			}
			
			case e_part.LEFT: // X-
			{
				x1 = (bend_offset - from[X]) / scale[X]
				
				texoff = point2D((bend_offset - from[X]), 0)
				tex[0] = point2D_add(tex[0], texoff)
				tex[3] = point2D_add(tex[3], texoff)
				break
			}
			
			case e_part.UPPER: // Z+
			{
				z2 = (bend_offset - from[Z]) / scale[Z]
				
				texoff = point2D(0, (size[Z] - bend_offset + from[Z]))
				tex[0] = point2D_add(tex[0], texoff)
				tex[1] = point2D_add(tex[1], texoff)
				break
			}
			
			case e_part.LOWER: // Z-
			{
				z1 = (bend_offset - from[Z]) / scale[Z]
				
				texoff = point2D(0, -(bend_offset - from[Z]))
				tex[2] = point2D_add(tex[2], texoff)
				tex[3] = point2D_add(tex[3], texoff)
				break
			}
		}
	}
}

// Mirror texture U
if (texture_mirror)
{
	var tmp = tex[0];
	tex[0] = tex[1]
	tex[1] = tmp
	tmp = tex[2]
	tex[2] = tex[3]
	tex[3] = tmp
}

// Transform texture values between 0-1
tex[0] = vec2_div(tex[0], texture_size)
tex[1] = vec2_div(tex[1], texture_size)
tex[2] = vec2_div(tex[2], texture_size)
tex[3] = vec2_div(tex[3], texture_size)

// Create faces
var p1, p2, p3, p4;
p1 = point3D(x1, 0, z2)
p2 = point3D(x2, 0, z2)
p3 = point3D(x2, 0, z1)
p4 = point3D(x1, 0, z1)

vbuffer_add_triangle(p1, p2, p3, tex[0], tex[1], tex[2], null, null, mat)
vbuffer_add_triangle(p3, p4, p1, tex[2], tex[3], tex[0], null, null, mat)

vbuffer_add_triangle(p2, p1, p3, tex[1], tex[0], tex[2], null, null, mat)
vbuffer_add_triangle(p4, p3, p1, tex[3], tex[2], tex[0], null, null, mat)

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