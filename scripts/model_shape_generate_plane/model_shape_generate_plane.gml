/// model_shape_generate_plane(texture, angle)
/// @arg texture
/// @arg angle
/// @desc Generates a plane shape with the given texture and bent by an angle.

var tex, angle;
tex = argument0
angle = argument1

vbuffer_start()

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

return vbuffer_done()