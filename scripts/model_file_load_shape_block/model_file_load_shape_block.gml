/// model_file_load_shape_block([bend])
/// @arg [bend]
/// @desc Generates a block shape, bend is supplied if this is the bent half.

var bend;
if (argument_count > 0)
	bend = argument[0]
else
	bend = false

var x1, x2, y1, y2, z1, z2;
x1 = from[X]; y1 = from[Y];	z1 = from[Z]
x2 = to[X];	  y2 = to[Y];   z2 = to[Z]

// Set to add
var add;
for (var d = 0; d < e_dir.amount; d++)
	add[d] = true
	
// Define texture coordinates to use (clockwise, starting at top-left)
var tex, size, texsize;
size = point3D_sub(to, from)
texsize = point3D_sub(to_noscale, from_noscale)

tex[e_dir.EAST, 0] = point2D_add(uv, point2D(texsize[X], 0))
tex[e_dir.EAST, 1] = point2D_add(tex[e_dir.EAST, 0], point2D(texsize[Y], 0))
tex[e_dir.EAST, 2] = point2D_add(tex[e_dir.EAST, 0], point2D(texsize[Y], texsize[Z]))
tex[e_dir.EAST, 3] = point2D_add(tex[e_dir.EAST, 0], point2D(0, texsize[Z]))

tex[e_dir.WEST, 0] = point2D_sub(uv, point2D(texsize[Y], 0))
tex[e_dir.WEST, 1] = point2D_add(tex[e_dir.WEST, 0], point2D(texsize[Y], 0))
tex[e_dir.WEST, 2] = point2D_add(tex[e_dir.WEST, 0], point2D(texsize[Y], texsize[Z]))
tex[e_dir.WEST, 3] = point2D_add(tex[e_dir.WEST, 0], point2D(0, texsize[Z]))

tex[e_dir.SOUTH, 0] = uv
tex[e_dir.SOUTH, 1] = point2D_add(tex[e_dir.SOUTH, 0], point2D(texsize[X], 0))
tex[e_dir.SOUTH, 2] = point2D_add(tex[e_dir.SOUTH, 0], point2D(texsize[X], texsize[Z]))
tex[e_dir.SOUTH, 3] = point2D_add(tex[e_dir.SOUTH, 0], point2D(0, texsize[Z]))

tex[e_dir.NORTH, 0] = point2D_add(tex[e_dir.EAST, 0], point2D(texsize[Y], 0))
tex[e_dir.NORTH, 1] = point2D_add(tex[e_dir.NORTH, 0], point2D(texsize[X], 0))
tex[e_dir.NORTH, 2] = point2D_add(tex[e_dir.NORTH, 0], point2D(texsize[X], texsize[Z]))
tex[e_dir.NORTH, 3] = point2D_add(tex[e_dir.NORTH, 0], point2D(0, texsize[Z]))

tex[e_dir.UP, 0] = point2D_sub(uv, point2D(0, texsize[Y]))
tex[e_dir.UP, 1] = point2D_add(tex[e_dir.UP, 0], point2D(texsize[X], 0))
tex[e_dir.UP, 2] = point2D_add(tex[e_dir.UP, 0], point2D(texsize[X], texsize[Y]))
tex[e_dir.UP, 3] = point2D_add(tex[e_dir.UP, 0], point2D(0, texsize[Y]))

