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
	tab_control(32)
	draw_button_menu("timelineeditorparent", e_menu.TIMELINE, dx, dy, dw, 32, par, text, action_tl_parent)
	tab_next()
	
	if (!tl_edit.value_type[e_value_type.HIERARCHY])
		return 0
	
	// Lock to bended half
	if (par != app && par.type = e_temp_type.BODYPART && par.model_part != null && par.model_part.bend_part != null)
	{
		var partname = array("right", "left", "front", "back", "upper", "lower");
		tab_control_checkbox()
		draw_checkbox("timelineeditorlockbend" + partname[par.model_part.bend_part], dx, dy, tl_edit.lock_bend, action_tl_lock_bend)
		tab_next()
	}
}
	
if (par != app)
{
	tab_control(18)
	draw_label(text_get("timelineeditorinherit"), dx, dy)
	tab_next()
	
	// Draw checkboxes
	var checkboxes, checkboxesmod;
	checkboxes = 0
	checkboxesmod = 0
	
	for (var i = 0; i < 11; i++)
	{
		if (checkboxesmod = 0)
			tab_control_checkbox()
		
		switch (i)
		{
			case 0: draw_checkbox("timelineeditorinheritposition", dx + floor(dw * 0.33 * checkboxesmod), dy, tl_edit.inherit_position, action_tl_inherit_position); break
			
			case 1:
			{
				if (tl_edit.value_type[e_value_type.ROTATION])
				{
					draw_checkbox("timelineeditorinheritrotation", dx + floor(dw * 0.33 * checkboxesmod), dy, tl_edit.inherit_rotation, action_tl_inherit_rotation)
					break
				}
				else
					continue
			}
			
			case 2: draw_checkbox("timelineeditorinheritrotpoint", dx + floor(dw * 0.33 * checkboxesmod), dy, tl_edit.inherit_rot_point, action_tl_inherit_rot_point) break
			
			case 3:
			{
				if (tl_edit.value_type[e_value_type.SCALE])
				{
					draw_checkbox("timelineeditorinheritscale", dx + floor(dw * 0.33 * checkboxesmod), dy, tl_edit.inherit_scale, action_tl_inherit_scale)
					break
				}
				else
					continue
			}
			
			case 4:
			{
				if (tl_edit.value_type[e_value_type.COLOR])
				{
					draw_checkbox("timelineeditorinheritalpha", dx + floor(dw * 0.33 * checkboxesmod), dy, tl_edit.inherit_alpha, action_tl_inherit_alpha)
					break
				}
				else
					continue
			}
			
			case 5:
			{
				if (tl_edit.value_type[e_value_type.COLOR])
				{
					draw_checkbox("timelineeditorinheritcolor", dx + floor(dw * 0.33 * checkboxesmod), dy, tl_edit.inherit_color, action_tl_inherit_color)
					break
				}
				else
					continue
			}
			
			case 6: draw_checkbox("timelineeditorinheritvisibility", dx + floor(dw * 0.33 * checkboxesmod), dy, tl_edit.inherit_visibility, action_tl_inherit_visibility); break
			
			case 7: draw_checkbox("timelineeditorinheritbend", dx + floor(dw * 0.33 * checkboxesmod), dy, tl_edit.inherit_bend, action_tl_inherit_bend); break
			
			case 8: 
			{
				if (tl_edit.value_type[e_value_type.TEXTURE])
				{
					draw_checkbox("timelineeditorinherittexture", dx + floor(dw * 0.33 * checkboxesmod), dy, tl_edit.inherit_texture, action_tl_inherit_texture)
					break
				}
				else
					continue
			}
			
			case 9: 
			{
				if (!tl_edit.value_type[e_value_type.CAMERA])
				{
					draw_checkbox("timelineeditorinheritglowcolor", dx + floor(dw * 0.33 * checkboxesmod), dy, tl_edit.inherit_glow_color, action_tl_inherit_glow_color)
					break
				}
				else
					continue
			}
			
			case 10: draw_checkbox("timelineeditorinheritselect", dx + floor(dw * 0.33 * checkboxesmod), dy, tl_edit.inherit_select, action_tl_inherit_select); break
		}
		
		checkboxes++
		checkboxesmod = checkboxes mod 3
		
		if (checkboxesmod = 0)
			tab_next()
	}
	
	if (checkboxesmod != 0)
		tab_next()
			
			
	// Scale mode
	if (tl_edit.value_type[e_value_type.SCALE] && tl_edit.inherit_scale)
	{
		tab_control_checkbox()
		draw_label(text_get("timelineeditorscalemode") + ":", dx, dy)
		draw_radiobutton("timelineeditorscalemoderesize", dx + floor(dw * 0.25), dy, 1, tl_edit.scale_resize = 1, action_tl_scale_resize)
		draw_radiobutton("timelineeditorscalemodestretch", dx + floor(dw * 0.5), dy, 0, tl_edit.scale_resize = 0, action_tl_scale_resize)
		tab_next()
	}
}
