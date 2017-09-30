/// alert_startup()

alert_x = 0
alert_y = 0
alert_width = 0
alert_height = 0
alert_alpha = 1

alert_list = ds_list_create()
alert_news_http = http_get(link_news)

closed_alert_list = ds_list_create()