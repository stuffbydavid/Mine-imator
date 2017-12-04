/// model_shape_generate_plane_3d(texture, angle)
/// @arg texture
/// @arg angle
/// @desc Generates a 3D plane shape with the given texture and bent by an angle.

var tex, angle;
tex = argument0
angle = argument1

var x1, x2, y1, y2, z1, z2, size;
x1 = from[X];	y1 = from[Y];			 z1 = from[Z]
x2 = to[X];		y2 = from[Y] + scale[Y]; z2 = to[Z]
size = point3D_sub(to, from)

// Axis to split up the plane
var segouteraxis, seginneraxis;
var arrouteraxis, arrinneraxis;
if (angle != 0)
{
	if (bend_part = e_part.LEFT || bend_part = e_part.RIGHT)
	{
		segouteraxis = X; seginneraxis = Z;
		arrouteraxis = X; arrinneraxis = Y;
	}
	else if (bend_part = e_part.LOWER || bend_part = e_part.UPPER)
	{
		segouteraxis = Z; seginneraxis = X;
		arrouteraxis = Y; arrinneraxis = X;
	}
}
else
{
	segouteraxis = Z; seginneraxis = X;
	arrouteraxis = Y; arrinneraxis = X;
}

// Define texture coordinates to use
var texsize, texuv;
texsize = point3D_sub(to_noscale, from_noscale)

// Generate array with the alpha values of the texture
var surf, alpha, samplesize;
samplesize = vec2(ceil(texsize[X]), ceil(texsize[Y]))
surf = surface_create(samplesize[X], samplesize[Y])
surface_set_target(surf)
{
	draw_clear_alpha(c_black, 0)
	draw_texture_part(tex, 0, 0, uv[X], uv[Y], samplesize[X], samplesize[Y])
}
surface_reset_target()
alpha = surface_get_alpha_array(surf)
surface_free(surf)

// Convert to 0-1
texsize = vec3(texsize[X] / texture_size[X], texsize[Y] / texture_size[Y], texsize[Z] / texture_size[Y])
texuv = vec2_div(uv, texture_size)

// Start position and bounds
var bendstart, bendend, invangle, segangle, mat, nmat;
invangle = (bend_part = e_part.LOWER || bend_part = e_part.LEFT)

if (segouteraxis = X)
{
	bendstart = (bend_offset - (position[X] + x1)) - bend_size / 2
	bendend = (bend_offset - (position[X] + x1)) + bend_size / 2
}
else if (segouteraxis = Z)
{
	bendstart = (bend_offset - (position[Z] + z1)) - bend_size / 2
	bendend = (bend_offset - (position[Z] + z1)) + bend_size / 2
}

// Angle
var segangle, mat, nmat;
if (angle = 0 || bendstart > 0) // No/below bend, no angle
	segangle = 0
else if (bendend < 0) // Above bend, apply full angle
	segangle = angle
else // Start inside bend, apply partial angle
	segangle = (1 - bendend / bend_size) * angle

mat = model_part_get_bend_matrix(id, test(invangle, (angle - segangle), segangle), vec3(0))

// Create triangles
vbuffer_start()

vertex_brightness = color_brightness
vertex_wave = wind_wave
vertex_wave_zmin = wind_wave_zmin
vertex_wave_zmax = wind_wave_zmax
	
