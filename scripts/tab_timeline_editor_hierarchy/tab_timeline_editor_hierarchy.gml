/// tab_timeline_editor_hierarchy()
	
var par = tl_edit.parent;

if (par = timeline_move_obj)
	par = tl_edit.move_parent

if (tl_edit.part_of = null)
{
	var text;
	
	// Parent
	if (par = app)
		text = text_get("timelinenone")
	else
		text = string_remove_newline(par.display_name)
	
	tab_control_menu()
	draw_button_menu("timelineeditorparent", e_menu.TIMELINE, dx, dy, dw, 24, par, text, action_tl_parent)
	tab_next()
	
	if (!tl_edit.value_type[e_value_type.HIERARCHY])
		return 0
	
	// Lock to bended half
	if (par != app && par.type = e_temp_type.BODYPART && par.model_part != null && par.model_part.bend_part != null)
	{
		var partname = array("right", "left", "front", "back", "upper", "lower");
		tab_control_switch()
		draw_switch("timelineeditorlockbend" + partname[par.model_part.bend_part], dx, dy, tl_edit.lock_bend, action_tl_lock_bend, true)
		tab_next()
	}
}
	
if (par != app)
{
	tab_control(20)
	draw_label(text_get("timelineeditorinherit"), dx, dy + 10, fa_left, fa_middle, c_text_secondary, a_text_secondary)
	tab_next()
	
	tab_set_collumns(true, floor(content_width/150))
	
	// Position
	tab_control_checkbox()
	draw_checkbox("timelineeditorinheritposition", dx, dy, tl_edit.inherit_position, action_tl_inherit_position)
	tab_next()
	
	// Rotation
	if (tl_edit.value_type[e_value_type.ROTATION])
	{
		tab_control_checkbox()
		draw_checkbox("timelineeditorinheritrotation", dx, dy, tl_edit.inherit_rotation, action_tl_inherit_rotation)
		tab_next()
	}
	
	// Rotation point
	tab_control_checkbox()
	draw_checkbox("timelineeditorinheritrotpoint", dx, dy, tl_edit.inherit_rot_point, action_tl_inherit_rot_point)
	tab_next()
	
	// Scale
	if (tl_edit.value_type[e_value_type.SCALE])
	{
		tab_control_checkbox()
		draw_checkbox("timelineeditorinheritscale", dx, dy, tl_edit.inherit_scale, action_tl_inherit_scale)
		tab_next()
	}
	
	// Color
	if (tl_edit.value_type[e_value_type.COLOR])
	{
		tab_control_checkbox()
		draw_checkbox("timelineeditorinheritalpha", dx, dy, tl_edit.inherit_alpha, action_tl_inherit_alpha)
		tab_next()
		
		tab_control_checkbox()
		draw_checkbox("timelineeditorinheritcolor", dx, dy, tl_edit.inherit_color, action_tl_inherit_color)
		tab_next()
	}
	
	// Visibility
	tab_control_checkbox()
	draw_checkbox("timelineeditorinheritvisibility", dx, dy, tl_edit.inherit_visibility, action_tl_inherit_visibility)
	tab_next()
	
	// Bend
	tab_control_checkbox()
	draw_checkbox("timelineeditorinheritbend", dx, dy, tl_edit.inherit_bend, action_tl_inherit_bend)
	tab_next()
	
	// Texture
	if (tl_edit.value_type[e_value_type.TEXTURE])
	{
		tab_control_checkbox()
		draw_checkbox("timelineeditorinherittexture", dx, dy, tl_edit.inherit_texture, action_tl_inherit_texture)
		tab_next()
	}
	
	// Glow color
	if (!tl_edit.value_type[e_value_type.CAMERA])
	{
		tab_control_checkbox()
		draw_checkbox("timelineeditorinheritglowcolor", dx, dy, tl_edit.inherit_glow_color, action_tl_inherit_glow_color)
		tab_next()
	}
	
	// Select
	tab_control_checkbox()
	draw_checkbox("timelineeditorinheritselect", dx, dy, tl_edit.inherit_select, action_tl_inherit_select)
	tab_next()	
	
	tab_set_collumns(false)
	
	// Scale mode
	if (tl_edit.value_type[e_value_type.SCALE] && tl_edit.inherit_scale)
	{
		tab_control_togglebutton()
		togglebutton_add("timelineeditorscalemoderesize", null, 1, tl_edit.scale_resize = 1, action_tl_scale_resize)
		togglebutton_add("timelineeditorscalemodestretch", null, 0, tl_edit.scale_resize = 0, action_tl_scale_resize)
		draw_togglebutton("timelineeditorscalemode", dx, dy)
		tab_next()
	}
}
