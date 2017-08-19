/// tl_keyframe_select(keyframe)
/// @arg keyframe

var kf = argument0;

if (kf.selected)
	return 0
	
kf.selected = true
	
with (kf.timeline)
{
	keyframe_select = kf
	keyframe_select_amount++
	tl_select()
}
