/// res_load_legacy_block_sheet(filename, format)
/// @arg filename
/// @arg format

var fn, format, list;
fn = argument0
format = argument1

if (format >= e_project.FORMAT_100_DEBUG)
	list = legacy_block_100_texture_list
else if (format = e_project.FORMAT_07_DEMO)
	list = legacy_block_07_demo_texture_list
else
	list = legacy_block_05_texture_list

// Find dimensions
var oldtex, sheetwid, blocksize;
oldtex  = texture_create(fn)
sheetwid = 16
if (format >= e_project.FORMAT_100_DEMO_2)
	sheetwid = 32
blocksize = texture_width(oldtex) / sheetwid

// Create new surface
var newsurf, newtex;
newsurf = surface_create(block_sheet_width * blocksize, block_sheet_height * blocksize)

surface_set_target(newsurf)
draw_clear_alpha(c_black, 0)

// Draw default sheet
gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha)
draw_texture(res_def.block_sheet_texture, 0, 0, blocksize / 16, blocksize / 16)

for (var i = 0; i < ds_list_size(list); i++)
{
	var name = list[|i];
	if (name = "")
		continue
		
	var newindex = ds_list_find_index(mc_assets.block_texture_list, name);
	if (newindex < 0)
		continue
		
	var oldx, oldy, newx, newy;
	oldx = (i mod sheetwid) * blocksize
	oldy = (i div sheetwid) * blocksize
	newx = (newindex mod block_sheet_width) * blocksize
	newy = (newindex div block_sheet_width) * blocksize
	
	// Overwrite default texture
	gpu_set_blendmode(bm_subtract)
	draw_blank(newx, newy, blocksize, blocksize)
	
	// Render old block
	gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha)
	draw_texture_part(oldtex, newx, newy, oldx, oldy, blocksize, blocksize)
}

gpu_set_blendmode(bm_normal)
surface_reset_target()

newtex = texture_surface(newsurf)
surface_free(newsurf)

return newtex