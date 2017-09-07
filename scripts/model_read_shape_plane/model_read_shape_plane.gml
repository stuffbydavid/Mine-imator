/// model_read_shape_plane([bend])
/// @arg [bend]
/// @desc Generates a plane shape, bend is supplied if this is the bended half.

var bend;
if (argument_count > 0)
	bend = argument[0]
else
	bend = false

var x1, x2, z1, z2;
x1 = from[X]; z1 = from[Z]
x2 = to[X];   z2 = to[Z]

// Define texture coordinates to use (clockwise, starting at top-left)
var tex, size;
size = point3D_sub(to, from)

tex[0] = uv
tex[1] = point2D_add(tex[0], point2D(size[X], 0))
tex[2] = point2D_add(tex[0], point2D(size[X], size[Z]))
tex[3] = point2D_add(tex[0], point2D(0, size[Z]))

// Adjust by bending
if (bend_part != null)
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
				
				texoff = point2D(bendoff, 0)
				tex[0] = point2D_add(tex[0], texoff)
				tex[3] = point2D_add(tex[3], texoff)
				break
			}
			
			case e_part.LEFT: // X-
			{
				bendoff = (bend_offset - position[X]) - from[X]
				x1 = -bendoff
				x2 = 0
				
				texoff = point2D(-(size[X] - bendoff), 0)
				tex[1] = point2D_add(tex[1], texoff)
				tex[2] = point2D_add(tex[2], texoff)
				break
			}
			
			case e_part.UPPER: // Z+
			{
				bendoff = (bend_offset - position[Z]) - from[Z]
				z1 = 0
				z2 = size[Z] - bendoff
				
				texoff = point2D(0, -bendoff)
				tex[2] = point2D_add(tex[2], texoff)
				tex[3] = point2D_add(tex[3], texoff)
				break
			}
			
			case e_part.LOWER: // Z-
			{
				bendoff = (bend_offset - position[Z]) - from[Z]
				z1 = -bendoff
				z2 = 0
				
				texoff = point2D(0, (size[Z] - bendoff))
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
				
				texoff = point2D(-(size[X] - bendoff), 0)
				tex[1] = point2D_add(tex[1], texoff)
				tex[2] = point2D_add(tex[2], texoff)
				break
			}
			
			case e_part.LEFT: // X-
			{
				bendoff = (bend_offset - position[X]) - from[X]
				x1 = from[X] + bendoff
				x2 = to[X]
				
				texoff = point2D(bendoff, 0)
				tex[0] = point2D_add(tex[0], texoff)
				tex[3] = point2D_add(tex[3], texoff)
				break
			}
			
			case e_part.UPPER: // Z+
			{
				bendoff = (bend_offset - position[Z]) - from[Z]
				z1 = from[Z]
				z2 = from[Z] + bendoff
				
				texoff = point2D(0, (size[Z] - bendoff))
				tex[0] = point2D_add(tex[0], texoff)
				tex[1] = point2D_add(tex[1], texoff)
				break
			}
			
			case e_part.LOWER: // Z-
			{
				bendoff = (bend_offset - position[Z]) - from[Z]
				z1 = from[Z] + bendoff
				z2 = to[Z]
				
				texoff = point2D(0, -bendoff)
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

vbuffer_add_triangle(p1, p2, p3, tex[0], tex[1], tex[2])
vbuffer_add_triangle(p3, p4, p1, tex[2], tex[3], tex[0])

vbuffer_add_triangle(p2, p1, p3, tex[1], tex[0], tex[2])
vbuffer_add_triangle(p4, p3, p1, tex[3], tex[2], tex[0])