/// @desc Updates rendering to determine if it's done with effects.

function render_fx_update()
{
	render_fx_done = true
	render_fx_progress++
	
	for (var i = render_fx_progress; i < ds_list_size(render_fx_list); i++)
	{
		if (render_fx_list[|i])
		{
			render_fx_done = false
			break
		}
	}
}
