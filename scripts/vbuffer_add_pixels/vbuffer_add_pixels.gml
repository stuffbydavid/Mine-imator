/// vbuffer_add_pixels(alphaarray, position, [height, texpos, texsize, texpixelsize, scale, [texposoff, texsizeoff, mirror, [color, alpha]]])
/// @arg alphaarray
/// @arg position
/// @arg [height
/// @arg texpos
/// @arg texsize
/// @arg texpixelsize
/// @arg scale
/// @arg [texposoff
/// @arg texsizeoff
/// @arg mirror
/// @arg [color
/// @arg alpha]]]

var alphaarr, pos, height, texpos, texsize, texpixelsize, scale, texposoff, texsizeoff, mirror, color, alpha, mirrorsign, mat;
alphaarr = argument[0]
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
	wid = array_height_2d(alphaarr)
	hei = array_length_2d(alphaarr, 0)
	
	height = hei
	texpos = vec2(0, 0)
	texsize = vec2(wid, hei)
	texpixelsize = vec2_div(vec2(1, 1), texsize)
	scale = vec3(1)
}

if (argument_count > 7)
{
	texposoff = argument[7]
	texsizeoff = argument[8]
	mirror = argument[9]
}
else
{
	texposoff = vec2(0, 0)
	texsizeoff = vec2(0, 0)
	mirror = false
}

if (argument_count > 10)
{
	color = argument[10]
	alpha = argument[11]
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

// Sample area of pixels
var samplesize = vec2(ceil(texsize[X] + texsizeoff[X]), ceil(texsize[Y] + texsizeoff[Y]));
if (samplesize[X] <= 0 || samplesize[Y] <= 0)
	return 0

// Create triangles
var px = 0;
for (var xx = 0; xx < samplesize[X]; xx++)
{
	// X size of pixel
	var pxs = 1;
	if (xx = 0)
		pxs = 1 - frac(texpos[X])
	else if (xx = samplesize[X] - 1 && frac(texpos[X] + texposoff[X] + texsize[X] + texsizeoff[X]) > 0)
		pxs = frac(texpos[X] + texposoff[X] + texsize[X] + texsizeoff[X])
	
	var py = 0;
	for (var yy = 0; yy < samplesize[Y]; yy++)
	{
		// Z size of pixel
		var pys = 1;
		if (yy = 0)
			pys = 1 - frac(texpos[Y])
		else if (yy = samplesize[Y] - 1 && frac(texpos[Y] + texposoff[Y] + texsize[Y] + texsizeoff[Y]) > 0)
			pys = frac(texpos[Y] + texposoff[Y] + texsize[Y] + texsizeoff[Y])
		
		// Array sample position
		var ax, ay;
		ax = floor(texposoff[X]) + xx
		ay = floor(texposoff[Y]) + yy
		
		// Transparent pixel found, continue
		if (alphaarr[@ ax, ay] < 1)
		{
			py += pys
			continue
		}
		
		// Texture
		var ptex, pfix, psize, t1, t2, t3, t4;
		ptex = point2D(floor(texpos[X]) + xx * mirrorsign, floor(texpos[Y]) + yy)
		
		// Artifact fix with CPU rendering
		pfix = 1 / 256 
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
		if (xx = samplesize[X] - 1 || alphaarr[@ ax + 1, ay] < 1)
		{
			p1 = point3D(px + pxs, 1 + pfix, (height / scale[Z] - pys) - (py - pys))
			p2 = point3D(px + pxs, -pfix, (height / scale[Z] - pys) - (py - pys))
			p3 = point3D(px + pxs, -pfix, (height / scale[Z] - pys) - py)
			p4 = point3D(px + pxs, 1 + pfix, (height / scale[Z] - pys) - py)
			vbuffer_add_triangle(p1, p2, p3, t1, t2, t3, null, color, alpha, mat)
			vbuffer_add_triangle(p3, p4, p1, t3, t4, t1, null, color, alpha, mat)
		}
			
		// West
		if (xx = 0 || alphaarr[@ ax - 1, ay] < 1)
		{
			p1 = point3D(px, -pfix, (height / scale[Z] - pys) - (py - pys))
			p2 = point3D(px, 1 + pfix, (height / scale[Z] - pys) - (py - pys))
			p3 = point3D(px, 1 + pfix, (height / scale[Z] - pys)- py)
			p4 = point3D(px, -pfix, (height / scale[Z] - pys) - py)
			vbuffer_add_triangle(p1, p2, p3, t1, t2, t3, null, color, alpha, mat)
			vbuffer_add_triangle(p3, p4, p1, t3, t4, t1, null, color, alpha, mat)
		}
			
		// Up
		if (yy = 0 || alphaarr[@ ax, ay - 1] < 1)
		{
			p1 = point3D(px, -pfix, (height / scale[Z] - pys) - (py - pys))
			p2 = point3D(px + pxs, -pfix, (height / scale[Z] - pys) - (py - pys))
			p3 = point3D(px + pxs, 1 + pfix, (height / scale[Z] - pys) - (py - pys))
			p4 = point3D(px, 1 + pfix, (height / scale[Z] - pys) - (py - pys))
			vbuffer_add_triangle(p1, p2, p3, t1, t2, t3, null, color, alpha, mat)
			vbuffer_add_triangle(p3, p4, p1, t3, t4, t1, null, color, alpha, mat)
		}
			
		// Down
		if (yy = samplesize[Y] - 1 || alphaarr[@ ax, ay + 1] < 1)
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