/// render_watermark_image()

var scale = (render_width * 0.33) / 1000;

gpu_set_texfilter(true)
draw_image(spr_watermark, 0, render_width, render_height, scale, scale)
gpu_set_texfilter(false)
