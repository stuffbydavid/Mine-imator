/// action_setting_watermark_scale(value, add)
/// @arg value
/// @arg add

function action_setting_watermark_scale(val, add)
{
	setting_watermark_scale = setting_watermark_scale * add + val / 100
}
