/// model_shape_generate_plane(angle)
/// @arg angle
/// @desc Generates a plane shape bent by an angle.

var angle = argument0;

var x1, x2, y1, z1, z2, size;
x1 = from[X];	y1 = from[Y];	z1 = from[Z]
x2 = to[X];						z2 = to[Z]
size = point3D_sub(to, from)

// Axis to split up the plane
var segaxis = Z;
if (angle != 0)
{
	if (bend_part = e_part.LEFT || bend_part = e_part.RIGHT)
		segaxis = X
	else if (bend_part = e_part.LOWER || bend_part = e_part.UPPER)
		segaxis = Z
}

// Define texture coordinates to use
var texsize, texuv;
texsize = point3D_sub(to_noscale, from_noscale)

// Convert to 0-1
texsize = vec3(texsize[X] / texture_size[X], texsize[Y] / texture_size[Y], texsize[Z] / texture_size[Y])
texuv = vec2_div(uv, texture_size)

// Plane texture mapping
var tex1, tex2, tex3, tex4;
tex1 = point2D_copy(texuv)
tex2 = point2D_add(tex1, point2D(texsize[X], 0))
tex3 = point2D_add(tex1, point2D(texsize[X], texsize[Z]))
tex4 = point2D_add(tex1, point2D(0, texsize[Z]))

// Mirror texture on X
if (texture_mirror)
{
	// Switch left/right points
	var tmp;
	tmp = tex2; tex2 = tex1; tex1 = tmp;
	tmp = tex3; tex3 = tex4; tex4 = tmp;
}

// Start position and bounds
var detail = 2;
var bendstart, bendend, bendsegsize, invangle;
bendsegsize = bend_size / detail;
invangle = (bend_part = e_part.LOWER || bend_part = e_part.LEFT)

var p1, p2, p3, p4;
var texp1;

if (segaxis = X)
{
	bendstart = (bend_offset - (position[X] + x1)) - bend_size / 2
	bendend = (bend_offset - (position[X] + x1)) + bend_size / 2
	p1 = point3D(x1, y1, z2)
	p2 = point3D(x1, y1, z1)
	texp1 = tex1[X]
}
else if (segaxis = Z)
{
	bendstart = (bend_offset - (position[Z] + z1)) - bend_size / 2
	bendend = (bend_offset - (position[Z] + z1)) + bend_size / 2
	p1 = point3D(x1, y1, z1)
	p2 = point3D(x2, y1, z1)
	texp1 = tex3[Y]
}
	
var mat;
if (angle != 0) // Apply bending transform
{
	// Angle
	var startangle;
	if (bendstart > 0) // Below bend, no angle
		startangle = 0
	else if (bendend < 0) // Above bend, apply full angle
		startangle = angle
	else // Start inside bend, apply partial angle
		startangle = (1 - bendend / bend_size) * angle
	
	mat = model_part_get_bend_matrix(id, test(invangle, (angle - startangle), startangle), vec3(0))
}
else // Apply rotation
	mat = matrix_build(0, 0, 0, rotation[X], rotation[Y], rotation[Z], 1, 1, 1)

p1 = point3D_mul_matrix(p1, mat)
p2 = point3D_mul_matrix(p2, mat)

// Create triangles
vbuffer_start()

vertex_brightness = color_brightness
vertex_wave = wind_wave
vertex_wave_zmin = wind_wave_zmin
vertex_wave_zmax = wind_wave_zmax

var segpos = 0;
while (segpos < size[segaxis])
{
	var segsize, np1, np2, ntexp1, ntexp2, ntexp3;
	
	// Find segment size
	if (angle = 0 || segpos >= bendend) // No/Above bend
		segsize = size[segaxis] - segpos
	else if (segpos < bendstart) // Below bend
		segsize = min(size[segaxis] - segpos, bendstart)
	else // Within bend
	{
		segsize = bendsegsize
		
		if (segpos = 0) // Start inside bend, apply partial size
			segsize -= (from[segaxis] - bendstart) % bendsegsize
		
		segsize = min(size[segaxis] - segpos, segsize)
	}
	
	// Advance
	segpos += segsize
	if (segaxis = X)
	{
		// Right points
		np1 = point3D(x1 + segpos, y1, z2)
		np2 = point3D(x1 + segpos, y1, z1)
		var toff = (segpos / size[X]) * texsize[X] * negate(texture_mirror);
		ntexp1 = tex1[X] + toff
	}
	else if (segaxis = Z)
	{
		// Upper points
		np1 = point3D(x1, y1, z1 + segpos)
		np2 = point3D(x2, y1, z1 + segpos)
		var toff = (segpos / size[Z]) * texsize[Z];
		ntexp1 = tex3[Y] - toff
	}
	
	if (angle != 0) // Apply bending transform
	{
		var segangle;
		if (segpos < bendstart) // Below bend, no angle
			segangle = 0
		else if (segpos >= bendend) // Above bend, apply full angle
			segangle = angle
		else // Inside bend, apply partial angle
			segangle = (1 - (bendend - segpos) / bend_size) * angle
			
		mat = model_part_get_bend_matrix(id, test(invangle, (angle - segangle), segangle), vec3(0))
	}
	else // Apply rotation
		mat = matrix_build(0, 0, 0, rotation[X], rotation[Y], rotation[Z], 1, 1, 1)
	
	np1 = point3D_mul_matrix(np1, mat)
	np2 = point3D_mul_matrix(np2, mat)
	
	// Add faces
	var t1, t2, t3, t4;
	if (segaxis = X)
	{
		t1 = vec2(texp1, tex1[Y])
		t2 = vec2(ntexp1, tex1[Y])
		t3 = vec2(ntexp1, tex3[Y])
		t4 = vec2(texp1, tex3[Y])
		vbuffer_add_triangle(p1, np1, np2, t1, t2, t3, null, color_blend, color_alpha, true)
		vbuffer_add_triangle(np2, p2, p1, t3, t4, t1, null, color_blend, color_alpha, true)
		vbuffer_add_triangle(p1, np1, np2, t1, t2, t3, null, color_blend, color_alpha, false)
		vbuffer_add_triangle(np2, p2, p1, t3, t4, t1, null, color_blend, color_alpha, false)
	}
	else if (segaxis = Z)
	{
		t1 = vec2(tex1[X], ntexp1)
		t2 = vec2(tex2[X], ntexp1)
		t3 = vec2(tex2[X], texp1)
		t4 = vec2(tex1[X], texp1)
		vbuffer_add_triangle(np1, np2, p2, t1, t2, t3, null, color_blend, color_alpha, true)
		vbuffer_add_triangle(p2, p1, np1, t3, t4, t1, null, color_blend, color_alpha, true)
		vbuffer_add_triangle(np1, np2, p2, t1, t2, t3, null, color_blend, color_alpha, false)
		vbuffer_add_triangle(p2, p1, np1, t3, t4, t1, null, color_blend, color_alpha, false)
	}
	
	p1 = np1; p2 = np2;
	texp1 = ntexp1
}

vertex_brightness = 0
vertex_wave = e_vertex_wave.NONE
vertex_wave_zmin = null
vertex_wave_zmax = null

return vbuffer_done()