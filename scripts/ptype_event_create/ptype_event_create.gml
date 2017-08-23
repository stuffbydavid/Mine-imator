/// ptype_event_create()
/// @desc Create event of obj_particle_type.

save_id = ""
save_id = save_id_create()
creator = null
creator_pos = null

name = ""
temp = null
text = text_get("particleeditortypetextsample")
spawn_rate = 0
sprite_vbuffer_amount = 0
sprite_vbuffer[0] = null
sprite_tex = null
sprite_tex_image = 0
sprite_frame_width = 8
sprite_frame_height = 8
sprite_frame_start = 7
sprite_frame_end = 0
sprite_animation_speed = 5
sprite_animation_speed_israndom = 0
sprite_animation_speed_random_min = 5
sprite_animation_speed_random_max = 10
sprite_animation_onend = 0 // 0 = stop, 1 = loop, 2 = reverse

spd_extend = false
rot_extend = false
rot_spd_extend = false

spd = vec3(0)
spd_israndom = vec3(true)
spd_random_min = vec3(-20)
spd_random_max = vec3(20)
spd_add = vec3(0)
spd_add_israndom = vec3(false)
spd_add_random_min = vec3(-1)
spd_add_random_max = vec3(1)
spd_mul = vec3(1)
spd_mul_israndom = vec3(false)
spd_mul_random_min = vec3(0.75)
spd_mul_random_max = vec3(0.9)
	
rot = vec3(0)
rot_israndom = vec3(true)
rot_random_min = vec3(0)
rot_random_max = vec3(360)
rot_spd = vec3(0)
rot_spd_israndom = vec3(true)
rot_spd_random_min = vec3(-180)
rot_spd_random_max = vec3(180)
rot_spd_add = vec3(0)
rot_spd_add_israndom = vec3(false)
rot_spd_add_random_min = vec3(-10)
rot_spd_add_random_max = vec3(10)
rot_spd_mul = vec3(1)
rot_spd_mul_israndom = vec3(false)
rot_spd_mul_random_min = vec3(0.75)
rot_spd_mul_random_max = vec3(0.9)

scale = 1
scale_israndom = false
scale_random_min = 0.5
scale_random_max = 2
scale_add = 0
scale_add_israndom = false
scale_add_random_min = -0.2
scale_add_random_max = -0.1

alpha = 1
alpha_israndom = false
alpha_random_min = 0
alpha_random_max = 1
alpha_add = 0
alpha_add_israndom = false
alpha_add_random_min = -0.1
alpha_add_random_max = -0.05

color = c_white
color_israndom = false
color_random_start = c_gray
color_random_end = c_white
color_mix_enabled = false
color_mix = c_black
color_mix_israndom = false
color_mix_random_start = c_gray
color_mix_random_end = c_white
color_mix_time = 3
color_mix_time_israndom = false
color_mix_time_random_min = 1
color_mix_time_random_max = 5

spawn_region = true
bounding_box = true
bounce = true
bounce_factor = 0.5
orbit = false

text_vbuffer = null
text_texture = null
text_string = ""
text_res = null