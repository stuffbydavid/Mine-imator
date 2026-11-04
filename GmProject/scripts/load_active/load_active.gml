/// @desc Returns whether the queued loader can advance.

function load_active()
{
	return (popup_current = popup_loading && popup_ani = 1 && popup_ani_type != "hide" &&
		popup_loading.load_object != null && popup_loading.load_script != null)
}