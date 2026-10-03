/// @arg [width]
/// @arg [height]

function render_watermark_image(wid = null, hei = null)
{
	var watermarkx, watermarky, watermarkwid, watermarkhei;
	watermarkx = 0
	watermarky = 0
	
	if (wid = null || hei = null)
	{
		wid = render_width
		hei = render_height
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
	
	watermarkwid = sprite_get_width(sprite)
	watermarkhei = sprite_get_height(sprite)
	
	if (watermarkwid > watermarkhei)
		scale *= wid/watermarkwid
	else
		scale *= hei/watermarkhei
	
	gpu_set_texfilter(true)
	
	watermarkx = wid - (watermarkwid/2 * scale)
	watermarky = hei - (watermarkhei/2 * scale)
	
	switch (halign)
	{
		case "left":
		{
			watermarkx = watermarkwid/2 * scale
			padx = wid * padding
			break
		}
		
		case "center":
		{
			watermarkx = wid/2
			break
		}
		
		case "right":
		{
			watermarkx = wid - (watermarkwid/2 * scale)
			padx = -(wid * padding)
			break
		}
	}
	
	switch (valign)
	{
		case "top":
		{
			watermarky = watermarkhei/2 * scale
			pady = (hei * padding)
			break
		}
		case "center":
		{
			watermarky = hei/2
			break
		}
		case "bottom":
		{
			watermarky = hei - (watermarkhei/2 * scale)
			pady = -(hei * padding)
			break
		}
	}
	
	watermarkx -= (watermarkwid/2) * scale
	watermarky -= (watermarkhei/2) * scale
	
	watermarkx += padx
	watermarky += pady
	
	gpu_set_texfilter(true)
	
	draw_image(sprite, 0, round(watermarkx), round(watermarky), scale, scale, c_white, opacity)
	
	gpu_set_blendmode_ext_sepalpha(bm_src_color, bm_one, bm_one, bm_one)
	draw_image(sprite, 0, round(watermarkx), round(watermarky), scale, scale, c_black, opacity)
	gpu_set_blendmode(bm_normal)
	
	gpu_set_texfilter(false)
}
