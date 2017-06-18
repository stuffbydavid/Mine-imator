/// tl_keyframe_remove(keyframe)
/// @arg keyframe

var kf = argument0;

with (kf.tl)
	tl_keyframes_pushup(kf.index)
	
if (kf.value[SOUNDOBJ])
	kf.value[SOUNDOBJ].count--

with (kf)
	instance_destroy()
