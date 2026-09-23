/// draw_composition_guide(x, y, width, height, alpha)
/// @arg x
/// @arg y
/// @arg width
/// @arg height
/// @arg alpha

function draw_composition_guide(xx, yy, wid, hei, alpha = 0.8)
{
    var col = c_white;
    var a   = alpha;

    var cx = xx + wid * 0.5;
    var cy = yy + hei * 0.5;
	
    switch (project_composition_guide)
    {
        
        case e_composition_guide.RULE_OF_THIRDS:
	        var cw = wid / project_grid_columns;
	        var ch = hei / project_grid_rows;

	        for (var i = 1; i < project_grid_columns; i++)
	            draw_line_ext(xx + cw * i, yy, xx + cw * i, yy + hei, col, a);

	        for (var j = 1; j < project_grid_rows; j++)
	            draw_line_ext(xx, yy + ch * j, xx + wid, yy + ch * j, col, a);
			break;
        
        case e_composition_guide.RADIAL:
            draw_line_ext(cx, cy, xx, yy, col, a);
            draw_line_ext(cx, cy, xx + wid, yy, col, a);
            draw_line_ext(cx, cy, xx, yy + hei, col, a);
            draw_line_ext(cx, cy, xx + wid, yy + hei, col, a);

            draw_line_ext(cx, cy, xx, cy, col, a);
            draw_line_ext(cx, cy, xx + wid, cy, col, a);
            draw_line_ext(cx, cy, cx, yy, col, a);
            draw_line_ext(cx, cy, cx, yy + hei, col, a);
			break;

		case e_composition_guide.TRIANGLE:
			// Main diagonal
			draw_line_ext(xx, yy, xx + wid, yy + hei, col, a);
			
			// Perpendicular to (wid, 0)
			var px = (wid * wid * wid) / (wid * wid + hei * hei);
			var py = (hei * wid * wid) / (wid * wid + hei * hei);
			draw_line_ext(xx + wid, yy, xx + px, yy + py, col, a);
			
			// Perpendicular to (0, hei)
			var px2 = (wid * hei * hei) / (wid * wid + hei * hei);
			var py2 = (hei * hei * hei) / (wid * wid + hei * hei);
			draw_line_ext(xx, yy + hei, xx + px2, yy + py2, col, a);
			break;

        case e_composition_guide.CIRCULAR:
			// Concentric circles/ovals
			var cnt = project_grid_rows;
			for (var i = 1; i <= cnt; i++)
			{
				var rx = (wid / 2) * (i / cnt);
				var ry = (hei / 2) * (i / cnt);
				// We don't have draw_ellipse_ext, but we can use draw_circle_ext if it supports non-uniform scaling or just draw it as a circles.
				// Actually, draw_circle_ext might not support ellipses easily.
				// Let's check draw_circle_ext implementation if it exists.
				// If not, I'll just use 32 segments or so.
				var detail = 64;
				var px, py, ox, oy;
				for (var j = 0; j <= detail; j++)
				{
					var angle = (j / detail) * 360;
					px = cx + lengthdir_x(rx, angle);
					py = cy + lengthdir_y(ry, angle);
					if (j > 0)
						draw_line_ext(ox, oy, px, py, col, a);
					ox = px;
					oy = py;
				}
			}
			break;
    }
}