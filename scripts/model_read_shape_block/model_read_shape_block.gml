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
x1 = 0;		  y1 = 0;		z1 = 0
x2 = size[X]; y2 = size[Y]; z2 = size[Z]

// Set to add
var add;
for (var d = 0; d < e_dir.amount; d++)
	add[d] = true
	
// Define texture coordinates to use (clockwise, starting at top-left)
var tex;
tex[e_dir.EAST, 0] = point2D_add(uv, point2D(size[X], 0))
tex[e_dir.EAST, 1] = point2D_add(tex[e_dir.EAST, 0], point2D(size[Y], 0))
tex[e_dir.EAST, 2] = point2D_add(tex[e_dir.EAST, 0], point2D(size[Y], size[Z]))
tex[e_dir.EAST, 3] = point2D_add(tex[e_dir.EAST, 0], point2D(0, size[Z]))

tex[e_dir.WEST, 0] = point2D_sub(uv, point2D(size[Y], 0))
tex[e_dir.WEST, 1] = point2D_add(tex[e_dir.WEST, 0], point2D(size[Y], 0))
tex[e_dir.WEST, 2] = point2D_add(tex[e_dir.WEST, 0], point2D(size[Y], size[Z]))
tex[e_dir.WEST, 3] = point2D_add(tex[e_dir.WEST, 0], point2D(0, size[Z]))

tex[e_dir.SOUTH, 0] = uv
tex[e_dir.SOUTH, 1] = point2D_add(tex[e_dir.SOUTH, 0], point2D(size[X], 0))
tex[e_dir.SOUTH, 2] = point2D_add(tex[e_dir.SOUTH, 0], point2D(size[X], size[Z]))
tex[e_dir.SOUTH, 3] = point2D_add(tex[e_dir.SOUTH, 0], point2D(0, size[Z]))

tex[e_dir.NORTH, 0] = point2D_add(tex[e_dir.EAST, 0], point2D(size[Y], 0))
tex[e_dir.NORTH, 1] = point2D_add(tex[e_dir.NORTH, 0], point2D(size[X], 0))
tex[e_dir.NORTH, 2] = point2D_add(tex[e_dir.NORTH, 0], point2D(size[X], size[Z]))
tex[e_dir.NORTH, 3] = point2D_add(tex[e_dir.NORTH, 0], point2D(0, size[Z]))

tex[e_dir.UP, 0] = point2D_sub(uv, point2D(0, size[Y]))
tex[e_dir.UP, 1] = point2D_add(tex[e_dir.UP, 0], point2D(size[X], 0))
tex[e_dir.UP, 2] = point2D_add(tex[e_dir.UP, 0], point2D(size[X], size[Y]))
tex[e_dir.UP, 3] = point2D_add(tex[e_dir.UP, 0], point2D(0, size[Y]))

tex[e_dir.DOWN, 0] = point2D_add(tex[e_dir.UP, 0], point2D(size[X], 0))
tex[e_dir.DOWN, 1] = point2D_add(tex[e_dir.DOWN, 0], point2D(0, size[Y]))
tex[e_dir.DOWN, 2] = point2D_add(tex[e_dir.DOWN, 0], point2D(size[X], size[Y]))
tex[e_dir.DOWN, 3] = point2D_add(tex[e_dir.DOWN, 0], point2D(size[X], 0))

