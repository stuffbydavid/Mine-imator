/// list_update_width(list)
/// @arg list
/// @desc Calculates width of list's components and text

function list_update_width(list)
{
	var maxwidthleft, maxwidthright, width, item, togglewid;
	maxwidthleft = 0
	maxwidthright = 0
	width = 0
	item = null
	togglewid = 0
	list.toggled = false
	
	// Left side
	draw_set_font(font_value)
	
	for (var i = 0; i < ds_list_size(list.item); i++)
	{
		item = list.item[|i]
		width = 4 + item.indent
		
		// Thumbnail(Assuming height of list is 36)
		if (item.thumbnail)
			width += 24
		
		// Left actions
		if (item.actions_left != null)
		{
			for (var j = 0; j < ds_list_size(item.actions_left); j += 6)
				width += 20
		}
		
		// Left icon
		if (item.icon_left)
			width += 24 + 4
		
		// Text
		width += string_width(item.name) + 8
		
		maxwidthleft = max(width, maxwidthleft)
	}
	
	// Right side
	draw_set_font(font_caption)
	
	for (var i = 0; i < ds_list_size(list.item); i++)
	{
		item = list.item[|i]
		width = 0
		
		// Right actions
		if (item.actions_right != null)
		{
			for (var j = 0; j < ds_list_size(item.actions_right); j += 6)
				width += 20
		}
		
		// Right icon
		if (item.icon_right)
			width += 24 + 4
		
		// Tick
		if (item.toggled)
		{
			togglewid = 24 + 4
			list.toggled = true
		}
		
		// Caption
		if (item.caption != "")
			width += string_width(item.caption) + 8
		
		maxwidthright = max(width, maxwidthright)
	}
	
	list.width = (maxwidthleft + maxwidthright + togglewid)
}
