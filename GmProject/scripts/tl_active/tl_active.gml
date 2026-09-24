/// tl_active(timeline)
/// @arg timeline
/// @desc Returns true if the given timeline is the project's active camera or environment object.

function tl_active(tl)
{
	return
		(tl.type = e_tl_type.CAMERA && !is_undefined(timeline_camera) && tl = timeline_camera) ||
		(tl.type = e_tl_type.BACKGROUND && !is_undefined(background_tlactive) && tl = background_tlactive);
}