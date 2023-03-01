/// action_setting_watermark_padding(value, add)
/// @arg value
/// @arg add

function action_setting_watermark_padding(val, add)
{
	setting_watermark_padding = setting_watermark_padding * add + val / 100
}
