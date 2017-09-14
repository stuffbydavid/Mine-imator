/// vbuffer_add_pixels(array, position, height, texpos, texsize, pixelsize, scale)
/// @arg array
/// @arg width
/// @arg height

var arr, pos, height, texpos, texsize, texpixelsize, scale;
arr = argument0
pos = argument1
height = argument2
texpos = argument3
texsize = argument4
texpixelsize = argument5
scale = argument6

for (var xx = 0; xx < texsize[X]; xx++)
{
	for (var yy = 0; yy < texsize[Y]; yy++)
	{
		if (!arr[@ xx, yy]) 
			continue
				
		var ptex = point2D(texpos[X] + xx * texpixelsize[X], texpos[Y] + yy * texpixelsize[Y]);
		var p1, p2, p3, p4;
		var t1, t2, t3, t4;
		
		t1 = ptex
		t2 = point2D(ptex[X] + texpixelsize[X], ptex[Y])
		t3 = point2D_add(ptex, texpixelsize)
		t4 = point2D(ptex[X], ptex[Y] + texpixelsize[Y])
			
		// East
		if (xx = texsize[X] - 1 || !arr[@ xx + 1, yy])
		{
			p1 = point3D(pos[X] + (xx + 1) * scale[X], pos[Y] + 1, pos[Z] + (height - scale[Z]) - (yy - 1) * scale[Z])
			p2 = point3D(pos[X] + (xx + 1) * scale[X], pos[Y], pos[Z] + (height - scale[Z]) - (yy - 1) * scale[Z])
			p3 = point3D(pos[X] + (xx + 1) * scale[X], pos[Y], pos[Z] + (height - scale[Z]) - yy * scale[Z])
			p4 = point3D(pos[X] + (xx + 1) * scale[X], pos[Y] + 1, pos[Z] + (height - scale[Z]) - yy * scale[Z])
			vbuffer_add_triangle(p1, p2, p3, t1, t2, t3)
			vbuffer_add_triangle(p3, p4, p1, t3, t4, t1)
		}
			
		// West
		if (xx = 0 || !arr[@ xx - 1, yy])
		{
			p1 = point3D(pos[X] + xx * scale[X], pos[Y], pos[Z] + (height - scale[Z]) - (yy - 1) * scale[Z])
			p2 = point3D(pos[X] + xx * scale[X], pos[Y] + 1, pos[Z] + (height - scale[Z]) - (yy - 1) * scale[Z])
			p3 = point3D(pos[X] + xx * scale[X], pos[Y] + 1, pos[Z] + (height - scale[Z]) - yy * scale[Z])
			p4 = point3D(pos[X] + xx * scale[X], pos[Y], pos[Z] + (height - scale[Z]) - yy * scale[Z])
			vbuffer_add_triangle(p1, p2, p3, t1, t2, t3)
			vbuffer_add_triangle(p3, p4, p1, t3, t4, t1)
		}
			
		// Up
		if (yy = 0 || !arr[@ xx, yy - 1])
		{
			p1 = point3D(pos[X] + xx * scale[X], pos[Y], pos[Z] + (height - scale[Z]) - (yy - 1) * scale[Z])
			p2 = point3D(pos[X] + (xx + 1) * scale[X], pos[Y], pos[Z] + (height - scale[Z]) - (yy - 1) * scale[Z])
			p3 = point3D(pos[X] + (xx + 1) * scale[X], pos[Y] + 1, pos[Z] + (height - scale[Z]) - (yy - 1) * scale[Z])
			p4 = point3D(pos[X] + xx * scale[X], pos[Y] + 1, pos[Z] + (height - scale[Z]) - (yy - 1) * scale[Z])
			vbuffer_add_triangle(p1, p2, p3, t1, t2, t3)
			vbuffer_add_triangle(p3, p4, p1, t3, t4, t1)
		}
			
		// Down
		if (yy = texsize[Y] - 1 || !arr[@ xx, yy + 1])
		{
			p1 = point3D(pos[X] + xx * scale[X], pos[Y] + 1, pos[Z] + (height - scale[Z]) - yy * scale[Z])
			p2 = point3D(pos[X] + (xx + 1) * scale[X], pos[Y] + 1, pos[Z] + (height - scale[Z]) - yy * scale[Z])
			p3 = point3D(pos[X] + (xx + 1) * scale[X], pos[Y], pos[Z] + (height - scale[Z]) - yy * scale[Z])
			p4 = point3D(pos[X] + xx * scale[X], pos[Y], pos[Z] + (height - scale[Z]) - yy* scale[Z])
			vbuffer_add_triangle(p1, p2, p3, t1, t2, t3)
			vbuffer_add_triangle(p3, p4, p1, t3, t4, t1)
		}
	}
}