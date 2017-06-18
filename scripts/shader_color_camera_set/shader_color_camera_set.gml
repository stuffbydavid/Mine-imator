/// shader_color_camera_set(camera)
/// @arg camera

var cam = argument0;
var uBrightness = shader_get_uniform(shader_color_camera, "uBrightness"), 
    uAlpha = shader_get_uniform(shader_color_camera, "uAlpha"), 
    uRGBAdd = shader_get_uniform(shader_color_camera, "uRGBAdd"), 
    uRGBSub = shader_get_uniform(shader_color_camera, "uRGBSub"), 
    uRGBMul = shader_get_uniform(shader_color_camera, "uRGBMul"), 
    uHSBAdd = shader_get_uniform(shader_color_camera, "uHSBAdd"), 
    uHSBSub = shader_get_uniform(shader_color_camera, "uHSBSub"), 
    uHSBMul = shader_get_uniform(shader_color_camera, "uHSBMul"), 
    uMixColor = shader_get_uniform(shader_color_camera, "uMixColor");

shader_set(shader_color_camera)

// Color
shader_set_uniform_f(uBrightness, cam.value[BRIGHTNESS])
shader_set_uniform_f(uAlpha, cam.value[ALPHA])
shader_set_uniform_color(uRGBAdd, cam.value[RGBADD], 1)
shader_set_uniform_color(uRGBSub, cam.value[RGBSUB], 1)
shader_set_uniform_color(uRGBMul, cam.value[RGBMUL], 1)
shader_set_uniform_color(uHSBAdd, cam.value[HSBADD], 1)
shader_set_uniform_color(uHSBSub, cam.value[HSBSUB], 1)
shader_set_uniform_color(uHSBMul, cam.value[HSBMUL], 1)
shader_set_uniform_color(uMixColor, cam.value[MIXCOLOR], cam.value[MIXPERCENT])
