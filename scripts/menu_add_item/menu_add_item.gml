/// menu_add_item(value, text, [texture, [icon, [script]]])
/// @arg value
/// @arg text
/// @arg [texture
/// @arg [icon
/// @arg [script]]]
/// @desc Adds a new item to the dropdown menu.

var item = new(obj_menuitem);
item.value = argument[0]
item.text = string_remove_newline(argument[1])

if (argument_count > 2)
	item.tex = argument[2]
else
	item.tex = null

if (argument_count > 3)
	item.icon = argument[3]
else
	item.icon = null
	
if (argument_count > 4)
	item.script = argument[4]
else
	item.script = null

app.menu_item[app.menu_amount] = item
app.menu_amount++
