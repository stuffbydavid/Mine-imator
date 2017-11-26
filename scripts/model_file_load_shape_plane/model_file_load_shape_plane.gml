/// model_file_load_shape_plane([bend])
/// @arg [bend]
/// @desc Generates a plane shape, bend is supplied if this is the bent half.

var bend = false;
if (argument_count > 0)
	bend = argument[0]

var x1, x2, y1, y2, z1, z2;
x1 = from[X];	y1 = from[Y];	z1 = from[Z]
x2 = to[X];		y2 = to[Y];		z2 = to[Z]

// Define texture coordinates to use (clockwise, starting at top-left)
var size, texsize;
var t1, t2, t3, t4;
size = point3D_sub(to, from)
texsize = point3D_sub(to_noscale, from_noscale)

t1 = point2D_copy(uv)
t2 = point2D_add(t1, point2D(texsize[X], 0))
t3 = point2D_add(t1, point2D(texsize[X], texsize[Z]))
t4 = point2D_add(t1, point2D(0, texsize[Z]))

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
				bendoff = (bend_offset - position[X]) - from[X]
				x1 = 0
				x2 = size[X] - bendoff
				
				texoff = point2D(bendoff / scale[X], 0)
				t1 = point2D_add(t1, texoff)
				t4 = point2D_add(t4, texoff)
				break
			}
			
			case e_part.LEFT: // X-
			{
				bendoff = (bend_offset - position[X]) - from[X]
				x1 = -bendoff
				x2 = 0
				
				texoff = point2D(-(texsize[X] - bendoff / scale[X]), 0)
				t2 = point2D_add(t2, texoff)
				t3 = point2D_add(t3, texoff)
				break
			}
			
			case e_part.UPPER: // Z+
			{
				bendoff = (bend_offset - position[Z]) - from[Z]
				z1 = 0
				z2 = size[Z] - bendoff
				
				texoff = point2D(0, -bendoff / scale[Z])
				t3 = point2D_add(t3, texoff)
				t4 = point2D_add(t4, texoff)
				break
			}
			
			case e_part.LOWER: // Z-
			{
				bendoff = (bend_offset - position[Z]) - from[Z]
				z1 = -bendoff
				z2 = 0
				
				texoff = point2D(0, (texsize[Z] - bendoff / scale[Z]))
				t1 = point2D_add(t1, texoff)
				t2 = point2D_add(t2, texoff)
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
				bendoff = (bend_offset - position[X]) - from[X]
				x1 = from[X]
				x2 = from[X] + bendoff
				
				texoff = point2D(-(texsize[X] - bendoff / scale[X]), 0)
				t2 = point2D_add(t2, texoff)
				t3 = point2D_add(t3, texoff)
				break
			}
			
			case e_part.LEFT: // X-
			{
				bendoff = (bend_offset - position[X]) - from[X]
				x1 = from[X] + bendoff
				x2 = to[X]
				
				texoff = point2D(bendoff / scale[X], 0)
				t1 = point2D_add(t1, texoff)
				t4 = point2D_add(t4, texoff)
				break
			}
			
			case e_part.UPPER: // Z+
			{
				bendoff = (bend_offset - position[Z]) - from[Z]
				z1 = from[Z]
				z2 = from[Z] + bendoff
				
				texoff = point2D(0, (texsize[Z] - bendoff / scale[Z]))
				t1 = point2D_add(t1, texoff)
				t2 = point2D_add(t2, texoff)
				break
			}
			
			case e_part.LOWER: // Z-
			{
				bendoff = (bend_offset - position[Z]) - from[Z]
				z1 = from[Z] + bendoff
				z2 = to[Z]
				
				texoff = point2D(0, -bendoff / scale[Z])
				t3 = point2D_add(t3, texoff)
				t4 = point2D_add(t4, texoff)
				break
			}
		}
	}
}

// Mirror texture U
if (texture_mirror)
{
	t1[X] = (texsize[X] - (t1[X] - uv[X])) + uv[X]
	t2[X] = (texsize[X] - (t2[X] - uv[X])) + uv[X]
	t3[X] = (texsize[X] - (t3[X] - uv[X])) + uv[X]
	t4[X] = (texsize[X] - (t4[X] - uv[X])) + uv[X]
}

// Transform texture values between 0-1
t1 = vec2_div(t1, texture_size)
t2 = vec2_div(t2, texture_size)
t3 = vec2_div(t3, texture_size)
t4 = vec2_div(t4, texture_size)

// Create faces
var p1, p2, p3, p4;
p1 = point3D(x1, y1, z2)
p2 = point3D(x2, y1, z2)
p3 = point3D(x2, y1, z1)
p4 = point3D(x1, y1, z1)
vbuffer_add_triangle(p1, p2, p3, t1, t2, t3, null, color_blend, color_alpha, true)
vbuffer_add_triangle(p3, p4, p1, t3, t4, t1, null, color_blend, color_alpha, true)

p1 = point3D(x1, y2, z2)
p2 = point3D(x2, y2, z2)
p3 = point3D(x2, y2, z1)
p4 = point3D(x1, y2, z1)
vbuffer_add_triangle(p1, p2, p3, t1, t2, t3, null, color_blend, color_alpha, false)
vbuffer_add_triangle(p3, p4, p1, t3, t4, t1, null, color_blend, color_alpha, false)