function list_item_add(name, value, caption = "", thumbnail = null, lefticon = null, righticon = null, script = null, divider = false, interact = true)
{
	with (new_obj(obj_list_item))
	{
		self.name = name
		self.value = value
		self.caption = caption
		
		self.thumbnail = thumbnail
		thumbnail_backdrop = true
		thumbnail_blend = c_white
		thumbnail_alpha = 1

		icon_left = lefticon
		actions_left = null

		icon_right = righticon
		actions_right = null
		
		self.script = script
		self.divider = divider
		self.interact = interact
		
		hover = false
		disabled = false

		hovertime = 0
		context_menu_name = ""
		context_menu_active = false
		context_menu_script = null
		context_menu_width = 0
		context_menu_height = 0

		draw_x = 0
		draw_y = 0

		indent = 0
		toggled = false

		if (list_edit != null)
		{
			ds_list_add(list_edit.item, id)
			list = list_edit
		}
		else
			list = null

		list_item_last = id

		return id
	}
}
