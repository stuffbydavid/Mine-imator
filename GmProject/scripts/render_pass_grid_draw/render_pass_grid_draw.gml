/// render_pass_grid_draw(combinedsurf)
/// @arg combinedsurf

function render_pass_grid_draw(combinedsurf)
{
	var passcount = e_render_pass.ALL
	var columns = ceil(sqrt(passcount))
	var rows = ceil(passcount / columns)
	var cellw = render_width / columns
	var cellh = render_height / rows
	
	render_set_projection_ortho(0, 0, render_width, render_height, 0)
	draw_set_font(app.font_label)
	draw_set_halign(fa_left)
	draw_set_valign(fa_top)
	
	for (var pass = e_render_pass.COMBINED; pass < e_render_pass.ALL; pass++)
	{
		var surf = (pass = e_render_pass.COMBINED ? combinedsurf : render_pass_surfs[pass])
		var xx = (pass mod columns) * cellw
		var yy = (pass div columns) * cellh
		
		if (surface_exists(surf))
			render_pass_draw(pass, surf, xx, yy, cellw, cellh)
		
		draw_set_alpha(.7)
		draw_set_color(c_black)
		draw_rectangle(xx, yy, xx + cellw, yy + 22, false)
		draw_set_alpha(1)
		draw_set_color(c_white)
		draw_text(xx + 4, yy + 3, text_get("viewrendererpass" + render_pass_list[|pass]))
	}
	
	draw_set_halign(fa_left)
	draw_set_valign(fa_top)
	draw_set_alpha(1)
	draw_set_color(c_white)
}
