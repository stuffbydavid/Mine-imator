/// alert_startup()

alert_x = 0
alert_y = 0
alert_width = 0
alert_height = 0
alert_alpha = 1

alert_list = ds_list_create()
http_alert_news = http_get(link_news)
