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

for (var a = alert_amount; a > 0; a--)
{
	alert_title[a] = alert_title[a - 1]
	alert_text[a] = alert_text[a - 1]
	alert_icon[a] = alert_icon[a - 1]
	alert_button[a] = alert_button[a - 1]
	alert_button_url[a] = alert_button_url[a - 1]
	alert_fadetime[a] = alert_fadetime[a - 1]
	alert_fadestart[a] = alert_fadestart[a - 1]
	alert_created[a] = alert_created[a - 1]
	alert_iid[a] = alert_iid[a - 1]
}
alert_amount++

alert_title[0] = title
alert_text[0] = text
alert_icon[0] = icon
alert_button[0] = button
alert_button_url[0] = buttonurl
alert_fadetime[0] = fadetime
alert_fadestart[0] = current_time
alert_created[0] = current_time
alert_iid[0] = iid
