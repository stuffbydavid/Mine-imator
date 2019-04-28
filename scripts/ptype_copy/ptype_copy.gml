/// ptype_copy(to)
/// @arg to
/// @desc Copies all the variables into the given object.

var to = argument0;

to.creator = creator
if (object_index = obj_particle_type)
	to.creator_index = ds_list_find_index(creator.pc_type_list, id)
else // History object (copy)
	to.creator_index = creator_index
to.name = name
to.temp = temp
to.text = text
to.spawn_rate = spawn_rate

to.sprite_tex = sprite_tex
to.sprite_tex_image = sprite_tex_image
to.sprite_template_tex = sprite_template_tex
to.sprite_template = sprite_template
to.sprite_template_reverse = sprite_template_reverse
to.sprite_template_still_frame = sprite_template_still_frame
to.sprite_template_random_frame = sprite_template_random_frame
to.sprite_frame_width = sprite_frame_width
to.sprite_frame_height = sprite_frame_height
to.sprite_frame_start = sprite_frame_start
to.sprite_frame_end = sprite_frame_end
to.sprite_animation_speed = sprite_animation_speed
to.sprite_animation_speed_israndom = sprite_animation_speed_israndom
to.sprite_animation_speed_random_min = sprite_animation_speed_random_min
to.sprite_animation_speed_random_max = sprite_animation_speed_random_max
to.sprite_animation_onend = sprite_animation_onend // 0 = stop, 1 = loop, 2 = reverse

to.angle_extend = angle_extend
to.rot_extend = rot_extend
to.spd_extend = spd_extend
to.rot_spd_extend = rot_spd_extend

to.angle = array_copy_1d(angle)
to.angle_strength = angle_strength
to.angle_strength_israndom = angle_strength_israndom
to.angle_strength_random_min = angle_strength_random_min
to.angle_strength_random_max = angle_strength_random_max
to.angle_strength_add = angle_strength_add
to.angle_strength_add_israndom = angle_strength_add_israndom
to.angle_strength_add_random_min = angle_strength_add_random_min
to.angle_strength_add_random_max = angle_strength_add_random_max
to.angle_strength_mul = angle_strength_mul
to.angle_strength_mul_israndom = angle_strength_mul_israndom
to.angle_strength_mul_random_min = angle_strength_mul_random_min
to.angle_strength_mul_random_max = angle_strength_mul_random_max

to.spd = array_copy_1d(spd)
to.spd_israndom = array_copy_1d(spd_israndom)
to.spd_random_min = array_copy_1d(spd_random_min)
to.spd_random_max = array_copy_1d(spd_random_max)
to.spd_add = array_copy_1d(spd_add)
to.spd_add_israndom = array_copy_1d(spd_add_israndom)
to.spd_add_random_min = array_copy_1d(spd_add_random_min)
to.spd_add_random_max = array_copy_1d(spd_add_random_max)
to.spd_mul = array_copy_1d(spd_mul)
to.spd_mul_israndom = array_copy_1d(spd_mul_israndom)
to.spd_mul_random_min = array_copy_1d(spd_mul_random_min)
to.spd_mul_random_max = array_copy_1d(spd_mul_random_max)

to.rot = array_copy_1d(rot)
to.rot_israndom = array_copy_1d(rot_israndom)
to.rot_random_min = array_copy_1d(rot_random_min)
to.rot_random_max = array_copy_1d(rot_random_max)
to.rot_spd = array_copy_1d(rot_spd)
to.rot_spd_israndom = array_copy_1d(rot_spd_israndom)
to.rot_spd_random_min = array_copy_1d(rot_spd_random_min)
to.rot_spd_random_max = array_copy_1d(rot_spd_random_max)
to.rot_spd_add = array_copy_1d(rot_spd_add)
to.rot_spd_add_israndom = array_copy_1d(rot_spd_add_israndom)
to.rot_spd_add_random_min = array_copy_1d(rot_spd_add_random_min)
to.rot_spd_add_random_max = array_copy_1d(rot_spd_add_random_max)
to.rot_spd_mul = array_copy_1d(rot_spd_mul)
to.rot_spd_mul_israndom = array_copy_1d(rot_spd_mul_israndom)
to.rot_spd_mul_random_min = array_copy_1d(rot_spd_mul_random_min)
to.rot_spd_mul_random_max = array_copy_1d(rot_spd_mul_random_max)

to.sprite_angle = sprite_angle
to.sprite_angle_israndom = sprite_angle_israndom
to.sprite_angle_random_min = sprite_angle_random_min
to.sprite_angle_random_max = sprite_angle_random_max
to.sprite_angle_add = sprite_angle_add
to.sprite_angle_add_israndom = sprite_angle_add_israndom
to.sprite_angle_add_random_min = sprite_angle_add_random_min
to.sprite_angle_add_random_max = sprite_angle_add_random_max

to.scale = scale
to.scale_israndom = scale_israndom
to.scale_random_min = scale_random_min
to.scale_random_max = scale_random_max
to.scale_add = scale_add
to.scale_add_israndom = scale_add_israndom
to.scale_add_random_min = scale_add_random_min
to.scale_add_random_max = scale_add_random_max

to.alpha = alpha
to.alpha_israndom = alpha_israndom
to.alpha_random_min = alpha_random_min
to.alpha_random_max = alpha_random_max
to.alpha_add = alpha_add
to.alpha_add_israndom = alpha_add_israndom
to.alpha_add_random_min = alpha_add_random_min
to.alpha_add_random_max = alpha_add_random_max

to.color = color
to.color_israndom = color_israndom
to.color_random_start = color_random_start
to.color_random_end = color_random_end
to.color_mix_enabled = color_mix_enabled
to.color_mix = color_mix
to.color_mix_israndom = color_mix_israndom
to.color_mix_random_start = color_mix_random_start
to.color_mix_random_end = color_mix_random_end
to.color_mix_time = color_mix_time
to.color_mix_time_israndom = color_mix_time_israndom
to.color_mix_time_random_min = color_mix_time_random_min
to.color_mix_time_random_max = color_mix_time_random_max

to.spawn_region = spawn_region
to.bounding_box = bounding_box
to.bounce = bounce
to.bounce_factor = bounce_factor
to.orbit = orbit
