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
	
texsize[X] = ceil(texsize[X])
texsize[Y] = ceil(texsize[Y])

// Create array with full alpha pixels
buffer_current = buffer_create(texsize[X] * texsize[Y] * 4, buffer_fixed, 4)
buffer_get_surface(buffer_current, surf, 0, 0, 0)
	
var hascolor;
for (var py = 0; py < texsize[Y]; py++)
	for (var px = 0; px < texsize[X]; px++)
		hascolor[px, py] = (buffer_read_int_uns() >> 24 = 255)
	
buffer_delete(buffer_current)

var px = 0;
for (var xx = 0; xx < texsize[X]; xx++)
{
	// X size of pixel TODO
	var pxs = 1;
	//if (xx = 0)
	//	pxs = 1 - frac(texpos[X])
	//else if (xx = texsize[X] - 1)
	//	pxs = frac(texpos[X] + texsize[X])
		
	var py = 0;
	for (var yy = 0; yy < texsize[Y]; yy++)
	{
		if (!hascolor[@ xx, yy]) 
			continue
				
		// Z size of pixel
		var pys = 1;
		
		// Texture
		var ptex, t1, t2, t3, t4;
		ptex = point2D((texpos[X] + xx * mirrorsign) * texpixelsize[X], (texpos[Y] + yy) * texpixelsize[Y])
		t1 = ptex
		t2 = point2D(ptex[X] + texpixelsize[X] * mirrorsign, ptex[Y])
		t3 = point2D(ptex[X] + texpixelsize[X] * mirrorsign, ptex[Y] + texpixelsize[Y])
		t4 = point2D(ptex[X], ptex[Y] + texpixelsize[Y])
			
		var p1, p2, p3, p4;
		
		// East
		if (xx = texsize[X] - 1 || !hascolor[@ xx + 1, yy])
		{
			p1 = point3D(xx + 1, 1, (height / scale[Z] - 1) - (yy - 1))
			p2 = point3D(xx + 1, 0, (height / scale[Z] - 1) - (yy - 1))
			p3 = point3D(xx + 1, 0, (height / scale[Z] - 1) - yy)
			p4 = point3D(xx + 1, 1, (height / scale[Z] - 1) - yy)
			vbuffer_add_triangle(p1, p2, p3, t1, t2, t3, null, color, alpha, mat)
			vbuffer_add_triangle(p3, p4, p1, t3, t4, t1, null, color, alpha, mat)
		}
			
		// West
		if (xx = 0 || !hascolor[@ xx - 1, yy])
		{
			p1 = point3D(xx, 0, (height / scale[Z] - 1) - (yy - 1))
			p2 = point3D(xx, 1, (height / scale[Z] - 1) - (yy - 1))
			p3 = point3D(xx, 1, (height / scale[Z] - 1) - yy)
			p4 = point3D(xx, 0, (height / scale[Z] - 1) - yy)
			vbuffer_add_triangle(p1, p2, p3, t1, t2, t3, null, color, alpha, mat)
			vbuffer_add_triangle(p3, p4, p1, t3, t4, t1, null, color, alpha, mat)
		}
			
		// Up
		if (yy = 0 || !hascolor[@ xx, yy - 1])
		{
			p1 = point3D(xx, 0, (height / scale[Z] - 1) - (yy - 1))
			p2 = point3D(xx + 1, 0, (height / scale[Z] - 1) - (yy - 1))
			p3 = point3D(xx + 1, 1, (height / scale[Z] - 1) - (yy - 1))
			p4 = point3D(xx, 1, (height / scale[Z] - 1) - (yy - 1))
			vbuffer_add_triangle(p1, p2, p3, t1, t2, t3, null, color, alpha, mat)
			vbuffer_add_triangle(p3, p4, p1, t3, t4, t1, null, color, alpha, mat)
		}
			
		// Down
		if (yy = texsize[Y] - 1 || !hascolor[@ xx, yy + 1])
		{
			p1 = point3D(xx, 1, (height / scale[Z] - 1) - yy)
			p2 = point3D(xx + 1, 1, (height / scale[Z] - 1) - yy)
			p3 = point3D(xx + 1, 0, (height / scale[Z] - 1) - yy)
			p4 = point3D(xx, 0, (height / scale[Z] - 1) - yy)
			vbuffer_add_triangle(p1, p2, p3, t1, t2, t3, null, color, alpha, mat)
			vbuffer_add_triangle(p3, p4, p1, t3, t4, t1, null, color, alpha, mat)
		}
		
		py += pys
	}
	
	px += pxs
}