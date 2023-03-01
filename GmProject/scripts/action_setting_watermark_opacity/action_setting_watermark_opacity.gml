/// action_setting_watermark_opacity(value, add)
/// @arg value
/// @arg add

function action_setting_watermark_opacity(val, add)
{
	setting_watermark_opacity = setting_watermark_opacity * add + val / 100
}
