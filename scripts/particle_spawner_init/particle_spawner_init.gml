/// particle_spawner_init()
/// @desc Creates the variables necessary for spawning particles.

spawn_queue_amount[minute_steps] = 0
spawn_queue[minute_steps, 0] = 0
spawn_queue_start = null
spawn_laststep = current_step
spawn_active = true
fire = false

particle_list = ds_list_create()
istl = (object_index = obj_timeline)
