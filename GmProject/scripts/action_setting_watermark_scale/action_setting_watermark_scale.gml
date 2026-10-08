function action_setting_watermark_scale(value, add)
{
	setting_watermark_scale = setting_watermark_scale * add + value / 100
	
	view_changed()
}
