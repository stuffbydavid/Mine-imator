/// toast_startup()

function toasts_startup()
{
	toast_list = ds_list_create()
	toast_amount = 0
	
	toast_script = null
	toast_script_value = null
	toast_mouseon = false
	toast_last = null
	
	http_alert_news = http_get(link_news)
}
