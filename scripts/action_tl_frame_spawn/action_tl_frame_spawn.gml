/// action_tl_frame_spawn(spawn)
/// @arg spawn

function action_tl_frame_spawn(spawn)
{
	tl_value_set_start(action_tl_frame_spawn, false)
	tl_value_set(e_value.SPAWN, spawn, false)
	tl_value_set_done()
}
