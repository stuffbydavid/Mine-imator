/// alert_show(title, text, icon, [button, buttonurl, [fadetime, [id]]])
/// @arg title
/// @arg text
/// @arg icon
/// @arg [button
/// @arg buttonurl
/// @arg [fadetime
/// @arg [id]]]

var title, text, icon, button, buttonurl, fadetime, iid;
title = argument[0]
text = argument[1]
icon = argument[2]

log("Show alert", title, text, icon)

if (argument_count > 3)
{
	button = argument[3]
	buttonurl = argument[4]
}
else
{
	button = ""
	buttonurl = ""
}

if (argument_count > 5)
	fadetime = argument[5]
else
	fadetime = null
	
if (argument_count > 6)
	iid = argument[6]
else
	iid = null

with (new(obj_alert))
{
	id.title = title
	id.text = text
	id.icon = icon
	id.button = button
	id.button_url = buttonurl
	id.fade_time = fadetime
	id.fade_start = current_time
	id.created = current_time
	id.iid = iid
	ds_list_insert(other.alert_list, 0, id)
}