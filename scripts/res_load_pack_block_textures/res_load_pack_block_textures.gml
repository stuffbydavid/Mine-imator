/// res_load_pack_block_textures()
/// @desc Creates a static and animated block sheet out of the list of block textures.

// Free old
if (block_sheet_texture != null)
	texture_free(block_sheet_texture)
	
if (block_sheet_ani_texture != null)
	for (var f = 0; f < block_sheet_ani_frames; f++)
		texture_free(block_sheet_ani_texture[f])
		
if (block_sheet_depth_list != null)
	ds_list_destroy(block_sheet_depth_list)
	
if (block_sheet_ani_depth_list != null)
	ds_list_destroy(block_sheet_ani_depth_list)
		
// Create new
var blocksize, texlist, texanilist, surf, anisurf;
blocksize = null

debug_timer_start()
		
// Static textures
texlist = ds_list_create() // name -> texture
for (var t = 0; t < ds_list_size(mc_assets.block_texture_list); t++)
{
	var fname  = load_assets_dir + mc_textures_directory + string_replace(mc_assets.block_texture_list[|t], " opaque", "") + ".png";
	if (file_exists_lib(fname))
	{
		var tex = texture_create(fname);
		blocksize = max(blocksize, texture_width(tex))
		ds_list_add(texlist, tex)
	}
	else
		ds_list_add(texlist, null)
}
	
// Animated textures
texanilist = ds_list_create() // name -> texture
for (var t = 0; t < ds_list_size(mc_assets.block_texture_ani_list); t++)
{
	var name, fname;
	name = mc_assets.block_texture_ani_list[|t]
	fname = load_assets_dir + mc_textures_directory + string_replace(mc_assets.block_texture_ani_list[|t], " opaque", "") + ".png"
	if (file_exists_lib(fname))
	{
		var tex = texture_create(fname);
		ds_list_add(texanilist, tex)
	}
	else
		ds_list_add(texanilist, null)
}

if (blocksize = null)
	blocksize = block_size
	
log("blocksize", blocksize)

// Create surface of static blocks
draw_texture_start()
surf = surface_create(block_sheet_width * blocksize, block_sheet_height * blocksize)
surface_set_target(surf)
{
	gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha)
	draw_clear_alpha(c_black, 0)

	for (var t = 0; t < ds_list_size(texlist); t++)
	{
		var tex, dx, dy;
		tex = texlist[|t]
		dx = (t mod block_sheet_width) * blocksize
		dy = (t div block_sheet_width) * blocksize
	
		if (tex != null)
		{
			var texwid, scale;
			texwid = texture_width(tex)
			scale = blocksize / texwid
			if (string_contains(mc_assets.block_texture_list[|t], " opaque"))
				draw_box(dx, dy, blocksize, blocksize, false, c_black, 1)
			draw_texture_part(tex, dx, dy, 0, 0, texwid, texwid, scale, scale)
		}
		else if (id != mc_res)
			draw_texture_part(mc_res.block_sheet_texture, dx, dy,
							  (t mod block_sheet_width) * block_size, (t div block_sheet_width) * block_size,
							  block_size, block_size, blocksize / block_size, blocksize / block_size)
		else
			draw_missing(dx, dy, blocksize, blocksize)
	}
	
	gpu_set_blendmode(bm_normal)
}
surface_reset_target()
draw_texture_done()

if (id = mc_res)
{
	var previewsurf = surface_create(block_sheet_width, block_sheet_height);
	surface_set_target(previewsurf)
	{
		gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha)
		gpu_set_tex_filter(true)
		draw_clear_alpha(c_black, 0)
		draw_surface_ext(surf, 0, 0, 1 / block_size, 1 / block_size, 0, c_white, 1)
		gpu_set_tex_filter(false)
		gpu_set_blendmode(bm_normal)
	}
	surface_reset_target()
	
	load_assets_block_preview_buffer = buffer_create(block_sheet_width * block_sheet_height * 4, buffer_fixed, 4)
	buffer_get_surface(load_assets_block_preview_buffer, previewsurf, 0, 0, 0)
	//surface_save(previewsurf, "previewsurf.png")
	//surface_free(previewsurf)
}

//surface_save(surf,"pack_load_block_textures_staticsurf.png")
block_sheet_texture = texture_surface(surf)