// Flip east/west sides if mirrored
if (texture_mirror)
{
	for (var t = 0; t < 4; t++)
	{
		var tmp = tex[e_dir.EAST, t]
		tex[e_dir.EAST, t] = tex[e_dir.WEST, t]
		tex[e_dir.WEST, t] = tmp
	}
}

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
				add[e_dir.WEST] = false
				x2 = size[X] - bend_offset + from[X]
				mat = matrix_create(point3D(0, from[Y], from[Z]), vec3(0), scale)
				
				texoff = point2D((bend_offset - from[X]), 0)
				tex[e_dir.SOUTH, 0] = point2D_add(tex[e_dir.SOUTH, 0], texoff)
				tex[e_dir.SOUTH, 3] = point2D_add(tex[e_dir.SOUTH, 3], texoff)
				tex[e_dir.NORTH, 1] = point2D_sub(tex[e_dir.NORTH, 1], texoff)
				tex[e_dir.NORTH, 2] = point2D_sub(tex[e_dir.NORTH, 2], texoff)
				tex[e_dir.UP, 0] = point2D_add(tex[e_dir.UP, 0], texoff)
				tex[e_dir.UP, 3] = point2D_add(tex[e_dir.UP, 3], texoff)
				tex[e_dir.DOWN, 0] = point2D_add(tex[e_dir.DOWN, 0], texoff)
				tex[e_dir.DOWN, 1] = point2D_add(tex[e_dir.DOWN, 1], texoff)
				break
			}
			
			case e_part.LEFT: // X-
			{
				add[e_dir.EAST] = false
				x2 = 0
				x1 = -(bend_offset - from[X])
				mat = matrix_create(point3D(0, from[Y], from[Z]), vec3(0), scale)
				
				texoff = point2D(-(size[X] - bend_offset + from[X]), 0)
				tex[e_dir.SOUTH, 1] = point2D_add(tex[e_dir.SOUTH, 1], texoff)
				tex[e_dir.SOUTH, 2] = point2D_add(tex[e_dir.SOUTH, 2], texoff)
				tex[e_dir.NORTH, 0] = point2D_sub(tex[e_dir.NORTH, 0], texoff)
				tex[e_dir.NORTH, 3] = point2D_sub(tex[e_dir.NORTH, 3], texoff)
				tex[e_dir.UP, 1] = point2D_add(tex[e_dir.UP, 1], texoff)
				tex[e_dir.UP, 2] = point2D_add(tex[e_dir.UP, 2], texoff)
				tex[e_dir.DOWN, 2] = point2D_add(tex[e_dir.DOWN, 2], texoff)
				tex[e_dir.DOWN, 3] = point2D_add(tex[e_dir.DOWN, 3], texoff)
				break
			}
			
			case e_part.FRONT: // Y+
			{
				add[e_dir.NORTH] = false
				y2 = size[Y] - bend_offset + from[Y]
				mat = matrix_create(point3D(from[X], 0, from[Z]), vec3(0), scale)
				
				texoff = point2D((bend_offset - from[Y]), 0)
				tex[e_dir.EAST, 1] = point2D_sub(tex[e_dir.EAST, 1], texoff)
				tex[e_dir.EAST, 2] = point2D_sub(tex[e_dir.EAST, 2], texoff)
				tex[e_dir.WEST, 0] = point2D_add(tex[e_dir.WEST, 0], texoff)
				tex[e_dir.WEST, 3] = point2D_add(tex[e_dir.WEST, 3], texoff)
				
				texoff = point2D(0, (bend_offset - from[Y]))
				tex[e_dir.UP, 0] = point2D_add(tex[e_dir.UP, 0], texoff)
				tex[e_dir.UP, 1] = point2D_add(tex[e_dir.UP, 1], texoff)
				tex[e_dir.DOWN, 0] = point2D_add(tex[e_dir.DOWN, 0], texoff)
				tex[e_dir.DOWN, 3] = point2D_add(tex[e_dir.DOWN, 3], texoff)
				break
			}
			
			case e_part.BACK: // Y-
			{
				add[e_dir.SOUTH] = false
				y2 = 0
				y1 = -(bend_offset - from[Y])
				mat = matrix_create(point3D(from[X], 0, from[Z]), vec3(0), scale)
				
				texoff = point2D(-(size[Y] - bend_offset + from[Y]), 0)
				tex[e_dir.EAST, 0] = point2D_sub(tex[e_dir.EAST, 0], texoff)
				tex[e_dir.EAST, 3] = point2D_sub(tex[e_dir.EAST, 3], texoff)
				tex[e_dir.WEST, 1] = point2D_add(tex[e_dir.WEST, 1], texoff)
				tex[e_dir.WEST, 2] = point2D_add(tex[e_dir.WEST, 2], texoff)
				
				texoff = point2D(0, -(size[Y] - bend_offset + from[Y]))
				tex[e_dir.UP, 2] = point2D_add(tex[e_dir.UP, 2], texoff)
				tex[e_dir.UP, 3] = point2D_add(tex[e_dir.UP, 3], texoff)
				tex[e_dir.DOWN, 1] = point2D_add(tex[e_dir.DOWN, 1], texoff)
				tex[e_dir.DOWN, 2] = point2D_add(tex[e_dir.DOWN, 2], texoff)
				break
			}
			
			case e_part.UPPER: // Z+
			{
				add[e_dir.DOWN] = false
				z2 = size[Z] - bend_offset + from[Z]
				mat = matrix_create(point3D(from[X], from[Y], 0), vec3(0), scale)
				
				texoff = point2D(0, -(bend_offset - from[Z]))
				tex[e_dir.EAST, 2] = point2D_add(tex[e_dir.EAST, 2], texoff)
				tex[e_dir.EAST, 3] = point2D_add(tex[e_dir.EAST, 3], texoff)
				tex[e_dir.WEST, 2] = point2D_add(tex[e_dir.WEST, 2], texoff)
				tex[e_dir.WEST, 3] = point2D_add(tex[e_dir.WEST, 3], texoff)
				tex[e_dir.SOUTH, 2] = point2D_add(tex[e_dir.SOUTH, 2], texoff)
				tex[e_dir.SOUTH, 3] = point2D_add(tex[e_dir.SOUTH, 3], texoff)
				tex[e_dir.NORTH, 2] = point2D_add(tex[e_dir.NORTH, 2], texoff)
				tex[e_dir.NORTH, 3] = point2D_add(tex[e_dir.NORTH, 3], texoff)
				break
			}
			
			case e_part.LOWER: // Z-
			{
				add[e_dir.UP] = false
				z2 = 0
				z1 = -(bend_offset - from[Z])
				mat = matrix_create(point3D(from[X], from[Y], 0), vec3(0), scale)
				
				texoff = point2D(0, (size[Z] - bend_offset + from[Z]))
				tex[e_dir.EAST, 0] = point2D_add(tex[e_dir.EAST, 0], texoff)
				tex[e_dir.EAST, 1] = point2D_add(tex[e_dir.EAST, 1], texoff)
				tex[e_dir.WEST, 0] = point2D_add(tex[e_dir.WEST, 0], texoff)
				tex[e_dir.WEST, 1] = point2D_add(tex[e_dir.WEST, 1], texoff)
				tex[e_dir.SOUTH, 0] = point2D_add(tex[e_dir.SOUTH, 0], texoff)
				tex[e_dir.SOUTH, 1] = point2D_add(tex[e_dir.SOUTH, 1], texoff)
				tex[e_dir.NORTH, 0] = point2D_add(tex[e_dir.NORTH, 0], texoff)
				tex[e_dir.NORTH, 1] = point2D_add(tex[e_dir.NORTH, 1], texoff)
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
				add[e_dir.EAST] = false
				x2 = (bend_offset - from[X]) / scale[X]
				
				texoff = point2D(-(size[X] - bend_offset + from[X]), 0)
				tex[e_dir.SOUTH, 1] = point2D_add(tex[e_dir.SOUTH, 1], texoff)
				tex[e_dir.SOUTH, 2] = point2D_add(tex[e_dir.SOUTH, 2], texoff)
				tex[e_dir.NORTH, 0] = point2D_sub(tex[e_dir.NORTH, 0], texoff)
				tex[e_dir.NORTH, 3] = point2D_sub(tex[e_dir.NORTH, 3], texoff)
				tex[e_dir.UP, 1] = point2D_add(tex[e_dir.UP, 1], texoff)
				tex[e_dir.UP, 2] = point2D_add(tex[e_dir.UP, 2], texoff)
				tex[e_dir.DOWN, 2] = point2D_add(tex[e_dir.DOWN, 2], texoff)
				tex[e_dir.DOWN, 3] = point2D_add(tex[e_dir.DOWN, 3], texoff)
				break
			}
				
			case e_part.LEFT: // X-
			{
				add[e_dir.WEST] = false
				x1 = (bend_offset - from[X]) / scale[X]
				
				texoff = point2D((bend_offset - from[X]), 0)
				tex[e_dir.SOUTH, 0] = point2D_add(tex[e_dir.SOUTH, 0], texoff)
				tex[e_dir.SOUTH, 3] = point2D_add(tex[e_dir.SOUTH, 3], texoff)
				tex[e_dir.NORTH, 1] = point2D_sub(tex[e_dir.NORTH, 1], texoff)
				tex[e_dir.NORTH, 2] = point2D_sub(tex[e_dir.NORTH, 2], texoff)
				tex[e_dir.UP, 0] = point2D_add(tex[e_dir.UP, 0], texoff)
				tex[e_dir.UP, 3] = point2D_add(tex[e_dir.UP, 3], texoff)
				tex[e_dir.DOWN, 0] = point2D_add(tex[e_dir.DOWN, 0], texoff)
				tex[e_dir.DOWN, 1] = point2D_add(tex[e_dir.DOWN, 1], texoff)
				break
			}
			
			case e_part.FRONT: // Y+
			{
				add[e_dir.SOUTH] = false
				y2 = (bend_offset - from[Y]) / scale[Y]
				
				texoff = point2D(-(size[Y] - bend_offset + from[Y]), 0)
				tex[e_dir.EAST, 0] = point2D_sub(tex[e_dir.EAST, 0], texoff)
				tex[e_dir.EAST, 3] = point2D_sub(tex[e_dir.EAST, 3], texoff)
				tex[e_dir.WEST, 1] = point2D_add(tex[e_dir.WEST, 1], texoff)
				tex[e_dir.WEST, 2] = point2D_add(tex[e_dir.WEST, 2], texoff)
				
				texoff = point2D(0, -(size[Y] - bend_offset + from[Y]))
				tex[e_dir.UP, 2] = point2D_add(tex[e_dir.UP, 2], texoff)
				tex[e_dir.UP, 3] = point2D_add(tex[e_dir.UP, 3], texoff)
				tex[e_dir.DOWN, 1] = point2D_add(tex[e_dir.DOWN, 1], texoff)
				tex[e_dir.DOWN, 2] = point2D_add(tex[e_dir.DOWN, 2], texoff)
				break
			}
				
			case e_part.BACK: // Y-
			{
				add[e_dir.NORTH] = false
				y1 = (bend_offset - from[Y]) / scale[Y]
				
				texoff = point2D((bend_offset - from[Y]), 0)
				tex[e_dir.EAST, 1] = point2D_sub(tex[e_dir.EAST, 1], texoff)
				tex[e_dir.EAST, 2] = point2D_sub(tex[e_dir.EAST, 2], texoff)
				tex[e_dir.WEST, 0] = point2D_add(tex[e_dir.WEST, 0], texoff)
				tex[e_dir.WEST, 3] = point2D_add(tex[e_dir.WEST, 3], texoff)
				
				texoff = point2D(0, (bend_offset - from[Y]))
				tex[e_dir.UP, 0] = point2D_add(tex[e_dir.UP, 0], texoff)
				tex[e_dir.UP, 1] = point2D_add(tex[e_dir.UP, 1], texoff)
				tex[e_dir.DOWN, 0] = point2D_add(tex[e_dir.DOWN, 0], texoff)
				tex[e_dir.DOWN, 3] = point2D_add(tex[e_dir.DOWN, 3], texoff)
				break
			}
			
			case e_part.UPPER: // Z+
			{
				add[e_dir.UP] = false
				z2 = (bend_offset - from[Z]) / scale[Z]
				
				texoff = point2D(0, (size[Z] - bend_offset + from[Z]))
				tex[e_dir.EAST, 0] = point2D_add(tex[e_dir.EAST, 0], texoff)
				tex[e_dir.EAST, 1] = point2D_add(tex[e_dir.EAST, 1], texoff)
				tex[e_dir.WEST, 0] = point2D_add(tex[e_dir.WEST, 0], texoff)
				tex[e_dir.WEST, 1] = point2D_add(tex[e_dir.WEST, 1], texoff)
				tex[e_dir.SOUTH, 0] = point2D_add(tex[e_dir.SOUTH, 0], texoff)
				tex[e_dir.SOUTH, 1] = point2D_add(tex[e_dir.SOUTH, 1], texoff)
				tex[e_dir.NORTH, 0] = point2D_add(tex[e_dir.NORTH, 0], texoff)
				tex[e_dir.NORTH, 1] = point2D_add(tex[e_dir.NORTH, 1], texoff)
				break
			}
				
			case e_part.LOWER: // Z-
			{
				add[e_dir.DOWN] = false
				z1 = (bend_offset - from[Z]) / scale[Z]
				
				texoff = point2D(0, -(bend_offset - from[Z]))
				tex[e_dir.EAST, 2] = point2D_add(tex[e_dir.EAST, 2], texoff)
				tex[e_dir.EAST, 3] = point2D_add(tex[e_dir.EAST, 3], texoff)
				tex[e_dir.WEST, 2] = point2D_add(tex[e_dir.WEST, 2], texoff)
				tex[e_dir.WEST, 3] = point2D_add(tex[e_dir.WEST, 3], texoff)
				tex[e_dir.SOUTH, 2] = point2D_add(tex[e_dir.SOUTH, 2], texoff)
				tex[e_dir.SOUTH, 3] = point2D_add(tex[e_dir.SOUTH, 3], texoff)
				tex[e_dir.NORTH, 2] = point2D_add(tex[e_dir.NORTH, 2], texoff)
				tex[e_dir.NORTH, 3] = point2D_add(tex[e_dir.NORTH, 3], texoff)
				break
			}
		}
	}
}