var segouterpos, arrouterpos;
segouterpos = 0
arrouterpos = 0
while (arrouterpos < samplesize[arrouteraxis])
{
	var psize = scale[segouteraxis];
	arrouterpos++
	segouterpos += psize

	// Angle
	if (angle = 0 || segouterpos < bendstart) // No/below bend, no angle
		segangle = 0
	else if (segouterpos >= bendend) // Above bend, apply full angle
		segangle = angle
	else // Inside bend, apply partial angle
		segangle = (1 - (bendend - segouterpos) / bend_size) * angle
	
	nmat = model_part_get_bend_matrix(id, test(invangle, (angle - segangle), segangle), vec3(0))
	
	var seginnerpos, arrinnerpos;
	seginnerpos = 0
	arrinnerpos = 0
	while (arrinnerpos < samplesize[arrinneraxis])
	{
		var psize = scale[seginneraxis];
		
		arrinnerpos++
		seginnerpos += psize
		
		var ax, ay;
		if (seginneraxis = X)
		{
			ax = arrinnerpos
			ay = samplesize[Y] - arrouterpos
		}
		else if (seginneraxis = Z)
		{
			ax = arrouterpos
			ay = samplesize[Y] - arrinnerpos
		}
		
		// Transparent pixel found, continue
		if (alpha[@ ax, ay] < 1)
			continue
		
		// Calculate which faces to add, continue if none are visible
		var wface, eface, aface, bface;
		wface = (ax = 0 || alpha[@ ax - 1, ay] < 1)
		eface = (ax = samplesize[X] - 1 || alpha[@ ax + 1, ay] < 1)
		aface = (ay = 0 || alpha[@ ax, ay - 1] < 1)
		bface = (ay = samplesize[Y] - 1 || alpha[@ ax, ay + 1] < 1)
			
		if (!eface && !wface && !aface && !bface)
			continue
			
		// Texture
		var ptex, ptexsize, t1, t2, t3, t4;
		ptex = point2D(texuv[X] + ax / texture_size[X], texuv[Y] + ay / texture_size[Y])
		ptexsize = vec2_div(vec2(1 - 1 / 256), texture_size)
		
		t1 = ptex
		t2 = point2D(ptex[X] + psize, ptex[Y])
		t3 = point2D(ptex[X] + psize, ptex[Y] + psize)
		t4 = point2D(ptex[X], ptex[Y] + psize)
		
		var p1, p2, p3, p4;
		var np1, np2, np3, np4;
		
		if (seginneraxis = X)
		{
			
		}
		else if (seginneraxis = Z)
		{
			
		}
		
		/*// East face
		if (eface)
		{
			p1 = point3D(px + pxs, 1, pz)
			p2 = point3D(px + pxs, 1, pz + pzs)
			p3 = point3D(px + pxs, 0, pz + pzs)
			p4 = point3D(px + pxs, 0, pz)
			vbuffer_add_triangle(p1, p2, p3, t1, t2, t3, null, color_blend, color_alpha, invert)
			vbuffer_add_triangle(p3, p4, p1, t3, t4, t1, null, color_blend, color_alpha, invert)
		}
			
		// West face
		if (wface)
		{
			p1 = point3D(px, 0, pz)
			p2 = point3D(px, 0, pz + pzs)
			p3 = point3D(px, 1, pz + pzs)
			p4 = point3D(px, 1, pz)
			vbuffer_add_triangle(p1, p2, p3, t1, t2, t3, null, color_blend, color_alpha, invert)
			vbuffer_add_triangle(p3, p4, p1, t3, t4, t1, null, color_blend, color_alpha, invert)
		}
			
		// Above face
		if (aface)
		{
			p1 = point3D(px, 1, pz + pzs)
			p2 = point3D(px, 0, pz + pzs)
			p3 = point3D(px + pxs, 0, pz + pzs)
			p4 = point3D(px + pxs, 1, pz + pzs)
			vbuffer_add_triangle(p1, p2, p3, t1, t2, t3, null, color_blend, color_alpha, invert)
			vbuffer_add_triangle(p3, p4, p1, t3, t4, t1, null, color_blend, color_alpha, invert)
		}
			
		// Below face
		if (bface)
		{
			p1 = point3D(px, 0, pz)
			p2 = point3D(px, 1, pz)
			p3 = point3D(px + pxs, 1, pz)
			p4 = point3D(px + pxs, 0, pz)
			vbuffer_add_triangle(p1, p2, p3, t1, t2, t3, null, color_blend, color_alpha, invert)
			vbuffer_add_triangle(p3, p4, p1, t3, t4, t1, null, color_blend, color_alpha, invert)
		}*/
	}
	
	mat = nmat
}

vertex_brightness = 0
vertex_wave = e_vertex_wave.NONE
vertex_wave_zmin = null
vertex_wave_zmax = null

return vbuffer_done()