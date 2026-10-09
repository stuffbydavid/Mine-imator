/// CppSeparate void window_create(Scope<app>, IntType, IntType, IntType, IntType, IntType)
/// @desc Creates a new window from a rectangle relative to the current window.
/// @arg window
/// @arg x
/// @arg y
/// @arg width
/// @arg height

function window_create(window, xx, yy, width, height)
{
	tip_reset()
	ds_list_add(window_list, window)
}
