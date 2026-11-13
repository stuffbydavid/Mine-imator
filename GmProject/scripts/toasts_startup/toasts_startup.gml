function toasts_startup()
{
	toast_list = ds_list_create()
	toast_amount = 0
	
	toast_script = null
	toast_script_value = null
	toast_mouseon = false
	toast_last = null
	
	var newsurl = link_news;
	newsurl += "?version=" + mineimator_version
	newsurl += "&platform=" + string(platform_get())
	newsurl += "&os=" + string(os_get())
	http_alert_news = http_get(newsurl)
}
