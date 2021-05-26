/// action_setting_watermark_alpha(value, add)
/// @arg value
/// @arg add

function action_setting_watermark_alpha(val, add)
{
	setting_watermark_alpha = setting_watermark_alpha * add + val / 100
}
