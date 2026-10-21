/// @arg message

function debug_timer_stop(msg)
{
	debug(msg, string(current_time - debug_timer) + " msec")
}
