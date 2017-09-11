/// render_watermark_image()

var scale = (render_width * 0.33) / 1000;

gpu_set_texfilter(true)
gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha)
draw_image(spr_watermark, 0, render_width, render_height, scale, scale)
gpu_set_blendmode(bm_normal)
gpu_set_texfilter(false)
