/// render_update_effects()
/// @desc Updates rendering to determine if it's done with effects

render_effects_done = true
render_effects_progress++

for (var i = render_effects_progress; i < ds_list_size(render_effects_list); i++)
{
	if (render_effects_list[|i])
	{
		render_effects_done = false
		break
	}
}