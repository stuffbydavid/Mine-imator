/// minecraft_assets_create_block_previews()
/// @desc Creates block previews (single color for top-down and cross-section view) for the world importer.

var statecolormap = ds_map_create()

with (obj_block_load_state_file)
{
	// Continue if previously set or has no model objects
	if (!is_undefined(statecolormap[?name]) || is_undefined(state_id_map[?0]))
		continue
		
	// Choose first model object from multi-part
	var modelobj = state_id_map[?0];
	if (is_array(modelobj))
		modelobj = modelobj[0]
		
	// Continue if no models
	if (modelobj.model_amount = 0)
		continue
		
	// Pick the preview color from the first found render model of the default state
	with (modelobj.model[0])
		statecolormap[?other.name] = array(preview_color_zp, preview_alpha_zp, preview_color_yp, preview_alpha_yp) // Top-down color, cross-section color
}

// Wave and lava
buffer_current = load_assets_block_preview_ani_buffer

var slot, px, py, waterpcolor, waterpalpha, lavapcolor, lavapalpha;

slot = mc_assets.block_liquid_slot_map[?"water"]
px = slot mod block_sheet_ani_width
py = slot div block_sheet_ani_width
waterpcolor = buffer_read_color(px, py, block_sheet_ani_width)
waterpcolor = color_multiply(waterpcolor, mc_res.color_water)
waterpalpha = power(buffer_read_alpha(px, py, block_sheet_ani_width), 2)

slot = mc_assets.block_liquid_slot_map[?"lava"]
px = slot mod block_sheet_ani_width
py = slot div block_sheet_ani_width
lavapcolor = buffer_read_color(px, py, block_sheet_ani_width)
lavapalpha = buffer_read_alpha(px, py, block_sheet_ani_width)

statecolormap[?"water"] = array(waterpcolor, waterpalpha, waterpcolor, waterpalpha)
statecolormap[?"lava"] = array(lavapcolor, lavapalpha, lavapcolor, lavapalpha)

// Save to file
log("Saving block previews", block_preview_file)

json_save_start(block_preview_file)
json_save_object_start()

var key = ds_map_find_first(statecolormap);
while (!is_undefined(key))
{
	var colors = statecolormap[?key];
	if (colors[0] != null || colors[2] != null)
	{
		json_save_object_start(key)
		
		if (colors[0] > null)
		{
			json_save_var_color("Y", colors[0])
			if (colors[1] < 1)
				json_save_var("Y_alpha", colors[1])
		}
		
		if (colors[2] > null)
		{
			json_save_var_color("Z", colors[2])
			if (colors[3] < 1)
				json_save_var("Z_alpha", colors[3])
		}
		
		json_save_object_done()
	}
	key = ds_map_find_next(statecolormap, key)
}

json_save_object_done()
json_save_done()