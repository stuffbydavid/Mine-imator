/// vbuffer_add_pixels(surface, position, [height, texpos, texsize, texpixelsize, scale])
/// @arg surface
/// @arg position
/// @arg [height
/// @arg texpos
/// @arg texsize
/// @arg texpixelsize
/// @arg scale]

var surf, pos, height, texpos, texsize, texpixelsize, scale;
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
		t1 = point2D((texpos[X] + xx) * texpixelsize[X], texpos[Y] * texpixelsize[Y])
		t2 = point2D_add(t1, point2D(texpixelsize[X], 0))
		t3 = point2D_add(t1, point2D(texpixelsize[X], texsize[Y] * texpixelsize[Y]))
		t4 = point2D_add(t1, point2D(0, texsize[Y] * texpixelsize[Y]))
		
		// X- face
		p1 = point3D(pos[X] + xx * scale[X], pos[Y], pos[Z] + height * scale[Z])
		p2 = point3D_add(p1, point3D(0, scale[Y], 0))
		p3 = point3D_add(p1, point3D(0, scale[Y], -height * scale[Z]))
		p4 = point3D_add(p1, point3D(0, 0, -height * scale[Z]))
		vbuffer_add_triangle(p1, p2, p3, t1, t2, t3)
		vbuffer_add_triangle(p3, p4, p1, t3, t4, t1)
		
		// X+ face
		p1 = point3D_add(p1, point3D(scale[X], 0, 0))
		p2 = point3D_add(p2, point3D(scale[X], 0, 0))
		p3 = point3D_add(p3, point3D(scale[X], 0, 0))
		p4 = point3D_add(p4, point3D(scale[X], 0, 0))
		vbuffer_add_triangle(p2, p1, p3, t2, t1, t3)
		vbuffer_add_triangle(p4, p3, p1, t4, t3, t1)
	}
	
	// Y
	for (var yy = 0; yy < texsize[Y]; yy++)
	{
		t1 = point2D(texpos[X] * texpixelsize[X], (texpos[Y] + yy) * texpixelsize[Y])
		t2 = point2D_add(t1, point2D(texsize[X] * texpixelsize[X], 0))
		t3 = point2D_add(t1, point2D(texsize[X] * texpixelsize[X], texpixelsize[Y]))
		t4 = point2D_add(t1, point2D(0, texpixelsize[Y]))
		
		// Y+ face
		p1 = point3D(pos[X], pos[Y], pos[Z] + height - yy * scale[Z])
		p2 = point3D_add(p1, point3D(texsize[X] * scale[X], 0, 0))
		p3 = point3D_add(p1, point3D(texsize[X] * scale[X], scale[Y], 0))
		p4 = point3D_add(p1, point3D(0, scale[Y], 0))
		vbuffer_add_triangle(p1, p2, p3, t1, t2, t3)
		vbuffer_add_triangle(p3, p4, p1, t3, t4, t1)
		
		// Y- face
		p1 = point3D_add(p1, point3D(0, 0, -scale[Z]))
		p2 = point3D_add(p2, point3D(0, 0, -scale[Z]))
		p3 = point3D_add(p3, point3D(0, 0, -scale[Z]))
		p4 = point3D_add(p4, point3D(0, 0, -scale[Z]))
		vbuffer_add_triangle(p2, p1, p3, t2, t1, t3)
		vbuffer_add_triangle(p4, p3, p1, t4, t3, t1)
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
				
			var ptex = point2D((texpos[X] + xx) * texpixelsize[X], (texpos[Y] + yy) * texpixelsize[Y]);
			var p1, p2, p3, p4;
			var t1, t2, t3, t4;
		
			t1 = ptex
			t2 = point2D(ptex[X] + texpixelsize[X], ptex[Y])
			t3 = point2D_add(ptex, texpixelsize)
			t4 = point2D(ptex[X], ptex[Y] + texpixelsize[Y])
			
			// East
			if (xx = texsize[X] - 1 || !hascolor[@ xx + 1, yy])
			{
				p1 = point3D(pos[X] + (xx + 1) * scale[X], pos[Y] + scale[Y], pos[Z] + (height - scale[Z]) - (yy - 1) * scale[Z])
				p2 = point3D(pos[X] + (xx + 1) * scale[X], pos[Y], pos[Z] + (height - scale[Z]) - (yy - 1) * scale[Z])
				p3 = point3D(pos[X] + (xx + 1) * scale[X], pos[Y], pos[Z] + (height - scale[Z]) - yy * scale[Z])
				p4 = point3D(pos[X] + (xx + 1) * scale[X], pos[Y] + scale[Y], pos[Z] + (height - scale[Z]) - yy * scale[Z])
				vbuffer_add_triangle(p1, p2, p3, t1, t2, t3)
				vbuffer_add_triangle(p3, p4, p1, t3, t4, t1)
			}
			
			// West
			if (xx = 0 || !hascolor[@ xx - 1, yy])
			{
				p1 = point3D(pos[X] + xx * scale[X], pos[Y], pos[Z] + (height - scale[Z]) - (yy - 1) * scale[Z])
				p2 = point3D(pos[X] + xx * scale[X], pos[Y] + scale[Y], pos[Z] + (height - scale[Z]) - (yy - 1) * scale[Z])
				p3 = point3D(pos[X] + xx * scale[X], pos[Y] + scale[Y], pos[Z] + (height - scale[Z]) - yy * scale[Z])
				p4 = point3D(pos[X] + xx * scale[X], pos[Y], pos[Z] + (height - scale[Z]) - yy * scale[Z])
				vbuffer_add_triangle(p1, p2, p3, t1, t2, t3)
				vbuffer_add_triangle(p3, p4, p1, t3, t4, t1)
			}
			
			// Up
			if (yy = 0 || !hascolor[@ xx, yy - 1])
			{
				p1 = point3D(pos[X] + xx * scale[X], pos[Y], pos[Z] + (height - scale[Z]) - (yy - 1) * scale[Z])
				p2 = point3D(pos[X] + (xx + 1) * scale[X], pos[Y], pos[Z] + (height - scale[Z]) - (yy - 1) * scale[Z])
				p3 = point3D(pos[X] + (xx + 1) * scale[X], pos[Y] + scale[Y], pos[Z] + (height - scale[Z]) - (yy - 1) * scale[Z])
				p4 = point3D(pos[X] + xx * scale[X], pos[Y] + scale[Y], pos[Z] + (height - scale[Z]) - (yy - 1) * scale[Z])
				vbuffer_add_triangle(p1, p2, p3, t1, t2, t3)
				vbuffer_add_triangle(p3, p4, p1, t3, t4, t1)
			}
			
			// Down
			if (yy = texsize[Y] - 1 || !hascolor[@ xx, yy + 1])
			{
				p1 = point3D(pos[X] + xx * scale[X], pos[Y] + scale[Y], pos[Z] + (height - scale[Z]) - yy * scale[Z])
				p2 = point3D(pos[X] + (xx + 1) * scale[X], pos[Y] + scale[Y], pos[Z] + (height - scale[Z]) - yy * scale[Z])
				p3 = point3D(pos[X] + (xx + 1) * scale[X], pos[Y], pos[Z] + (height - scale[Z]) - yy * scale[Z])
				p4 = point3D(pos[X] + xx * scale[X], pos[Y], pos[Z] + (height - scale[Z]) - yy* scale[Z])
				vbuffer_add_triangle(p1, p2, p3, t1, t2, t3)
				vbuffer_add_triangle(p3, p4, p1, t3, t4, t1)
			}
		}
	}
}