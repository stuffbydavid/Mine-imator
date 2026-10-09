function render_pass_grid_draw(combinedsurface)
{
	var passcount, columns, rows, cellw, cellh;
	passcount = e_render_pass.ALL
	columns = ceil(sqrt(passcount))
	rows = ceil(passcount / columns)
	cellw = render_width / columns
	cellh = render_height / rows
	
	render_set_projection_ortho(0, 0, render_width, render_height, 0)
	draw_set_font(app.font_label)
	draw_set_halign(fa_left)
	draw_set_valign(fa_top)
	
	for (var pass = e_render_pass.COMBINED; pass < e_render_pass.ALL; pass++)
	{
		var surf, xx, yy;
		surf = (pass = e_render_pass.COMBINED ? combinedsurface : render_pass_surfs[pass])
		xx = (pass mod columns) * cellw
		yy = (pass div columns) * cellh
		
		if (surface_exists(surf))
			render_pass_draw(pass, surf, xx, yy, cellw, cellh)
		
		draw_set_alpha(.7)
		draw_set_color(c_black)
		draw_rectangle(xx, yy, xx + cellw, yy + 22, false)
		draw_set_alpha(1)
		draw_set_color(c_white)
		draw_text(xx + 4, yy + 3, text_get("view/renderer/pass/" + render_pass_list[|pass]))
	}
	
	draw_set_halign(fa_left)
	draw_set_valign(fa_top)
	draw_set_alpha(1)
	draw_set_color(c_white)
}
