/// render_watermark_image([width, height])
/// @arg [width
/// @arg height]

function render_watermark_image()
{
	var draw_width, draw_height, scale, watermark_x, watermark_y, watermark_width, watermark_height;
	draw_width = render_width
	draw_height = render_height
	
	if (argument_count > 0)
	{
		draw_width = argument[0]
		draw_height = argument[1]
	}
	
	scale = ((draw_width * 0.33) / 1000)
	watermark_x = 0
	watermark_y = 0
	watermark_width = sprite_get_width(spr_watermark)
	watermark_height = sprite_get_height(spr_watermark)
	
	gpu_set_texfilter(true)
	
	watermark_x = draw_width - (watermark_width/2 * scale)
	watermark_y = draw_height - (watermark_height/2 * scale)
	
	/*
	var anchorx, anchory;
	anchorx = "right"
	anchory = "bottom"
	
	switch (setting_watermark_anchor_x)
	{
		case "left":
			watermark_x = watermark_width/2 * scale;
			break;
		case "center":
			watermark_x = draw_width/2
			break;
		case "right":
			watermark_x = draw_width - (watermark_width/2 * scale)
			break;
	}
	
	switch (setting_watermark_anchor_y)
	{
		case "top":
			watermark_y = watermark_height/2 * scale;
			break;
		case "center":
			watermark_y = draw_height/2
			break;
		case "bottom":
			watermark_y = draw_height - (watermark_height/2 * scale)
			break;
	}
	*/
	
	gpu_set_texfilter(true)
	
	draw_image(spr_watermark, 0, round(watermark_x), round(watermark_y), scale, scale, c_white, 1)
	
	gpu_set_blendmode_ext_sepalpha(bm_src_color, bm_one, bm_one, bm_one)
	draw_image(spr_watermark, 0, round(watermark_x), round(watermark_y), scale, scale, c_black, 1)
	gpu_set_blendmode(bm_normal)
	
	gpu_set_texfilter(false)
}
