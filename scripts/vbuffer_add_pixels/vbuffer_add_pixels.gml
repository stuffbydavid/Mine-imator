/// vbuffer_add_pixels(alphaarray, position, [height, texpos, texsize, texpixelsize, scale, [arrayoff, arraysizeoff, mirror, [color, alpha]]])
/// @arg alphaarray
/// @arg position
/// @arg [height
/// @arg texpos
/// @arg texsize
/// @arg texpixelsize
/// @arg scale
/// @arg [arrposoff
/// @arg arrsizeoff
/// @arg mirror
/// @arg [color
/// @arg alpha]]]

var alphaarr, pos, height, texpos, texsize, texpixelsize, scale, arrposoff, arrsizeoff, mirror, color, alpha, mat;
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
	arrposoff = argument[7]
	arrsizeoff = argument[8]
	mirror = argument[9]
}
else
{
	arrposoff = vec2(0, 0)
	arrsizeoff = vec2(0, 0)
	mirror = false
}

if (argument_count > 10)
{
	color = argument[10]
	alpha = argument[11]
}
else
{
	color = c_white
	alpha = 1
}

mat = matrix_create(pos, vec3(0), scale)

// Sample area of pixels
var samplestartx, samplestarty, sampleendx, sampleendy, samplesizex, samplesizey;
if (!mirror)
{
	samplestartx = texpos[X] + arrposoff[X]
	sampleendx = texpos[X] + arrposoff[X] + texsize[X] + arrsizeoff[X]
}
else
{
	samplestartx = texpos[X] + texsize[X] - (arrposoff[X] + texsize[X] + arrsizeoff[X])
	sampleendx = texpos[X] + texsize[X] - arrposoff[X]
}
samplestarty = texpos[Y] + arrposoff[Y]
sampleendy = texpos[Y] + arrposoff[Y] + texsize[Y] + arrsizeoff[Y]
samplesizex = ceil(sampleendx) - floor(samplestartx)
samplesizey = ceil(sampleendy) - floor(samplestarty)

// Pixel sizes
var sizestartx, sizestarty, sizeendx, sizeendy;
if (!mirror)
{
	sizestartx = 1 - frac(samplestartx)
	sizeendx = frac(sampleendx)
}
else
{
	sizestartx = frac(sampleendx)
	sizeendx = 1 - frac(samplestartx)
}
sizestarty = 1 - frac(samplestarty)
sizeendy = frac(sampleendy)

// Create triangles
var px = 0;
for (var xx = 0; xx < samplesizex; xx++)
{
	// Array X location
	var ax;
	if (!mirror)
		ax = floor(arrposoff[X]) + xx
	else
		ax = ceil(texsize[X] - arrposoff[X]) - 1 - xx
	
	// X size of pixel
	var pxs = 1;
	if (xx = 0 && sizestartx > 0) // First pixel
		pxs = sizestartx
	else if (xx = samplesizex - 1 && sizeendx > 0) // Last pixel
		pxs = sizeendx
	
	var pz = height / scale[Z];
	for (var yy = 0; yy < samplesizey; yy++)
	{
		// Array Z location
		var ay = floor(arrposoff[Y]) + yy;
		
		// Z size of pixel
		var pzs = 1;
		if (yy = 0 && sizestarty > 0) // First pixel
			pzs = sizestarty
		else if (yy = samplesizey - 1 && sizeendy > 0) // Last pixel
			pzs = sizeendy
		
		// Transparent pixel found, continue
		if (alphaarr[@ ax, ay] < 1)
		{
			pz -= pzs
			continue
		}
		
		// Calculate which faces to add, continue if none are visible
		var wface, eface, aface, bface;
		wface = (ax = 0 || alphaarr[@ ax - 1, ay] < 1)
		eface = (ax = ceil(texsize[X]) - 1 || alphaarr[@ ax + 1, ay] < 1)
		aface = (ay = 0 || alphaarr[@ ax, ay - 1] < 1)
		bface = (ay = ceil(texsize[Y]) - 1 || alphaarr[@ ax, ay + 1] < 1)
		
		if (mirror)
		{
			var tmp = wface;
			wface = eface
			eface = tmp
		}
		
		if (!eface && !wface && !aface && !bface)
		{
			pz -= pzs
			continue
		}
		
		// Texture
		var ptex, pfix, psize, t1, t2, t3, t4;
		ptex = point2D(floor(texpos[X]) + ax, floor(texpos[Y]) + ay)
		
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
			vbuffer_add_triangle(p1, p2, p3, t1, t2, t3, null, color, alpha, false, mat)
			vbuffer_add_triangle(p3, p4, p1, t3, t4, t1, null, color, alpha, false, mat)
		}
			
		// West face
		if (wface)
		{
			p1 = point3D(px, 0, pz - pzs)
			p2 = point3D(px, 0, pz)
			p3 = point3D(px, 1, pz)
			p4 = point3D(px, 1, pz - pzs)
			vbuffer_add_triangle(p1, p2, p3, t1, t2, t3, null, color, alpha, false, mat)
			vbuffer_add_triangle(p3, p4, p1, t3, t4, t1, null, color, alpha, false, mat)
		}
			
		// Above face
		if (aface)
		{
			p1 = point3D(px, 1, pz)
			p2 = point3D(px, 0, pz)
			p3 = point3D(px + pxs, 0, pz)
			p4 = point3D(px + pxs, 1, pz)
			vbuffer_add_triangle(p1, p2, p3, t1, t2, t3, null, color, alpha, false, mat)
			vbuffer_add_triangle(p3, p4, p1, t3, t4, t1, null, color, alpha, false, mat)
		}
			
		// Below face
		if (bface)
		{
			p1 = point3D(px, 0, pz - pzs)
			p2 = point3D(px, 1, pz - pzs)
			p3 = point3D(px + pxs, 1, pz - pzs)
			p4 = point3D(px + pxs, 0, pz - pzs)
			vbuffer_add_triangle(p1, p2, p3, t1, t2, t3, null, color, alpha, false, mat)
			vbuffer_add_triangle(p3, p4, p1, t3, t4, t1, null, color, alpha, false, mat)
		}
		
		pz -= pzs
	}
	
	px += pxs
}