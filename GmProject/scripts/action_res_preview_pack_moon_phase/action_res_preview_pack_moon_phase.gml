/// action_res_preview_pack_moon_phase(phase)
/// @arg phase

function action_res_preview_pack_moon_phase(phase)
{
	res_preview.pack_moon_phase = phase
	res_preview.update = true
	res_preview.reset_view = true
}
