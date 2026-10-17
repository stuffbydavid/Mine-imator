/// @arg name
/// @arg script
/// @arg width
/// @arg height
/// @arg block
/// @arg [custom]
/// @arg [revert]
/// @arg [closebutton]
/// @arg [closescript]

function new_popup(name, script, wid, hei, block, custom = false, revert = false, closebutton = null, closescript = null)
{
	with (new_obj(obj_popup))
	{
		self.name = name
		self.script = script
		width = wid
		height = hei

		self.block = block
		self.custom = custom
		self.revert = revert
		
		if (closebutton != null)
			close_button = closebutton
		else
			close_button = !custom
			
		close_script = closescript

		caption = text_get(name + "/caption")
		
		offset_x = 0
		offset_y = 0
		custom_height = -4
		custom_height_goal = 0
		
		return id
	}
}
