/// temp_update_item()
/// @desc Generates the item vbuffer of the template from the selected resource.

if (!item_tex.ready)
	return 0

// Create vbuffer
if (item_vbuffer)
	vbuffer_destroy(item_vbuffer)
item_vbuffer = vbuffer_start()

// Calculate texture position and size
var texpos, texsize, slotsize, slottexsize, slottex;

if (item_tex.item_sheet_texture != null)
{
	texpos = point2D(item_slot mod item_tex.item_sheet_size[X], item_slot div item_tex.item_sheet_size[X])
	texsize = vec2(texture_width(item_tex.item_sheet_texture), texture_height(item_tex.item_sheet_texture))
	slotsize = vec2_div(texsize, item_tex.item_sheet_size)
	slotsize[X] = max(1, floor(slotsize[X]))
	slotsize[Y] = max(1, floor(slotsize[Y]))
	slottexsize = vec2_div(vec2(1), item_tex.item_sheet_size)
	slottex = point2D_mul(texpos, slottexsize)
}
else
{
	texpos = point2D(0, 0)
	texsize = vec2(texture_width(item_tex.texture), texture_height(item_tex.texture))
	slotsize = texsize
	slottexsize = point2D(1, 1)
	slottex = point2D(0, 0)
}

// Calculate 3D size
var size, scale;
size = vec3(item_size, bool_to_float(item_3d), item_size)
if (slotsize[X] > slotsize[Y]) // Not a square
	size[Z] *= slotsize[Y] / slotsize[X]
else if (slotsize[Y] > slotsize[X])
	size[X] *= slotsize[X] / slotsize[Y]
	
scale = vec3_div(size, vec3(slotsize[X], size[Y], slotsize[Y]))

var p1, p2, p3, p4;
var t1, t2, t3, t4;

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
	var surf, tex;
	surf = surface_create(slotsize[X], slotsize[Y])
	if (item_tex.item_sheet_texture != null)
		tex = item_tex.item_sheet_texture
	else
		tex = item_tex.texture
	
	draw_texture_start()
	surface_set_target(surf)
	{
		draw_clear_alpha(c_black, 0)
		draw_texture_part(tex, 0, 0, texpos[X] * slotsize[X], texpos[Y] * slotsize[Y], slotsize[X], slotsize[Y])
	}
	surface_reset_target()
	draw_texture_done()
	
	var slotpixel = vec2_div(slottexsize, slotsize);
	vbuffer_add_pixels(surf, point3D(0, 0, 0), size[Z], slottex, slotsize, slotpixel, scale)
	
	surface_free(surf)
}

vbuffer_done()
