/// view_toggle_render()

view_render = !view_render
if (view_render)
	view_render_real_time = true
else
	render_free()
