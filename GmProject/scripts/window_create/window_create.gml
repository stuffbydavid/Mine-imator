/// CppSeparate void window_create(Scope<app>, IntType, IntType, IntType, IntType, IntType)
/// Creates a new window from a rectangle relative to the current window.

function window_create(window, xx, yy, width, height)
{
	tip_reset()
	ds_list_add(window_list, window)
}