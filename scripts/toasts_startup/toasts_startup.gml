/// toast_startup()

toast_list = ds_list_create()
toast_amount = 0

toast_script = null
toast_script_value = null
toast_mouseon = false
toast_last = null

http_alert_news = http_get(link_news)

// TODO: REMOVE
alert_x = 0
alert_y = 0
alert_width = 0
alert_height = 0
alert_alpha = 1

alert_list = ds_list_create()
http_alert_news = http_get(link_news)
