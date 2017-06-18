/// temp_update_item()
/// @desc Generates the item vbuffer of the vbuffer.

var texsize, itempos, slotsize, slottexsize, slottex, slotpixel, size, scale;
var p1, p2, p3, p4;
var t1, t2, t3, t4;

if (!item_tex.ready)
	return 0

// Create vbuffer
if (item_vbuffer)
	vbuffer_destroy(item_vbuffer)
item_vbuffer = vbuffer_start()

// Calculate texture position and size
texsize = vec2(texture_width(item_tex.item_texture), texture_height(item_tex.item_texture))

if (item_tex.is_item_sheet)
{
	var index = ds_list_find_index(mc_version.item_texture_list, item_name);
	itempos = point2D(index mod item_tex.item_sheet_size[X], index div item_tex.item_sheet_size[X])
	slotsize = vec2_div(texsize, item_tex.item_sheet_size)
	slotsize[X] = max(1, floor(slotsize[X]))
	slotsize[Y] = max(1, floor(slotsize[Y]))
	slottexsize = vec2_div(vec2(1), item_tex.item_sheet_size)
	slottex = point2D_mul(itempos, slottexsize)
}
else
{
	itempos = point2D(0, 0)
	slotsize = texsize
	slottexsize = point2D(1, 1)
	slottex = point2D(0, 0)
}

slotpixel = vec2_div(slottexsize, slotsize)

// Calculate 3D size
size = vec3(item_size, bool_to_float(item_3d), item_size)
if (slotsize[X] > slotsize[Y]) // Not a square
	size[Z] *= slotsize[Y] / slotsize[X]
else if (slotsize[Y] > slotsize[X])
	size[X] *= slotsize[X] / slotsize[Y]
	
scale = vec3_div(size, vec3(slotsize[X], size[Y], slotsize[Y]))

// Front
p1 = point3D(0, size[Y], size[Z])
p2 = point3D(size[X], size[Y], size[Z])
p3 = point3D(size[X], size[Y], 0)
p4 = point3D(0, size[Y], 0)
t1 = slottex
t2 = point2D(slottex[X] + slottexsize[X], slottex[Y])
t3 = point2D_add(slottex, slottexsize)
t4 = point2D(slottex[X], slottex[Y] + slottexsize[Y])
vbuffer_add_triangle(p1, p2, p3, t1, t2, t3)
vbuffer_add_triangle(p3, p4, p1, t3, t4, t1)

// Back
p1 = point3D(size[X], 0, size[Z])
p2 = point3D(0, 0, size[Z])
p3 = point3D(0, 0, 0)
p4 = point3D(size[X], 0, 0)
t1 = point2D(slottex[X] + slottexsize[X], slottex[Y])
t2 = slottex
t3 = point2D(slottex[X], slottex[Y] + slottexsize[Y])
t4 = point2D_add(slottex, slottexsize)
vbuffer_add_triangle(p1, p2, p3, t1, t2, t3)
vbuffer_add_triangle(p3, p4, p1, t3, t4, t1)

// 3D pixels
if (item_3d)
{
	var surf, hascolor;
	surf = surface_create(slotsize[X], slotsize[Y])
	surface_set_target(surf)
	{
		draw_clear_alpha(c_black, 0)
		draw_texture_part(item_tex.item_texture, 0, 0, itempos[X] * slotsize[X], itempos[Y] * slotsize[Y], slotsize[X], slotsize[Y])
	}
	surface_reset_target()
	
	buffer_current = buffer_create(slotsize[X] * slotsize[Y] * 4, buffer_fixed, 4)
	buffer_get_surface(buffer_current, surf, 0, 0, 0)
	
	for (var xx = 0; xx < slotsize[X]; xx++)
		for (var yy = 0; yy < slotsize[Y]; yy++)
			hascolor[xx, yy] = (buffer_read_alpha(xx, yy, slotsize[X]) > 0)
			
	buffer_delete(buffer_current)
	surface_free(surf)
	
	for (var xx = 0; xx < slotsize[X]; xx++)
	{
		for (var yy = 0; yy < slotsize[Y]; yy++)
		{
			if (!hascolor[xx, yy]) 
				continue
				
			var ptex = point2D(slottex[X] + xx * slotpixel[X], slottex[Y] + yy * slotpixel[Y]);
			t1 = ptex
			t2 = point2D(ptex[X] + slotpixel[X], ptex[Y])
			t3 = point2D_add(ptex, slotpixel)
			t4 = point2D(ptex[X], ptex[Y] + slotpixel[Y])
			
			// East
			if (xx = slotsize[X] - 1 || !hascolor[xx + 1, yy])
			{
				p1 = point3D((xx + 1) * scale[X], 1, (size[Z] - scale[Z]) - (yy - 1) * scale[Z])
				p2 = point3D((xx + 1) * scale[X], 0, (size[Z] - scale[Z]) - (yy - 1) * scale[Z])
				p3 = point3D((xx + 1) * scale[X], 0, (size[Z] - scale[Z]) - yy * scale[Z])
				p4 = point3D((xx + 1) * scale[X], 1, (size[Z] - scale[Z]) - yy * scale[Z])
				vbuffer_add_triangle(p1, p2, p3, t1, t1, t4)
				vbuffer_add_triangle(p3, p4, p1, t4, t4, t1)
			}
			
			// West
			if (xx = 0 || !hascolor[xx - 1, yy])
			{
				p1 = point3D(xx * scale[X], 0, (size[Z] - scale[Z]) - (yy - 1) * scale[Z])
				p2 = point3D(xx * scale[X], 1, (size[Z] - scale[Z]) - (yy - 1) * scale[Z])
				p3 = point3D(xx * scale[X], 1, (size[Z] - scale[Z]) - yy * scale[Z])
				p4 = point3D(xx * scale[X], 0, (size[Z] - scale[Z]) - yy * scale[Z])
				vbuffer_add_triangle(p1, p2, p3, t1, t1, t4)
				vbuffer_add_triangle(p3, p4, p1, t4, t4, t1)
			}
			
			// Up
			if (yy = 0 || !hascolor[xx, yy - 1])
			{
				p1 = point3D(xx * scale[X], 0, (size[Z] - scale[Z]) - (yy - 1) * scale[Z])
				p2 = point3D((xx + 1) * scale[X], 0, (size[Z] - scale[Z]) - (yy - 1) * scale[Z])
				p3 = point3D((xx + 1) * scale[X], 1, (size[Z] - scale[Z]) - (yy - 1) * scale[Z])
				p4 = point3D(xx * scale[X], 1, (size[Z] - scale[Z]) - (yy - 1) * scale[Z])
				vbuffer_add_triangle(p1, p2, p3, t1, t2, t2)
				vbuffer_add_triangle(p3, p4, p1, t2, t1, t1)
			}
			
			// Down
			if (yy = slotsize[Y] - 1 || !hascolor[xx, yy + 1])
			{
				p1 = point3D(xx * scale[X], 1, (size[Z] - scale[Z]) - yy * scale[Z])
				p2 = point3D((xx + 1) * scale[X], 1, (size[Z] - scale[Z]) - yy * scale[Z])
				p3 = point3D((xx + 1) * scale[X], 0, (size[Z] - scale[Z]) - yy * scale[Z])
				p4 = point3D(xx * scale[X], 0, (size[Z] - scale[Z]) - yy* scale[Z])
				vbuffer_add_triangle(p1, p2, p3, t1, t2, t2)
				vbuffer_add_triangle(p3, p4, p1, t2, t1, t1)
			}
		}
	}
}

vbuffer_done()
