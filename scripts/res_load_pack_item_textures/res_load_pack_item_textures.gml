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
log("Item textures", "load")
texlist = ds_list_create() // name -> texture
for (var t = 0; t < ds_list_size(mc_assets.item_texture_list); t++)
{
	if (mc_assets.item_texture_list[|t] = "")
	{
		ds_list_add(texlist, null)
		continue
	}
	
	var name, fname;
	name = mc_assets.item_texture_list[|t]
	fname = load_assets_dir + mc_textures_directory + name + ".png";
	
	if (!file_exists_lib(fname) && !is_undefined(legacy_item_texture_name_map[?name]))
		fname = load_assets_dir + mc_textures_directory + legacy_item_texture_name_map[?name] + ".png"
		
	if (file_exists_lib(fname))
	{
		var tex = texture_create(fname);
		itemsize = max(itemsize, texture_width(tex))
		ds_list_add(texlist, tex)
	}
	else
	{
		log("Item texture not found", mc_assets.item_texture_list[|t])
		ds_list_add(texlist, null)
	}
}

if (itemsize = null)
	itemsize = item_size

// Create surface of items
log("Item textures", "surface")
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
		{
			var wid, hei, scale;
			wid = texture_width(tex)
			hei = texture_height(tex)
			scale = itemsize / wid
			draw_texture_part(tex, dx, dy, 0, 0, wid, hei, scale, scale)
		}
		else if (id != mc_res)
			draw_texture_part(mc_res.item_sheet_texture, dx, dy,
							  (t mod item_sheet_width) * item_size, (t div item_sheet_width) * item_size,
							  item_size, item_size, itemsize / item_size, itemsize / item_size)
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

log("Item textures", "done")
debug_timer_stop("Item textures")