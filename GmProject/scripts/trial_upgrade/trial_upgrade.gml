/// @arg key

function trial_upgrade(key)
{
	key_current = key
	key_current_date = date_current_datetime()
	key_expired = false
	key_expired_dismissed = false
	
	key_save()
	
	trial_version = false
	popup_exportimage.watermark = false
	popup_exportmovie.watermark = false
	settings_save()
	
	toast_new(e_toast.POSITIVE, text_get("alert/upgraded"))
}