tex[e_dir.DOWN, 0] = point2D_add(tex[e_dir.UP, 0], point2D(texsize[X], 0))
tex[e_dir.DOWN, 1] = point2D_add(tex[e_dir.DOWN, 0], point2D(0, texsize[Y]))
tex[e_dir.DOWN, 2] = point2D_add(tex[e_dir.DOWN, 0], point2D(texsize[X], texsize[Y]))
tex[e_dir.DOWN, 3] = point2D_add(tex[e_dir.DOWN, 0], point2D(texsize[X], 0))

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
if (bend_part != null && bend_mode = e_shape_bend.BEND)
{
	var bendoff, texoff;
	
	if (bend) // Bent half
	{
		switch (bend_part)
		{
			case e_part.RIGHT: // X+
			{
				add[e_dir.WEST] = false
				bendoff = (bend_offset - position[X]) - from[X]
				x1 = 0
				x2 = size[X] - bendoff
				
				texoff = point2D(bendoff / scale[X], 0)
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
				bendoff = (bend_offset - position[X]) - from[X]
				x1 = -bendoff
				x2 = 0
				
				texoff = point2D(-(texsize[X] - bendoff / scale[X]), 0)
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
				bendoff = (bend_offset - position[Y]) - from[Y]
				y1 = 0
				y2 = size[Y] - bendoff
				
				texoff = point2D(bendoff / scale[Y], 0)
				tex[e_dir.EAST, 1] = point2D_sub(tex[e_dir.EAST, 1], texoff)
				tex[e_dir.EAST, 2] = point2D_sub(tex[e_dir.EAST, 2], texoff)
				tex[e_dir.WEST, 0] = point2D_add(tex[e_dir.WEST, 0], texoff)
				tex[e_dir.WEST, 3] = point2D_add(tex[e_dir.WEST, 3], texoff)
				
				texoff = point2D(0, bendoff / scale[Y])
				tex[e_dir.UP, 0] = point2D_add(tex[e_dir.UP, 0], texoff)
				tex[e_dir.UP, 1] = point2D_add(tex[e_dir.UP, 1], texoff)
				tex[e_dir.DOWN, 0] = point2D_add(tex[e_dir.DOWN, 0], texoff)
				tex[e_dir.DOWN, 3] = point2D_add(tex[e_dir.DOWN, 3], texoff)
				break
			}
			
			case e_part.BACK: // Y-
			{
				add[e_dir.SOUTH] = false
				bendoff = (bend_offset - position[Y]) - from[Y]
				y1 = -bendoff
				y2 = 0
				
				texoff = point2D(-(texsize[Y] - bendoff / scale[Y]), 0)
				tex[e_dir.EAST, 0] = point2D_sub(tex[e_dir.EAST, 0], texoff)
				tex[e_dir.EAST, 3] = point2D_sub(tex[e_dir.EAST, 3], texoff)
				tex[e_dir.WEST, 1] = point2D_add(tex[e_dir.WEST, 1], texoff)
				tex[e_dir.WEST, 2] = point2D_add(tex[e_dir.WEST, 2], texoff)
				
				texoff = point2D(0, -(texsize[Y] - bendoff / scale[Y]))
				tex[e_dir.UP, 2] = point2D_add(tex[e_dir.UP, 2], texoff)
				tex[e_dir.UP, 3] = point2D_add(tex[e_dir.UP, 3], texoff)
				tex[e_dir.DOWN, 1] = point2D_add(tex[e_dir.DOWN, 1], texoff)
				tex[e_dir.DOWN, 2] = point2D_add(tex[e_dir.DOWN, 2], texoff)
				break
			}
			
			case e_part.UPPER: // Z+
			{
				add[e_dir.DOWN] = false
				bendoff = (bend_offset - position[Z]) - from[Z]
				z1 = 0
				z2 = size[Z] - bendoff
				
				texoff = point2D(0, -bendoff / scale[Z])
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
				bendoff = (bend_offset - position[Z]) - from[Z]
				z1 = -bendoff
				z2 = 0
				
				texoff = point2D(0, (texsize[Z] - bendoff / scale[Z]))
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
				bendoff = (bend_offset - position[X]) - from[X]
				x1 = from[X]
				x2 = from[X] + bendoff
				
				texoff = point2D(-(size[X] - bendoff / scale[X]), 0)
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
				bendoff = (bend_offset - position[X]) - from[X]
				x1 = from[X] + bendoff
				x2 = to[X]
				
				texoff = point2D(bendoff / scale[X], 0)
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
				bendoff = (bend_offset - position[Y]) - from[Y]
				y1 = from[Y]
				y2 = from[Y] + bendoff
				
				texoff = point2D(-(texsize[Y] - bendoff / scale[Y]), 0)
				tex[e_dir.EAST, 0] = point2D_sub(tex[e_dir.EAST, 0], texoff)
				tex[e_dir.EAST, 3] = point2D_sub(tex[e_dir.EAST, 3], texoff)
				tex[e_dir.WEST, 1] = point2D_add(tex[e_dir.WEST, 1], texoff)
				tex[e_dir.WEST, 2] = point2D_add(tex[e_dir.WEST, 2], texoff)
				
				texoff = point2D(0, -(texsize[Y] - bendoff / scale[Y]))
				tex[e_dir.UP, 2] = point2D_add(tex[e_dir.UP, 2], texoff)
				tex[e_dir.UP, 3] = point2D_add(tex[e_dir.UP, 3], texoff)
				tex[e_dir.DOWN, 1] = point2D_add(tex[e_dir.DOWN, 1], texoff)
				tex[e_dir.DOWN, 2] = point2D_add(tex[e_dir.DOWN, 2], texoff)
				break
			}
				
			case e_part.BACK: // Y-
			{
				add[e_dir.NORTH] = false
				bendoff = (bend_offset - position[Y]) - from[Y]
				y1 = from[Y] + bendoff
				y2 = to[Y]
				
				texoff = point2D(bendoff / scale[Y], 0)
				tex[e_dir.EAST, 1] = point2D_sub(tex[e_dir.EAST, 1], texoff)
				tex[e_dir.EAST, 2] = point2D_sub(tex[e_dir.EAST, 2], texoff)
				tex[e_dir.WEST, 0] = point2D_add(tex[e_dir.WEST, 0], texoff)
				tex[e_dir.WEST, 3] = point2D_add(tex[e_dir.WEST, 3], texoff)
				
				texoff = point2D(0, bendoff / scale[Y])
				tex[e_dir.UP, 0] = point2D_add(tex[e_dir.UP, 0], texoff)
				tex[e_dir.UP, 1] = point2D_add(tex[e_dir.UP, 1], texoff)
				tex[e_dir.DOWN, 0] = point2D_add(tex[e_dir.DOWN, 0], texoff)
				tex[e_dir.DOWN, 3] = point2D_add(tex[e_dir.DOWN, 3], texoff)
				break
			}
			
			case e_part.UPPER: // Z+
			{
				add[e_dir.UP] = false
				bendoff = (bend_offset - position[Z]) - from[Z]
				z1 = from[Z]
				z2 = from[Z] + bendoff
				
				texoff = point2D(0, (texsize[Z] - bendoff / scale[Z]))
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
				bendoff = (bend_offset - position[Z]) - from[Z]
				z1 = from[Z] + bendoff
				z2 = to[Z]
				
				texoff = point2D(0, -bendoff / scale[Z])
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
		vbuffer_add_triangle(p2, p1, p3, t2, t1, t3, null, color)
		vbuffer_add_triangle(p4, p3, p1, t4, t3, t1, null, color)
	}
	else
	{
		vbuffer_add_triangle(p1, p2, p3, t1, t2, t3, null, color)
		vbuffer_add_triangle(p3, p4, p1, t3, t4, t1, null, color)
	}
}
