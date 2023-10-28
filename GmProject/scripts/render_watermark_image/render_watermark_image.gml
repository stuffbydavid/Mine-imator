/// render_watermark_image([width, height])
/// @arg [width
/// @arg height]

function render_watermark_image(draw_width = undefined, draw_height = undefined)
{
	var watermark_x, watermark_y, watermark_width, watermark_height;
	watermark_x = 0
	watermark_y = 0
	
	if (is_undefined(draw_width))
	{
		draw_width = render_width
		draw_height = render_height
	}
	
	var sprite, scale, opacity, halign, valign, padding, padx, pady;
	padx = 0
	pady = 0
	
	if (setting_watermark_custom)
	{
		scale = setting_watermark_scale
		opacity = setting_watermark_opacity
		halign = setting_watermark_halign
		valign = setting_watermark_valign
		padding = setting_watermark_padding
		
		if (setting_watermark_image != null)
			sprite = setting_watermark_image
		else
			sprite = spr_watermark
	}
	else
	{
		scale = .33
		opacity = 1
		halign = "right"
		valign = "bottom"
		padding = 0
		sprite = spr_watermark
	}
	
	watermark_width = sprite_get_width(sprite)
	watermark_height = sprite_get_height(sprite)
	
	if (watermark_width > watermark_height)
		scale *= draw_width/watermark_width
	else
		scale *= draw_height/watermark_height
	
	gpu_set_texfilter(true)
	
	watermark_x = draw_width - (watermark_width/2 * scale)
	watermark_y = draw_height - (watermark_height/2 * scale)
	
	switch (halign)
	{
		case "left":
		{
			watermark_x = watermark_width/2 * scale
			padx = draw_width * padding
			break
		}
		
		case "center":
		{
			watermark_x = draw_width/2;
			break
		}
		
		case "right":
		{
			watermark_x = draw_width - (watermark_width/2 * scale)
			padx = -(draw_width * padding)
			break
		}
	}
	
	switch (valign)
	{
		case "top":
		{
			watermark_y = watermark_height/2 * scale
			pady = (draw_height * padding)
			break
		}
		case "center":
		{
			watermark_y = draw_height/2
			break
		}
		case "bottom":
		{
			watermark_y = draw_height - (watermark_height/2 * scale)
			pady = -(draw_height * padding)
			break
		}
	}
	
	watermark_x -= (watermark_width/2) * scale
	watermark_y -= (watermark_height/2) * scale
	
	watermark_x += padx
	watermark_y += pady
	
	gpu_set_texfilter(true)
	
	draw_image(sprite, 0, round(watermark_x), round(watermark_y), scale, scale, c_white, opacity)
	
	gpu_set_blendmode_ext_sepalpha(bm_src_color, bm_one, bm_one, bm_one)
	draw_image(sprite, 0, round(watermark_x), round(watermark_y), scale, scale, c_black, opacity)
	gpu_set_blendmode(bm_normal)
	
	gpu_set_texfilter(false)
}
