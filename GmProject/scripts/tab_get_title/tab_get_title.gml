/// @desc Returns the tab title.

function tab_get_title(tab)
{
	if (tab = properties)
		return text_get("tab/project_properties")
	
	else if (tab = renderer_settings)
		return text_get("tab/renderer", text_get("render/renderer/" + (tab.renderer = e_renderer.STANDARD ? "standard" : "realistic")))
	
	else if (tab = timeline)
		return text_get("tab/timeline")
	
	else if (tab = build_tool)
		return text_get("tab/build_tool")
	
	else if (tab = object_editor)
	{
		if (obj_edit = null || !instance_exists(obj_edit))
			return ""
		switch (obj_edit.type)
		{
			case e_temp_type.CHARACTER:
				return text_get("tab/char_model", string_remove_newline(obj_edit.display_name))

			case e_temp_type.EQUIPMENT:
				return text_get("tab/equipment", string_remove_newline(obj_edit.display_name))
			
			case e_temp_type.SPECIAL_BLOCK:
			case e_temp_type.BLOCK:
				return text_get("tab/block", string_remove_newline(obj_edit.display_name))
			
			case e_temp_type.ITEM:
				return text_get("tab/item", string_remove_newline(obj_edit.display_name))
			
			case e_temp_type.MODEL_PART:
				return text_get("tab/model_part", string_remove_newline(obj_edit.display_name))
			
			case e_temp_type.PARTICLE_SPAWNER:
				return text_get("tab/particles", string_remove_newline(obj_edit.display_name))
		}
	}
	else if (tab = ground_editor)
		return text_get("tab/ground")
	
	else if (tab = timeline_editor)
	{
		var name = "";
		if (tl_edit)
		{
			name = string_remove_newline(tl_edit.display_name)
			if (tl_edit_amount > 1)
				name += "..."
		}
		return text_get("tab/timeline_editor", name)
	}
	else if (tab = frame_editor)
	{
		var name, frametab, framesel;
		name = ""
		frametab = "tab/frame_editor_single"
		framesel = round(timeline_marker)
		
		if (tl_edit)
		{
			name = string_remove_newline(tl_edit.display_name)
			if (!tl_edit.animated && tl_edit_amount = 1)
				return name
			
			if (tl_edit_amount > 1)
			{
				name += "..."
				
				var framecount = 0;
				with (obj_keyframe)
					if (selected)
						framecount++
				
				frametab = "tab/frame_editor_multi"
				framesel = framecount
			}
			else if (tl_edit.keyframe_select_amount > 1)
			{
				frametab = "tab/frame_editor_multi"
				framesel = round(tl_edit.keyframe_select_amount)
			}
			else if (tl_edit.keyframe_select_amount = 1)
				framesel = round(tl_edit.keyframe_select.position)
		}
		
		return text_get("tab/frame_editor", name, text_get(frametab, string(framesel)))
	}
	else if (tab = settings)
		return text_get("tab/settings")
	
	return ""
}
