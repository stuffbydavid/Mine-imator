/// model_file_load_shape_plane([bend])
/// @arg [bend]
/// @desc Generates a plane shape, bend is supplied if this is the bent half.

var bend = false;
if (argument_count > 0)
	bend = argument[0]

var x1, x2, y1, y2, z1, z2;
x1 = from[X];	y1 = from[Y];	z1 = from[Z]
x2 = to[X];		y2 = from[Y];	z2 = to[Z]

if (is3d)
	y2 += scale[Y]

// Define texture coordinates to use (clockwise, starting at top-left)
var tex, size, texsize;
size = point3D_sub(to, from)
texsize = point3D_sub(to_noscale, from_noscale)

tex[0] = uv
tex[1] = point2D_add(tex[0], point2D(texsize[X], 0))
tex[2] = point2D_add(tex[0], point2D(texsize[X], texsize[Z]))
tex[3] = point2D_add(tex[0], point2D(0, texsize[Z]))

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
				tex[0] = point2D_add(tex[0], texoff)
				tex[3] = point2D_add(tex[3], texoff)
				break
			}
			
			case e_part.LEFT: // X-
			{
				bendoff = (bend_offset - position[X]) - from[X]
				x1 = -bendoff
				x2 = 0
				
				texoff = point2D(-(texsize[X] - bendoff / scale[X]), 0)
				tex[1] = point2D_add(tex[1], texoff)
				tex[2] = point2D_add(tex[2], texoff)
				break
			}
			
			case e_part.UPPER: // Z+
			{
				bendoff = (bend_offset - position[Z]) - from[Z]
				z1 = 0
				z2 = size[Z] - bendoff
				
				texoff = point2D(0, -bendoff / scale[Z])
				tex[2] = point2D_add(tex[2], texoff)
				tex[3] = point2D_add(tex[3], texoff)
				break
			}
			
			case e_part.LOWER: // Z-
			{
				bendoff = (bend_offset - position[Z]) - from[Z]
				z1 = -bendoff
				z2 = 0
				
				texoff = point2D(0, (texsize[Z] - bendoff / scale[Z]))
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
				bendoff = (bend_offset - position[X]) - from[X]
				x1 = from[X]
				x2 = from[X] + bendoff
				
				texoff = point2D(-(texsize[X] - bendoff / scale[X]), 0)
				tex[1] = point2D_add(tex[1], texoff)
				tex[2] = point2D_add(tex[2], texoff)
				break
			}
			
			case e_part.LEFT: // X-
			{
				bendoff = (bend_offset - position[X]) - from[X]
				x1 = from[X] + bendoff
				x2 = to[X]
				
				texoff = point2D(bendoff / scale[X], 0)
				tex[0] = point2D_add(tex[0], texoff)
				tex[3] = point2D_add(tex[3], texoff)
				break
			}
			
			case e_part.UPPER: // Z+
			{
				bendoff = (bend_offset - position[Z]) - from[Z]
				z1 = from[Z]
				z2 = from[Z] + bendoff
				
				texoff = point2D(0, (texsize[Z] - bendoff / scale[Z]))
				tex[0] = point2D_add(tex[0], texoff)
				tex[1] = point2D_add(tex[1], texoff)
				break
			}
			
			case e_part.LOWER: // Z-
			{
				bendoff = (bend_offset - position[Z]) - from[Z]
				z1 = from[Z] + bendoff
				z2 = to[Z]
				
				texoff = point2D(0, -bendoff / scale[Z])
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
p1 = point3D(x1, y1, z2)
p2 = point3D(x2, y1, z2)
p3 = point3D(x2, y1, z1)
p4 = point3D(x1, y1, z1)
vbuffer_add_triangle(p2, p1, p3, tex[1], tex[0], tex[2], null, color)
vbuffer_add_triangle(p4, p3, p1, tex[3], tex[2], tex[0], null, color)

p1 = point3D(x1, y2, z2)
p2 = point3D(x2, y2, z2)
p3 = point3D(x2, y2, z1)
p4 = point3D(x1, y2, z1)
vbuffer_add_triangle(p1, p2, p3, tex[0], tex[1], tex[2], null, color)
vbuffer_add_triangle(p3, p4, p1, tex[2], tex[3], tex[0], null, color)