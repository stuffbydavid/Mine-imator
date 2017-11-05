/// vbuffer_add_pixels(surface, position, [height, texpos, texsize, texpixelsize, scale, [mirror, [color, alpha]]])
/// @arg surface
/// @arg position
/// @arg [height
/// @arg texpos
/// @arg texsize
/// @arg texpixelsize
/// @arg scale
/// @arg [mirror
/// @arg [color
/// @arg alpha]]]

var surf, pos, height, texpos, texsize, texpixelsize, scale, mirror, color, alpha, mirrorsign, mat;
surf = argument[0]
pos = argument[1]

if (argument_count > 2)
{
	height = argument[2]
	texpos = argument[3]
	texsize = argument[4]
	texpixelsize = argument[5]
	scale = argument[6]
}
else
{
	var wid, hei;
	wid = surface_get_width(surf)
	hei = surface_get_height(surf)
	
	height = hei
	texpos = vec2(0, 0)
	texsize = vec2(wid, hei)
	texpixelsize = vec2_div(vec2(1, 1), texsize)
	scale = vec3(1)
}

if (argument_count > 7)
	mirror = argument[7]
else
	mirror = false

if (argument_count > 8)
{
	color = argument[8]
	alpha = argument[9]
}
else
{
	color = -1
	alpha = 1
}

mirrorsign = negate(mirror)
mat = matrix_create(pos, vec3(0), scale)

if (mirror)
	texpos[X] += texsize[X]
	
var texsizeceil;
texsizeceil[X] = ceil(texsize[X])
texsizeceil[Y] = ceil(texsize[Y])

// Create array with full alpha pixels
buffer_current = buffer_create(texsizeceil[X] * texsizeceil[Y] * 4, buffer_fixed, 4)
buffer_get_surface(buffer_current, surf, 0, 0, 0)
	
var hascolor;
for (var py = 0; py < texsizeceil[Y]; py++)
	for (var px = 0; px < texsizeceil[X]; px++)
		hascolor[px, py] = (buffer_read_int_uns() >> 24 = 255)
	
buffer_delete(buffer_current)

var px = 0;
for (var xx = 0; xx < texsizeceil[X]; xx++)
{
	// X size of pixel
	var pxs = 1;
	if (xx = 0)
		pxs = 1 - frac(texpos[X])
	else if (xx = texsizeceil[X] - 1 && frac(texpos[X] + texsize[X]) > 0)
		pxs = frac(texpos[X] + texsize[X])
		
	var py = 0;
	for (var yy = 0; yy < texsizeceil[Y]; yy++)
	{
		// Z size of pixel
		var pys = 1;
		if (yy = 0)
			pys = 1 - frac(texpos[Y])
		else if (yy = texsizeceil[Y] - 1 && frac(texpos[Y] + texsize[Y]) > 0)
			pys = frac(texpos[Y] + texsize[Y])
		
		// Transparent pixel found, continue
		if (!hascolor[@ xx, yy])
		{
			py += pys
			continue
		}
		
		// Texture
		var ptex, pfix, psize, t1, t2, t3, t4;
		ptex = point2D(floor(texpos[X]) + xx * mirrorsign, floor(texpos[Y]) + yy)
		
		// Artifact fix with CPU rendering
		pfix = 1 / 64 
		psize = 1 - pfix
		
		t1 = ptex
		t2 = point2D(ptex[X] + mirrorsign * psize, ptex[Y])
		t3 = point2D(ptex[X] + mirrorsign * psize, ptex[Y] + psize)
		t4 = point2D(ptex[X], ptex[Y] + psize)
		
		// Conver coordinates to 0-1
		t1 = point2D_mul(t1, texpixelsize)
		t2 = point2D_mul(t2, texpixelsize)
		t3 = point2D_mul(t3, texpixelsize)
		t4 = point2D_mul(t4, texpixelsize)
			
		var p1, p2, p3, p4;
		
		// East
		if (xx = texsizeceil[X] - 1 || !hascolor[@ xx + 1, yy])
		{
			p1 = point3D(px + pxs, 1 + pfix, (height / scale[Z] - pys) - (py - pys))
			p2 = point3D(px + pxs, -pfix, (height / scale[Z] - pys) - (py - pys))
			p3 = point3D(px + pxs, -pfix, (height / scale[Z] - pys) - py)
			p4 = point3D(px + pxs, 1 + pfix, (height / scale[Z] - pys) - py)
			vbuffer_add_triangle(p1, p2, p3, t1, t2, t3, null, color, alpha, mat)
			vbuffer_add_triangle(p3, p4, p1, t3, t4, t1, null, color, alpha, mat)
		}
			
		// West
		if (xx = 0 || !hascolor[@ xx - 1, yy])
		{
			p1 = point3D(px, -pfix, (height / scale[Z] - pys) - (py - pys))
			p2 = point3D(px, 1 + pfix, (height / scale[Z] - pys) - (py - pys))
			p3 = point3D(px, 1 + pfix, (height / scale[Z] - pys)- py)
			p4 = point3D(px, -pfix, (height / scale[Z] - pys) - py)
			vbuffer_add_triangle(p1, p2, p3, t1, t2, t3, null, color, alpha, mat)
			vbuffer_add_triangle(p3, p4, p1, t3, t4, t1, null, color, alpha, mat)
		}
			
		// Up
		if (yy = 0 || !hascolor[@ xx, yy - 1])
		{
			p1 = point3D(px, -pfix, (height / scale[Z] - pys) - (py - pys))
			p2 = point3D(px + pxs, -pfix, (height / scale[Z] - pys) - (py - pys))
			p3 = point3D(px + pxs, 1 + pfix, (height / scale[Z] - pys) - (py - pys))
			p4 = point3D(px, 1 + pfix, (height / scale[Z] - pys) - (py - pys))
			vbuffer_add_triangle(p1, p2, p3, t1, t2, t3, null, color, alpha, mat)
			vbuffer_add_triangle(p3, p4, p1, t3, t4, t1, null, color, alpha, mat)
		}
			
		// Down
		if (yy = texsizeceil[Y] - 1 || !hascolor[@ xx, yy + 1])
		{
			p1 = point3D(px, 1 + pfix, (height / scale[Z] - pys) - py)
			p2 = point3D(px + pxs, 1 + pfix, (height / scale[Z] - pys) - py)
			p3 = point3D(px + pxs, -pfix, (height / scale[Z] - pys) - py)
			p4 = point3D(px, -pfix, (height / scale[Z] - pys) - py)
			vbuffer_add_triangle(p1, p2, p3, t1, t2, t3, null, color, alpha, mat)
			vbuffer_add_triangle(p3, p4, p1, t3, t4, t1, null, color, alpha, mat)
		}
		
		py += pys
	}
	
	px += pxs
}