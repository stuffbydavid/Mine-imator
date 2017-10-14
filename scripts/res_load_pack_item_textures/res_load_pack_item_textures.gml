/// res_load_pack_item_textures()
/// @desc Creates a texture sheet for the items.

// Free old
if (item_sheet_texture != null)
	texture_free(item_sheet_texture)

// Create new
var itemsize, texlist, surf;
itemsize = null

debug_timer_start()

// Load textures
texlist = ds_list_create() // name -> texture
for (var t = 0; t < ds_list_size(mc_assets.item_texture_list); t++)
{
	var fname = load_assets_dir + mc_textures_directory + mc_assets.item_texture_list[|t] + ".png";
	if (file_exists_lib(fname))
	{
		var tex = texture_create(fname);
		if (itemsize = null)
			itemsize = texture_width(tex)
		ds_list_add(texlist, tex)
	}
	else
		ds_list_add(texlist, null)
}

if (itemsize = null)
	itemsize = item_size

// Create surface of static blocks
draw_texture_start()
surf = surface_create(item_sheet_width * itemsize, item_sheet_height * itemsize)
surface_set_target(surf)
{
	gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha)
	draw_clear_alpha(c_black, 0)
	
	for (var t = 0; t < ds_list_size(texlist); t++)
	{
		var tex, dx, dy;
		tex = texlist[|t]
		dx = (t mod item_sheet_width) * itemsize
		dy = (t div item_sheet_width) * itemsize
	
		if (tex != null)
			draw_texture_part(tex, dx, dy, 0, 0, itemsize, itemsize)
	}
	
	gpu_set_blendmode(bm_normal)
}
surface_reset_target()
draw_texture_done()

item_sheet_texture = texture_surface(surf)

// Clean up
for (var t = 0; t < ds_list_size(texlist); t++)
	if (texlist[|t] != null)
		texture_free(texlist[|t])
	
surface_free(surf)
ds_list_destroy(texlist)

debug_timer_stop("res_load_pack_item_textures")