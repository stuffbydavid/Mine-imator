/// vbuffer_add_pixels(surface, position, [height, texpos, texsize, texpixelsize, scale, [mirror, [color]]])
/// @arg surface
/// @arg position
/// @arg [height
/// @arg texpos
/// @arg texsize
/// @arg texpixelsize
/// @arg scale
/// @arg [mirror
/// @arg [blendcolor]]]

var surf, pos, height, texpos, texsize, texpixelsize, scale, mirror, color, mirrorsign, mat;
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
	color = argument[8]
else
	color = c_white

mirrorsign = negate(mirror)
mat = matrix_create(pos, vec3(0), scale)


log(is_array(mat))

if (mirror)
	texpos[X] += texsize[X]

// Quick method: Creates rows and columns of triangles with the texture, instead of
// going through pixel-by-pixel. Speeds up generation but looks bad with aliased textures
var QUICK = false;
if (QUICK)
{
	var p1, p2, p3, p4;
	var t1, t2, t3, t4;
		
	// X
	for (var xx = 0; xx < texsize[X]; xx++)
	{
		t1 = point2D((texpos[X] + xx * mirrorsign) * texpixelsize[X], texpos[Y] * texpixelsize[Y])
		t2 = point2D_add(t1, point2D(texpixelsize[X] * mirrorsign, 0))
		t3 = point2D_add(t1, point2D(texpixelsize[X] * mirrorsign, texsize[Y] * texpixelsize[Y]))
		t4 = point2D_add(t1, point2D(0, texsize[Y] * texpixelsize[Y]))
		
		// X- face
		p1 = point3D(xx, 0, height)
		p2 = point3D_add(p1, point3D(0, 1, 0))
		p3 = point3D_add(p1, point3D(0, 1, -height))
		p4 = point3D_add(p1, point3D(0, 0, -height))
		vbuffer_add_triangle(p1, p2, p3, t1, t2, t3, null, color, mat)
		vbuffer_add_triangle(p3, p4, p1, t3, t4, t1, null, color, mat)
		
		// X+ face
		p1 = point3D_add(p1, point3D(1, 0, 0))
		p2 = point3D_add(p2, point3D(1, 0, 0))
		p3 = point3D_add(p3, point3D(1, 0, 0))
		p4 = point3D_add(p4, point3D(1, 0, 0))
		vbuffer_add_triangle(p2, p1, p3, t2, t1, t3, null, color, mat)
		vbuffer_add_triangle(p4, p3, p1, t4, t3, t1, null, color, mat)
	}
	
	// Y
	for (var yy = 0; yy < texsize[Y]; yy++)
	{
		t1 = point2D(texpos[X] * texpixelsize[X], (texpos[Y] + yy) * texpixelsize[Y])
		t2 = point2D_add(t1, point2D(texsize[X] * texpixelsize[X] * mirrorsign, 0))
		t3 = point2D_add(t1, point2D(texsize[X] * texpixelsize[X] * mirrorsign, texpixelsize[Y]))
		t4 = point2D_add(t1, point2D(0, texpixelsize[Y]))
		
		// Y+ face
		p1 = point3D(0, 0, height - yy)
		p2 = point3D_add(p1, point3D(texsize[X], 0, 0))
		p3 = point3D_add(p1, point3D(texsize[X], 1, 0))
		p4 = point3D_add(p1, point3D(0, 1, 0))
		vbuffer_add_triangle(p1, p2, p3, t1, t2, t3, null, color, mat)
		vbuffer_add_triangle(p3, p4, p1, t3, t4, t1, null, color, mat)
		
		// Y- face
		p1 = point3D_add(p1, point3D(0, 0, -1))
		p2 = point3D_add(p2, point3D(0, 0, -1))
		p3 = point3D_add(p3, point3D(0, 0, -1))
		p4 = point3D_add(p4, point3D(0, 0, -1))
		vbuffer_add_triangle(p2, p1, p3, t2, t1, t3, null, color, mat)
		vbuffer_add_triangle(p4, p3, p1, t4, t3, t1, null, color, mat)
	}
}
else
{
	// Create array with full alpha pixels
	buffer_current = buffer_create(texsize[X] * texsize[Y] * 4, buffer_fixed, 4)
	buffer_get_surface(buffer_current, surf, 0, 0, 0)
	
	var hascolor;
	for (var py = 0; py < texsize[Y]; py++)
		for (var px = 0; px < texsize[X]; px++)
			hascolor[px, py] = (buffer_read_int_uns() >> 24 = 255)
	
	buffer_delete(buffer_current)
	
	for (var xx = 0; xx < texsize[X]; xx++)
	{
		for (var yy = 0; yy < texsize[Y]; yy++)
		{
			if (!hascolor[@ xx, yy]) 
				continue
				
			var ptex = point2D((texpos[X] + xx * mirrorsign) * texpixelsize[X], (texpos[Y] + yy) * texpixelsize[Y]);
			var p1, p2, p3, p4;
			var t1, t2, t3, t4;
		
			t1 = ptex
			t2 = point2D(ptex[X] + texpixelsize[X] * mirrorsign, ptex[Y])
			t3 = point2D(ptex[X] + texpixelsize[X] * mirrorsign, ptex[Y] + texpixelsize[Y])
			t4 = point2D(ptex[X], ptex[Y] + texpixelsize[Y])
			
			// East
			if (xx = texsize[X] - 1 || !hascolor[@ xx + 1, yy])
			{
				p1 = point3D(xx + 1, 1, (height - 1) - (yy - 1))
				p2 = point3D(xx + 1, 0, (height - 1) - (yy - 1))
				p3 = point3D(xx + 1, 0, (height - 1) - yy)
				p4 = point3D(xx + 1, 1, (height - 1) - yy)
				vbuffer_add_triangle(p1, p2, p3, t1, t2, t3, null, color, mat)
				vbuffer_add_triangle(p3, p4, p1, t3, t4, t1, null, color, mat)
			}
			
			// West
			if (xx = 0 || !hascolor[@ xx - 1, yy])
			{
				p1 = point3D(xx, 0, (height - 1) - (yy - 1))
				p2 = point3D(xx, 1, (height - 1) - (yy - 1))
				p3 = point3D(xx, 1, (height - 1) - yy)
				p4 = point3D(xx, 0, (height - 1) - yy)
				vbuffer_add_triangle(p1, p2, p3, t1, t2, t3, null, color, mat)
				vbuffer_add_triangle(p3, p4, p1, t3, t4, t1, null, color, mat)
			}
			
			// Up
			if (yy = 0 || !hascolor[@ xx, yy - 1])
			{
				p1 = point3D(xx, 0, (height - 1) - (yy - 1))
				p2 = point3D(xx + 1, 0, (height - 1) - (yy - 1))
				p3 = point3D(xx + 1, 1, (height - 1) - (yy - 1))
				p4 = point3D(xx, 1, (height - 1) - (yy - 1))
				vbuffer_add_triangle(p1, p2, p3, t1, t2, t3, null, color, mat)
				vbuffer_add_triangle(p3, p4, p1, t3, t4, t1, null, color, mat)
			}
			
			// Down
			if (yy = texsize[Y] - 1 || !hascolor[@ xx, yy + 1])
			{
				p1 = point3D(xx, 1, (height - 1) - yy)
				p2 = point3D(xx + 1, 1, (height - 1) - yy)
				p3 = point3D(xx + 1, 0, (height - 1) - yy)
				p4 = point3D(xx, 0, (height - 1) - yy)
				vbuffer_add_triangle(p1, p2, p3, t1, t2, t3, null, color, mat)
				vbuffer_add_triangle(p3, p4, p1, t3, t4, t1, null, color, mat)
			}
		}
	}
}