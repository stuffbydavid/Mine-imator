/// action_setting_render_watermark_alpha(value, add)
/// @arg value
/// @arg add

function action_setting_render_watermark_alpha(val, add)
{
	setting_render_watermark_alpha = setting_render_watermark_alpha * add + val / 100
}
