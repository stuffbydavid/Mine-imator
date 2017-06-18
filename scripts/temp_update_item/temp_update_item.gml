/// temp_update_item()
/// @desc Generates the item vbuffer of the vbuffer.

var size, slotsize, slot, pixel, scale, ix, iy, tx, ty, ysize;

if (!item_tex.ready)
	return 0

// Create vbuffer
if (item_vbuffer)
	vbuffer_destroy(item_vbuffer)
item_vbuffer = vbuffer_start()

// Calculate dimensions
size = texture_width(item_tex.item_texture)

if (item_sheet)
{
	slotsize = size / 16
	slot = 1/16
	ix = (item_n mod 16) * slotsize
	iy = (item_n div 16) * slotsize
	tx = ix / size
	ty = iy / size
}
else
{
	slotsize = size
	slot = 1
	ix = 0
	iy = 0
	tx = 0
	ty = 0
}
pixel = slot / slotsize
scale = 16 / slotsize

// Front
ysize = bool_to_float(item_3d)
vertex_add(0, ysize, 0, 0, 1, 0, tx, ty + slot)
vertex_add(0, ysize, 16, 0, 1, 0, tx, ty)
vertex_add(16, ysize, 16, 0, 1, 0, tx + slot, ty)
vertex_add(16, ysize, 16, 0, 1, 0, tx + slot, ty)
vertex_add(16, ysize, 0, 0, 1, 0, tx + slot, ty + slot)
vertex_add(0, ysize, 0, 0, 1, 0, tx, ty + slot)

// Back
vertex_add(16, 0, 16, 0, -1, 0, tx + slot, ty)
vertex_add(0, 0, 16, 0, -1, 0, tx, ty)
vertex_add(0, 0, 0, 0, -1, 0, tx, ty + slot)
vertex_add(0, 0, 0, 0, -1, 0, tx, ty + slot)
vertex_add(16, 0, 0, 0, -1, 0, tx + slot, ty + slot)
vertex_add(16, 0, 16, 0, -1, 0, tx + slot, ty)

if (item_3d)
{
	var surf, hascolor;
	surf = surface_create(slotsize, slotsize)
	surface_set_target(surf)
	{
		draw_clear_alpha(c_black, 0)
		draw_texture_part(item_tex.item_texture, 0, 0, ix, iy, slotsize, slotsize)
	}
	surface_reset_target()
	
	buffer_current = buffer_create(slotsize * slotsize * 4, buffer_fixed, 4)
	buffer_get_surface(buffer_current, surf, 0, 0, 0)
	
	for (var xx = 0; xx < slotsize; xx++)
		for (var yy = 0; yy < slotsize; yy++)
			hascolor[xx, yy] = buffer_read_alpha(xx, yy, slotsize) > 0
			
	buffer_delete(buffer_current)
	surface_free(surf)
	
	for (var xx = 0; xx < slotsize; xx++)
	{
		for (var yy = 0; yy < slotsize; yy++)
		{
			var txp, typ;
			
			if (!hascolor[xx, yy]) 
				continue
				
			txp = tx + xx * pixel
			typ = ty + yy * pixel
			
			if (xx = slotsize - 1 || !hascolor[xx + 1, yy])
			{
				vertex_add((xx + 1) * scale, 0, (16 - scale) - yy * scale, 1, 0, 0, txp, typ)
				vertex_add((xx + 1) * scale, 1, (16 - scale) - yy * scale, 1, 0, 0, txp, typ)
				vertex_add((xx + 1) * scale, 1, (16 - scale) - (yy - 1) * scale, 1, 0, 0, txp + pixel, typ + pixel) 
				vertex_add((xx + 1) * scale, 1, (16 - scale) - (yy - 1) * scale, 1, 0, 0, txp + pixel, typ + pixel)
				vertex_add((xx + 1) * scale, 0, (16 - scale) - (yy - 1) * scale, 1, 0, 0, txp + pixel, typ + pixel)
				vertex_add((xx + 1) * scale, 0, (16 - scale) - yy * scale, 1, 0, 0, txp, typ)
			}
			
			if (xx = 0 || !hascolor[xx - 1, yy])
			{
				vertex_add(xx * scale, 1, (16 - scale) - (yy - 1) * scale, -1, 0, 0, txp + pixel, typ + pixel)
				vertex_add(xx * scale, 1, (16 - scale) - yy * scale, -1, 0, 0, txp, typ)
				vertex_add(xx * scale, 0, (16 - scale) - yy * scale, -1, 0, 0, txp, typ)
				vertex_add(xx * scale, 0, (16 - scale) - yy * scale, -1, 0, 0, txp, typ)
				vertex_add(xx * scale, 0, (16 - scale) - (yy - 1) * scale, -1, 0, 0, txp + pixel, typ + pixel)
				vertex_add(xx * scale, 1, (16 - scale) - (yy - 1) * scale, -1, 0, 0, txp + pixel, typ + pixel)
			}
			
			if (yy = slotsize - 1 || !hascolor[xx, yy + 1])
			{
				vertex_add(xx * scale, 0, (16 - scale) - yy * scale, 0, 0, -1, txp, typ)
				vertex_add(xx * scale, 1, (16 - scale) - yy * scale, 0, 0, -1, txp, typ)
				vertex_add((xx + 1) * scale, 1, (16 - scale) - yy * scale, 0, 0, -1, txp + pixel, typ + pixel)
				vertex_add((xx + 1) * scale, 1, (16 - scale) - yy * scale, 0, 0, -1, txp + pixel, typ + pixel)
				vertex_add((xx + 1) * scale, 0, (16 - scale) - yy * scale, 0, 0, -1, txp + pixel, typ + pixel)
				vertex_add(xx * scale, 0, (16 - scale) - yy * scale, 0, 0, -1, txp, typ)
			}
			
			if (yy = 0 || !hascolor[xx, yy - 1])
			{
				vertex_add((xx + 1) * scale, 1, (16 - scale) - (yy - 1) * scale, 0, 0, 1, txp + pixel, typ + pixel)
				vertex_add(xx * scale, 1, (16 - scale) - (yy - 1) * scale, 0, 0, 1, txp, typ)
				vertex_add(xx * scale, 0, (16 - scale) - (yy - 1) * scale, 0, 0, 1, txp, typ)
				vertex_add(xx * scale, 0, (16 - scale) - (yy - 1) * scale, 0, 0, 1, txp, typ)
				vertex_add((xx + 1) * scale, 0, (16 - scale) - (yy - 1) * scale, 0, 0, 1, txp + pixel, typ + pixel)
				vertex_add((xx + 1) * scale, 1, (16 - scale) - (yy - 1) * scale, 0, 0, 1, txp + pixel, typ + pixel)
			}
		}
	}
}

vbuffer_done()
