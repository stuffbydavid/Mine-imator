/// alert_close(id)
/// @arg id

var n = argument0;

if (alert_iid[n])
	ds_list_add(closed_alerts, alert_iid[n])

alert_amount--
for (var a = n; a < alert_amount; a++)
{
	alert_title[a] = alert_title[a + 1]
	alert_text[a] = alert_text[a + 1]
	alert_icon[a] = alert_icon[a + 1]
	alert_button[a] = alert_button[a + 1]
	alert_button_url[a] = alert_button_url[a + 1]
	alert_fadetime[a] = alert_fadetime[a + 1]
	alert_fadestart[a] = alert_fadestart[a + 1]
	alert_created[a] = alert_created[a + 1]
	alert_iid[a] = alert_iid[a + 1]
}
