/// vbuffer_add_pixels(alphaarray, position, [height, texpos, texsize, texpixelsize, scale])
/// @arg alphaarray
/// @arg position
/// @arg [height
/// @arg texpos
/// @arg texsize
/// @arg texpixelsize
/// @arg scale]

var alpha, pos, height, texpos, texsize, texpixelsize, scale, mat;
var samplesizex, samplesizey;
alpha = argument[0]
pos = argument[1]

samplesizex = array_height_2d(alpha)
samplesizey = array_length_2d(alpha, 0)

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
	height = samplesizey
	texpos = vec2(0, 0)
	texsize = vec2(samplesizex, samplesizey)
	texpixelsize = vec2_div(vec2(1, 1), texsize)
	scale = vec3(1)
}

mat = matrix_create(pos, vec3(0), scale)

// Pixel sizes
var sizestartx, sizestarty, sizeendx, sizeendy;
sizestartx = 1 - frac(texpos[X])
sizestarty = 1 - frac(texpos[Y])
sizeendx = frac(texpos[X] + texsize[X])
sizeendy = frac(texpos[Y] + texsize[Y])

// Create triangles
var px = 0;
for (var xx = 0; xx < samplesizex; xx++)
{
	// X size of pixel
	var pxs = 1;
	if (xx = 0 && sizestartx > 0) // First pixel
		pxs = sizestartx
	else if (xx = samplesizex - 1 && sizeendx > 0) // Last pixel
		pxs = sizeendx
		
	var pz = height / scale[Z];
	for (var yy = 0; yy < samplesizey; yy++)
	{
		// Z size of pixel
		var pzs = 1;
		if (yy = 0 && sizestarty > 0) // First pixel
			pzs = sizestarty
		else if (yy = samplesizey - 1 && sizeendy > 0) // Last pixel
			pzs = sizeendy
			
		// Transparent pixel found, continue
		if (alpha[@ xx, yy] < 1)
		{
			pz -= pzs
			continue
		}
		
		// Calculate which faces to add, continue if none are visible
		var wface, eface, aface, bface;
		wface = (xx = 0 || alpha[@ xx - 1, yy] < 1)
		eface = (xx = ceil(texsize[X]) - 1 || alpha[@ xx + 1, yy] < 1)
		aface = (yy = 0 || alpha[@ xx, yy - 1] < 1)
		bface = (yy = ceil(texsize[Y]) - 1 || alpha[@ xx, yy + 1] < 1)
		
		if (!eface && !wface && !aface && !bface)
		{
			pz -= pzs
			continue
		}
		
		// Texture
		var ptex, pfix, psize, t1, t2, t3, t4;
		ptex = point2D(floor(texpos[X]) + xx, floor(texpos[Y]) + yy)
		
		// Artifact fix with CPU rendering
		pfix = 1 / 256 
		psize = 1 - pfix
		
		t1 = ptex
		t2 = point2D(ptex[X] + psize, ptex[Y])
		t3 = point2D(ptex[X] + psize, ptex[Y] + psize)
		t4 = point2D(ptex[X], ptex[Y] + psize)
		
		// Conver coordinates to 0-1
		t1 = point2D_mul(t1, texpixelsize)
		t2 = point2D_mul(t2, texpixelsize)
		t3 = point2D_mul(t3, texpixelsize)
		t4 = point2D_mul(t4, texpixelsize)
		
		var p1, p2, p3, p4;
		
		// East face
		if (eface)
		{
			p1 = point3D(px + pxs, 1, pz - pzs)
			p2 = point3D(px + pxs, 1, pz)
			p3 = point3D(px + pxs, 0, pz)
			p4 = point3D(px + pxs, 0, pz - pzs)
			vbuffer_add_triangle(p1, p2, p3, t1, t2, t3, null, null, null, null, null, false, mat)
			vbuffer_add_triangle(p3, p4, p1, t3, t4, t1, null, null, null, null, null, false, mat)
		}
			
		// West face
		if (wface)
		{
			p1 = point3D(px, 0, pz - pzs)
			p2 = point3D(px, 0, pz)
			p3 = point3D(px, 1, pz)
			p4 = point3D(px, 1, pz - pzs)
			vbuffer_add_triangle(p1, p2, p3, t1, t2, t3, null, null, null, null, null, false, mat)
			vbuffer_add_triangle(p3, p4, p1, t3, t4, t1, null, null, null, null, null, false, mat)
		}
			
		// Above face
		if (aface)
		{
			p1 = point3D(px, 1, pz)
			p2 = point3D(px, 0, pz)
			p3 = point3D(px + pxs, 0, pz)
			p4 = point3D(px + pxs, 1, pz)
			vbuffer_add_triangle(p1, p2, p3, t1, t2, t3, null, null, null, null, null, false, mat)
			vbuffer_add_triangle(p3, p4, p1, t3, t4, t1, null, null, null, null, null, false, mat)
		}
			
		// Below face
		if (bface)
		{
			p1 = point3D(px, 0, pz - pzs)
			p2 = point3D(px, 1, pz - pzs)
			p3 = point3D(px + pxs, 1, pz - pzs)
			p4 = point3D(px + pxs, 0, pz - pzs)
			vbuffer_add_triangle(p1, p2, p3, t1, t2, t3, null, null, null, null, null, false, mat)
			vbuffer_add_triangle(p3, p4, p1, t3, t4, t1, null, null, null, null, null, false, mat)
		}
		
		pz -= pzs
	}
	
	px += pxs
}