/// render_alpha_hashing_warning(alpha_mode)
/// @arg alpha_mode

function render_alpha_hashing_warning(alpha_mode)
{
	var realisticpreset = render_preset_map[?project_render_preset[e_renderer.REALISTIC]];
	if (realisticpreset.renderer[e_renderer.REALISTIC].alpha_hashing)
		return;

	if (alpha_mode = e_alpha_mode.DEFAULT)
		alpha_mode = project_render_alpha_mode

	if (alpha_mode = e_alpha_mode.HASHED)
		draw_tooltip_label("renderalphahashingwarning", icons.WARNING_TRIANGLE, e_toast.WARNING)
}
