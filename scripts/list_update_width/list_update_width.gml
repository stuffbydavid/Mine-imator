/// list_update_width(list)
/// @arg list
/// @desc Calculates width of list's components and text

var list, maxwidthleft, maxwidthright, width, item;
list = argument0
maxwidthleft = 0
maxwidthright = 0
width = 0
item = null

for (var i = 0; i < ds_list_size(list.item); i++)
{
	item = list.item[|i]
	width = 12

	// Thumbnail(Assuming height of list is 36)
	if (item.thumbnail)
		width += 32

	// Left actions
	if (item.actions_left != null)
	{
		for (var j = 0; j < ds_list_size(item.actions_left); j += 6)
			width += 24
	}
	
	// Left icon
	if (item.icon_left)
		width += 24

	// Text
	draw_set_font(font_value)
	width += string_width(item.name) + 8
	
	maxwidthleft = max(width, maxwidthleft)
}

for (var i = 0; i < ds_list_size(list.item); i++)
{
	item = list.item[|i]
	width = 12

	// Right actions
	if (item.actions_right != null)
	{
		for (var j = 0; j < ds_list_size(item.actions_right); j += 6)
			width += 24
	}
	
	// Right icon
	if (item.icon_right)
		width += 24
	
	// Caption
	if (item.caption != "")
	{
		draw_set_font(font_caption)
		width += string_width(item.caption) + 4
	}
	
	maxwidthright = max(width, maxwidthright)
}

list.width = maxwidthleft + maxwidthright
