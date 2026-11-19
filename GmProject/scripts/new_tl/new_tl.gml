/// @arg type

function new_tl(tlype)
{
	with (new_obj(obj_timeline))
	{
		type = tlype
		has_temp = type_is_templated(type)
		animated = type_is_animated(type)
		
		if (type = e_tl_type.EQUIPMENT)
			glint_mode = e_glint.ARMOR
		
		if (type = e_tl_type.TEXT)
			value[e_value.TEXT] = text_get("frame_editor/text/sample")
		
		if (type_is_light(type))
			tl_light_check_shadows()
		
		tl_update()
		
		tl_set_parent_root()
		tl_value_spawn()
		
		return id
	}
}