// Create faces
for (var d = 0; d < e_dir.amount; d++)
{
	if (!add[d])
		continue
	
	var p1, p2, p3, p4;
	var t1, t2, t3, t4;
		
	// Mirror texture U
	if (texture_mirror)
	{
		t1 = tex[d, 1]
		t2 = tex[d, 0]
		t3 = tex[d, 3]
		t4 = tex[d, 2]
	}
	else
	{
		t1 = tex[d, 0]
		t2 = tex[d, 1]
		t3 = tex[d, 2]
		t4 = tex[d, 3]
	}
	
	// Transform texture values between 0-1
	t1 = vec2_div(t1, texture_size)
	t2 = vec2_div(t2, texture_size)
	t3 = vec2_div(t3, texture_size)
	t4 = vec2_div(t4, texture_size)
	
	// Set vertices
	switch (d)
	{
		case e_dir.EAST:
		{
			p1 = point3D(x2, y2, z2)
			p2 = point3D(x2, y1, z2) 
			p3 = point3D(x2, y1, z1)
			p4 = point3D(x2, y2, z1)
			break
		}
		
		case e_dir.WEST:
		{
			p1 = point3D(x1, y1, z2)
			p2 = point3D(x1, y2, z2)
			p3 = point3D(x1, y2, z1)
			p4 = point3D(x1, y1, z1)
			break
		}
		
		case e_dir.SOUTH:
		{
			p1 = point3D(x1, y2, z2)
			p2 = point3D(x2, y2, z2)
			p3 = point3D(x2, y2, z1)
			p4 = point3D(x1, y2, z1)
			break
		}
		
		case e_dir.NORTH:
		{
			p1 = point3D(x2, y1, z2)
			p2 = point3D(x1, y1, z2)
			p3 = point3D(x1, y1, z1)
			p4 = point3D(x2, y1, z1)
			break
		}
		
		case e_dir.UP:
		{
			p1 = point3D(x1, y1, z2)
			p2 = point3D(x2, y1, z2)
			p3 = point3D(x2, y2, z2)
			p4 = point3D(x1, y2, z2)
			break
		}
		
		case e_dir.DOWN:
		{
			p1 = point3D(x1, y1, z1)
			p2 = point3D(x1, y2, z1)
			p3 = point3D(x2, y2, z1)
			p4 = point3D(x2, y1, z1)
			break
		}
	}
	
	if (invert)
	{
		vbuffer_add_triangle(p2, p1, p3, t2, t1, t3, null, null, mat)
		vbuffer_add_triangle(p4, p3, p1, t4, t3, t1, null, null, mat)
	}
	else
	{
		vbuffer_add_triangle(p1, p2, p3, t1, t2, t3, null, null, mat)
		vbuffer_add_triangle(p3, p4, p1, t3, t4, t1, null, null, mat)
	}
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