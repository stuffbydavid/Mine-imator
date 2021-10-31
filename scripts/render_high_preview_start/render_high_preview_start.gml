/// render_high_preview_start()

function render_high_preview_start()
{
	if (!render_high_preview)
		return 0
	
	render_high_preview_width = render_width
	render_high_preview_height = render_height
	render_width = floor(render_width/2) + ceil(frac(render_width/2))
	render_height = floor(render_height/2) + ceil(frac(render_height/2))
}