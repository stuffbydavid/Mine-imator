/// action_lib_shape_save_map()

var fn = file_dialog_save_image(temp_edit.type);
if (fn != "")
{
	var spr;
	if (temp_edit.type = "cone")
		spr = spr_map_cone
	else if (temp_edit.type = "cube")
		spr = spr_map_cube
	else
		spr = spr_map_cylinder
		
	// Export surface
	var surf = surface_create(sprite_get_width(spr), sprite_get_height(spr));
	surface_set_target(surf)
	{
		draw_clear_alpha(c_black, 0)
		draw_sprite(spr, 0, 0, 0)
	}
	surface_reset_target()
	surface_save_lib(surf, fn)
	surface_free(surf)
}