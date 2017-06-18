/// alert_startup()

alert_amount = 0

alert_x = 0
alert_y = 0
alert_width = 0
alert_height = 0
alpha_alpha = 1

alert_title[0] = ""
alert_text[0] = ""
alert_icon[0] = 0
alert_button[0] = ""
alert_button_url[0] = ""
alert_fadetime[0] = 0
alert_created[0] = 0
alert_iid[0] = null

alert_news_http = http_get(link_news)

closed_alerts = ds_list_create()
closed_alerts_open()
