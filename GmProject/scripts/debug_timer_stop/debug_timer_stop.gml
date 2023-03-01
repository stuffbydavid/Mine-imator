/// debug_timer_stop(message)
/// @arg message

function debug_timer_stop(str)
{
	debug(str, string(current_time - debug_timer) + " msec")
}
