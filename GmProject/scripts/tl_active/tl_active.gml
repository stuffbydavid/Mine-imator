/// tl_active(timeline)
/// @arg timeline
/// @desc Returns true if the given timeline is the project's active camera/environment object.

function tl_active(tl)
{
	return
		(tl.type = e_tl_type.CAMERA && tl = timeline_camera) ||
		(tl.type = e_tl_type.BACKGROUND && tl = background_tlactive);
}