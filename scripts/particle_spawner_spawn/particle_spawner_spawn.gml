/// particle_spawner_spawn(type)
/// @arg type
/// @desc Adds a new particle to the spawner's list.

var type, pt, temp;
type = argument0
pt = new(obj_particle)
pt.creator = id
pt.type = type
pt.spawntime = current_step
pt.frame = 0
pt.time = 0

if (istl)
    temp = id.temp
else
    temp = select
pt.timetolive = value_random(temp.pc_destroy_at_time_seconds, temp.pc_destroy_at_time_israndom, temp.pc_destroy_at_time_random_min, temp.pc_destroy_at_time_random_max) * 60

// Position
pt.pos[X] = pos[X]
pt.pos[Y] = pos[Y]
pt.pos[Z] = pos[Z]
if (temp.pc_spawn_region_use && type.spawn_region)
{
    switch (temp.pc_spawn_region_type)
	{
        case "sphere":
		{
            var xyang, zang, dis;
            xyang = random(360)
            zang = random_range(-180, 180)
            dis = random_range(-temp.pc_spawn_region_sphere_radius, temp.pc_spawn_region_sphere_radius)
            pt.pos[X] += lengthdir_x(dis, xyang) * lengthdir_x(1, zang)
            pt.pos[Y] += lengthdir_y(dis, xyang) * lengthdir_x(1, zang)
            pt.pos[Z] += lengthdir_z(dis, zang)
            break
        }
		
        case "cube":
		{
            pt.pos[X] += random_range(-temp.pc_spawn_region_cube_size / 2, temp.pc_spawn_region_cube_size / 2)
            pt.pos[Y] += random_range(-temp.pc_spawn_region_cube_size / 2, temp.pc_spawn_region_cube_size / 2)
            pt.pos[Z] += random_range(-temp.pc_spawn_region_cube_size / 2, temp.pc_spawn_region_cube_size / 2)
            break
        }
		
        case "box":
		{
            pt.pos[X] += random_range(-temp.pc_spawn_region_box_size[X] / 2, temp.pc_spawn_region_box_size[X] / 2)
            pt.pos[Y] += random_range(-temp.pc_spawn_region_box_size[Y] / 2, temp.pc_spawn_region_box_size[Y] / 2)
            pt.pos[Z] += random_range(-temp.pc_spawn_region_box_size[Z] / 2, temp.pc_spawn_region_box_size[Z] / 2)
            break
        }
    }
}

// Animation
pt.anispeed = value_random(type.sprite_animation_speed, type.sprite_animation_speed_israndom, type.sprite_animation_speed_random_min, type.sprite_animation_speed_random_max)

for (var a = X; a <= Z; a++)
{
    // Speed
    pt.spd[a] = value_random(type.spd[a * type.spd_extend], type.spd_israndom[a * type.spd_extend], type.spd_random_min[a * type.spd_extend], type.spd_random_max[a * type.spd_extend]) / 60
    pt.spd_add[a] = value_random(type.spd_add[a * type.spd_extend], type.spd_add_israndom[a * type.spd_extend], type.spd_add_random_min[a * type.spd_extend], type.spd_add_random_max[a * type.spd_extend]) / 60
    pt.spd_mul[a] = value_random(type.spd_mul[a * type.spd_extend], type.spd_mul_israndom[a * type.spd_extend], type.spd_mul_random_min[a * type.spd_extend], type.spd_mul_random_max[a * type.spd_extend])
    if (pt.spd_mul[a] != 1)
        repeat (5)
            pt.spd_mul[a] = sqrt(pt.spd_mul[a])
    
    // Rotation
    pt.rot[a] = value_random(type.rot[a * type.rot_extend], type.rot_israndom[a * type.rot_extend], type.rot_random_min[a * type.rot_extend], type.rot_random_max[a * type.rot_extend])
    pt.rot_spd[a] = value_random(type.rot_spd[a * type.rot_spd_extend], type.rot_spd_israndom[a * type.rot_spd_extend], type.rot_spd_random_min[a * type.rot_spd_extend], type.rot_spd_random_max[a * type.rot_spd_extend]) / 60
    pt.rot_spd_add[a] = value_random(type.rot_spd_add[a * type.rot_spd_extend], type.rot_spd_add_israndom[a * type.rot_spd_extend], type.rot_spd_add_random_min[a * type.rot_spd_extend], type.rot_spd_add_random_max[a * type.rot_spd_extend]) / 60
    pt.rot_spd_mul[a] = value_random(type.rot_spd_mul[a * type.rot_spd_extend], type.rot_spd_mul_israndom[a * type.rot_spd_extend], type.rot_spd_mul_random_min[a * type.rot_spd_extend], type.rot_spd_mul_random_max[a * type.rot_spd_extend])
    if (pt.rot_spd_mul[a] != 1)
        repeat (5)
            pt.rot_spd_mul[a] = sqrt(pt.rot_spd_mul[a])
}

// Scale
pt.scale = value_random(type.scale, type.scale_israndom, type.scale_random_min, type.scale_random_max)
pt.scale_add = value_random(type.scale_add, type.scale_add_israndom, type.scale_add_random_min, type.scale_add_random_max) / 60

// Alpha
pt.alpha = value_random(type.alpha, type.alpha_israndom, type.alpha_random_min, type.alpha_random_max)
pt.alpha_add = value_random(type.alpha_add, type.alpha_add_israndom, type.alpha_add_random_min, type.alpha_add_random_max) / 60

// Color
if (type.color_israndom)
    pt.color = merge_color(type.color_random_start, type.color_random_end, random(1))
else
    pt.color = type.color

// Color mix
if (type.color_mix_enabled)
{
    if (type.color_mix_israndom)
        pt.color_mix = merge_color(type.color_mix_random_start, type.color_mix_random_end, random(1))
    else
        pt.color_mix = type.color_mix
    pt.color_mix_start = pt.color
    pt.color_mix_time = max(1, value_random(type.color_mix_time, type.color_mix_time_israndom, type.color_mix_time_random_min, type.color_mix_time_random_max) * 60)
}
else
{
    pt.color_mix = -1
    pt.color_mix_start = -1
    pt.color_mix_time = 0
}

ds_list_add(particles, pt)