// Create surfaces for animated blocks
for (var f = 0; f < block_sheet_ani_frames; f++)
	anisurf[f] = surface_create(block_sheet_ani_width * blocksize, block_sheet_ani_height * blocksize)

draw_texture_start()
gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha)
for (var t = 0; t < ds_list_size(texanilist); t++)
{
	var tex, dx, dy;
	tex = texanilist[|t]
	dx = (t mod block_sheet_ani_width) * blocksize
	dy = (t div block_sheet_ani_width) * blocksize
	
	// Read animation data if available
	var framefade, frametime, framelist, opaque;
	var fname, texwid, images, aniframes, anilength, aniloops;
	framefade = false
	frametime = 1
	framelist = null
	opaque = string_contains(mc_assets.block_texture_ani_list[|t], " opaque")
	
	// Load JSON
	fname = load_assets_dir + mc_textures_directory + mc_assets.block_texture_ani_list[|t] + ".png.mcmeta"
	if (file_exists_lib(fname))
	{
		var map = json_load(fname);
		if (ds_map_valid(map))
		{
			var animation = map[?"animation"];
			if (!is_undefined(animation))
			{
				// Interpolate
				if (!is_undefined(animation[?"interpolate"]))
					framefade = animation[?"interpolate"]
					
				// Frametime
				if (!is_undefined(animation[?"frametime"]))
					frametime = animation[?"frametime"]
					
				// Frames
				if (!is_undefined(animation[?"frames"]))
					framelist = animation[?"frames"]
			}
		}
	}
	
	// Images in the texture
	texwid = texture_width(tex)
	images = texture_height(tex) / texwid
	
	// Total animation time (in frames)
	if (framelist != null)
		aniframes = ds_list_size(framelist)
	else
		aniframes = images
	anilength = aniframes * frametime
	
	// More than 150% of max frames, no animation
	if (anilength > block_sheet_ani_frames * 1.5)
	{
		aniframes = 1
		anilength = 1
	}
	
	// Number of loops
	aniloops = max(1, round(block_sheet_ani_frames / anilength))
	
	for (var f = 0; f < block_sheet_ani_frames; f++)
	{
		var aniprogress = (f / (block_sheet_ani_frames / aniloops)) mod 1;
		
		surface_set_target(anisurf[f])
		{
			if (t = 0)
				draw_clear_alpha(c_black, 0)
				
			if (tex != null)
			{
				// Set current and next image
				var image, nextimage;
				image = aniprogress * aniframes;
				nextimage = floor(image) + 1
				if (framelist != null)
				{
					image = framelist[|floor(image) mod ds_list_size(framelist)] + frac(image)
					nextimage = framelist[|(floor(image) + 1) mod ds_list_size(framelist)]
				}
				image = image mod images
				nextimage = nextimage mod images
		
				// Draw part
				if (opaque)
					draw_box(dx, dy, blocksize, blocksize, false, c_black, 1)
			
				draw_texture_part(tex, dx, dy, 0, floor(image) * texwid, texwid, texwid)
			
				// Interpolate with next
				if (framefade)
				{
					gpu_set_blendmode_ext_sepalpha(bm_src_alpha, bm_inv_src_alpha, bm_one, bm_inv_src_alpha) // Windows only
					draw_texture_part(tex, dx, dy, 0, nextimage * texwid, blocksize, blocksize, 1, 1, c_white, frac(image))
					gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha)
				}
			}
			
			// Missing
			else
			{
				if (id != mc_res)
					draw_texture_part(mc_res.block_sheet_ani_texture[f], dx, dy,
									  (t mod block_sheet_ani_width) * block_size, (t div block_sheet_ani_width) * block_size,
									  block_size, block_size, blocksize / block_size, blocksize / block_size)
				else
					draw_missing(dx, dy, blocksize, blocksize)
			}
		}
		surface_reset_target()
	}
}
gpu_set_blendmode(bm_normal)
draw_texture_done()

// Create preview surface and get buffer
if (id = mc_res)
{
	var previewanisurf = surface_create(block_sheet_ani_width, block_sheet_ani_height);
	surface_set_target(previewanisurf)
	{
		draw_clear_alpha(c_black, 0)
		draw_surface_ext(anisurf[0], 0, 0, 1 / block_size, 1 / block_size, 0, c_white, 1)
	}
	surface_reset_target()
	
	load_assets_block_preview_ani_buffer = buffer_create(block_sheet_ani_width * block_sheet_ani_height * 4, buffer_fixed, 4)
	buffer_get_surface(load_assets_block_preview_ani_buffer, previewanisurf, 0, 0, 0)
	//surface_save(previewanisurf, "previewanisurf.png")
	//surface_free(previewanisurf)
}

