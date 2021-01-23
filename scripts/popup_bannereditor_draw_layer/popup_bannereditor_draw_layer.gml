/// popup_bannereditor_draw_layer(x, y, width, height, index, base)
/// @arg x
/// @arg y
/// @arg width
/// @arg height
/// @arg index
/// @arg base

var xx, yy, width, height, index, base;
var editname, mouseon, dragging, actionx, layerpattern, layercolor;
xx = argument0
yy = argument1
width = argument2
height = argument3
index = argument4
base = argument5

editname = "bannereditoreditlayer" + string(index)
mouseon = (app_mouse_box(xx, yy, width, height) || (popup_bannereditor.layer_edit = index && settings_menu_name = editname))
dragging = (popup_bannereditor.layer_move = index)
layerpattern = (base ? 1 : ds_list_find_index(minecraft_banner_pattern_list, popup_bannereditor.pattern_list_edit[|index]))
layercolor = (base ? c_minecraft_black : popup_bannereditor.pattern_color_list_edit[|index])

// Draw pattern
if (popup_bannereditor.banner_edit_preview != null)
	draw_box(xx + 4, yy + 4, 20, 40, false, popup_bannereditor.banner_edit_preview.banner_base_color, 1)

if (!base)
	draw_sprite_ext(popup_bannereditor.pattern_sprites[layerpattern], 0, xx + 4, yy + 4, 1 / popup_bannereditor.res_ratio, 1 / popup_bannereditor.res_ratio, 0, layercolor, 1)

gpu_set_blendmode_ext(bm_zero, bm_src_color)
draw_sprite_ext(popup_bannereditor.pattern_sprites[array_length_1d(popup_bannereditor.pattern_sprites) - 1], 0, xx + 4, yy + 4, (1 / popup_bannereditor.res_ratio), (1 / popup_bannereditor.res_ratio), 0, c_white, 1)
gpu_set_blendmode(bm_normal)

// Layer name
var name = (base ? text_get("bannereditorbase") : text_get("bannereditorlayer", index + 1));
draw_label(name, xx + 32, yy + height/2, fa_left, fa_middle, c_text_main, a_text_main, font_value)

actionx = xx + width - 4

// Drag layer
if (!base)
{
	var draghover = app_mouse_box(actionx - 20, yy + height/2 - 14, 20, 28);
	
	if (draghover)
	{
		mouse_cursor = cr_size_all
		
		if (mouse_move > 0 && !dragging)
		{
			popup_bannereditor.layer_move = index
			popup_bannereditor.layer_move_x = xx - mouse_x
			popup_bannereditor.layer_move_y = yy - mouse_y
			window_busy = "bannereditordraglayer"
		}
	}
	
	draw_image(spr_icons, icons.DRAGGER, actionx - 10, yy + height/2, 1, 1, c_text_tertiary, a_text_tertiary)
	
	actionx -= 24
	
	// Remove layer
	if (mouseon && !dragging)
	{
		if (draw_button_icon("bannereditorremovelayer" + string(index), actionx - 24, yy + height/2 - 14, 24, 24, false, icons.DELETE))
			popup_bannereditor.layer_remove = index
		
		actionx -= 28
	}
}

// Edit layer
if (mouseon && !dragging)
{
	if (draw_button_icon(editname, actionx - 24, yy + height/2 - 14, 24, 24, settings_menu_name = editname, icons.EDIT))
	{
		menu_settings_set(actionx - 24, yy + height/2 - 14, editname, 24)
		settings_menu_script = popup_bannereditor_edit_layer
		settings_menu_busy_prev = "popup" + popup.name
		popup_bannereditor.layer_edit = index
	}
	
	if (settings_menu_name = editname && settings_menu_ani_type != "hide")
		current_mcroani.value = true	
}
