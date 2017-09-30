/// toolbar_draw_alerts()

var busy;

if (ds_list_size(alert_list) = 0)
	return 0
	
busy = window_busy
if (popup && busy = "popup" + popup.name)
	window_busy = ""

draw_alert(0)
	
window_busy = busy