// Setup texture sample positions
var samplepos, sampleposamount;
samplepos[0] = point2D(blocksize / 2, blocksize / 2)
samplepos[1] = point2D(0, blocksize / 2)
samplepos[2] = point2D(blocksize / 2, 0)
samplepos[3] = point2D(blocksize - 1, blocksize / 2)
samplepos[4] = point2D(blocksize / 2, blocksize - 1)
samplepos[5] = point2D(blocksize / 4, blocksize / 4)
sampleposamount = 6

// Find block depths (static)
buffer_current = buffer_create(surface_get_width(surf) * surface_get_height(surf) * 4, buffer_fixed, 4)
buffer_get_surface(buffer_current, surf, 0, 0, 0)
var wid = surface_get_width(surf);

block_sheet_depth_list = ds_list_create()
for (var t = 0; t < ds_list_size(mc_assets.block_texture_list); t++)
{
	if (texlist[|t] = null)
	{
		ds_list_add(block_sheet_depth_list, e_block_depth.DEPTH0)
		continue
	}
	
	// Leaves are always treated as transparent (opaque or not) to fix wind issues
	var opaque = string_contains(mc_assets.block_texture_list[|t], "leaves");
	if (opaque)
	{
		ds_list_add(block_sheet_depth_list, e_block_depth.DEPTH1)
		continue
	}
	
	var bx, by, dep;
	bx = (t mod block_sheet_width) * blocksize
	by = (t div block_sheet_width) * blocksize
	dep = e_block_depth.DEPTH0
	
	// Sample pixels
	for (var s = 0; s < sampleposamount; s++)
	{
		var spos, alpha;
		spos = samplepos[s]
		alpha = buffer_read_alpha(bx + spos[@ X], by + spos[@ Y], wid)
		
		if (alpha < 1) // Transparent
			dep = e_block_depth.DEPTH1
		
		if (alpha > 0 && alpha < 1) // Semi-transparent
		{
			dep = e_block_depth.DEPTH2
			break
		}
	}
	
	ds_list_add(block_sheet_depth_list, dep)
}
buffer_delete(buffer_current)

// Find block depths (animated)
buffer_current = buffer_create(surface_get_width(anisurf[0]) * surface_get_height(anisurf[0]) * 4, buffer_fixed, 4)
buffer_get_surface(buffer_current, anisurf[0], 0, 0, 0)
wid = surface_get_width(anisurf[0])

block_sheet_ani_depth_list = ds_list_create()
for (var t = 0; t < ds_list_size(mc_assets.block_texture_ani_list); t++)
{
	if (texanilist[|t] = null)
	{
		ds_list_add(block_sheet_ani_depth_list, e_block_depth.DEPTH0)
		continue
	}
	
	var bx, by, dep;
	bx = (t mod block_sheet_ani_width) * blocksize
	by = (t div block_sheet_ani_width) * blocksize
	dep = e_block_depth.DEPTH0
	
	// Sample
	for (var s = 0; s < sampleposamount; s++)
	{
		var spos, alpha;
		spos = samplepos[s]
		alpha = buffer_read_alpha(bx + spos[@ X], by + spos[@ Y], wid)
		
		if (alpha < 1) // Transparent
			dep = e_block_depth.DEPTH1
		
		if (alpha > 0 && alpha < 1) // Semi-transparent
		{
			dep = e_block_depth.DEPTH2
			break
		}
	}
	
	ds_list_add(block_sheet_ani_depth_list, dep)
}
buffer_delete(buffer_current)

// Clean up
for (var f = 0; f < block_sheet_ani_frames; f++)
{
	block_sheet_ani_texture[f] = texture_surface(anisurf[f])
	surface_free(anisurf[f])
}

for (var t = 0; t < ds_list_size(texlist); t++)
	if (texlist[|t] != null)
		texture_free(texlist[|t])
		
for (var t = 0; t < ds_list_size(texanilist); t++)
	if (texanilist[|t] != null)
		texture_free(texanilist[|t])

surface_free(surf)
ds_list_destroy(texlist)
ds_list_destroy(texanilist)

debug_timer_stop("res_load_pack_block_textures")