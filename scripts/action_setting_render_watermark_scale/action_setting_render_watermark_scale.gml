/// action_setting_render_watermark_scale(value, add)
/// @arg value
/// @arg add

function action_setting_render_watermark_scale(val, add)
{
	setting_render_watermark_scale = setting_render_watermark_scale * add + val / 100
}
