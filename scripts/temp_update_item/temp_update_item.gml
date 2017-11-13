/// temp_update_item()
/// @desc Generates the item vbuffer of the template from the selected resource.

if (!item_tex.ready)
	return 0

// Create vbuffer
if (item_vbuffer)
	vbuffer_destroy(item_vbuffer)
item_vbuffer = vbuffer_start()

// Calculate texture position and size
var texsize, texpos, slotpos, slotsize, slottexsize, slottex;

if (item_tex.item_sheet_texture != null)
{
	texsize = vec2(texture_width(item_tex.item_sheet_texture), texture_height(item_tex.item_sheet_texture))
	slotpos = point2D(item_slot mod item_tex.item_sheet_size[X], item_slot div item_tex.item_sheet_size[X])
	slotsize = vec2_div(texsize, item_tex.item_sheet_size)
	slotsize[X] = max(1, slotsize[X])
	slotsize[Y] = max(1, slotsize[Y])
	slottexsize = vec2_div(vec2(1), item_tex.item_sheet_size)
	slottex = point2D_mul(slotpos, slottexsize)
	texpos = point2D_mul(slotpos, slotsize)
}
else
{
	texsize = vec2(texture_width(item_tex.texture), texture_height(item_tex.texture))
	slotpos = point2D(0, 0)
	slotsize = texsize
	slottexsize = point2D(1, 1)
	slottex = point2D(0, 0)
	texpos = point2D(0, 0)
}

// Artifact fix with CPU rendering, offset end texture coordinates by 1/64s of a pixel
var pfix, slottexsizefix, slotsizefix;
pfix = vec2_mul(vec2_div(vec2(1), slotsize), vec2(1 / 64))
slottexsizefix = point2D_sub(slottexsize, point2D_mul(pfix, slottexsize))
slotsizefix = point2D_sub(slotsize, point2D_mul(pfix, slotsize))

// Calculate 3D size and scale
var size, scale;
size = vec3(item_size, bool_to_float(item_3d), item_size)
if (slotsizefix[X] > slotsizefix[Y]) // Not a square
	size[Z] *= slotsizefix[Y] / slotsizefix[X]
else if (slotsizefix[Y] > slotsizefix[X])
	size[X] *= slotsizefix[X] / slotsizefix[Y]
	
scale = vec3_div(size, vec3(slotsizefix[X], size[Y], slotsizefix[Y]))

// Add faces
var p1, p2, p3, p4;
var t1, t2, t3, t4;

// Front face
p1 = point3D(0, size[Y], size[Z])
p2 = point3D(size[X], size[Y], size[Z])
p3 = point3D(size[X], size[Y], 0)
p4 = point3D(0, size[Y], 0)
t1 = slottex
t2 = point2D(slottex[X] + slottexsizefix[X], slottex[Y])
t3 = point2D_add(slottex, slottexsizefix)
t4 = point2D(slottex[X], slottex[Y] + slottexsizefix[Y])
vbuffer_add_triangle(p1, p2, p3, t1, t2, t3)
vbuffer_add_triangle(p3, p4, p1, t3, t4, t1)

// Back face
p1 = point3D(size[X], 0, size[Z])
p2 = point3D(0, 0, size[Z])
p3 = point3D(0, 0, 0)
p4 = point3D(size[X], 0, 0)
t1 = point2D(slottex[X] + slottexsizefix[X], slottex[Y])
t2 = slottex
t3 = point2D(slottex[X], slottex[Y] + slottexsizefix[Y])
t4 = point2D_add(slottex, slottexsizefix)
vbuffer_add_triangle(p1, p2, p3, t1, t2, t3)
vbuffer_add_triangle(p3, p4, p1, t3, t4, t1)

// 3D pixels
if (item_3d)
{
	var slotsizeceil, surf, tex;
	slotsizeceil = point2D(ceil(slotsize[X]), ceil(slotsize[Y]))
	
	surf = surface_create(slotsizeceil[X], slotsizeceil[Y])
	if (item_tex.item_sheet_texture != null)
		tex = item_tex.item_sheet_texture
	else
		tex = item_tex.texture
	
	draw_texture_start()
	surface_set_target(surf)
	{
		draw_clear_alpha(c_black, 0)
		draw_texture_part(tex, 0, 0, floor(texpos[X]), floor(texpos[Y]), slotsizeceil[X], slotsizeceil[Y])
	}
	surface_reset_target()
	draw_texture_done()
	
	var slotpixel = vec2_div(slottexsizefix, slotsizefix);
	vbuffer_add_pixels(surface_get_alpha_array(surf), point3D(0, 0, 0), size[Z], texpos, slotsizefix, slotpixel, scale)
	
	surface_free(surf)
}

vbuffer_done()
