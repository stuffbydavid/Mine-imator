/// tl_keyframe_select(keyframe)
/// @arg keyframe

var kf = argument0;

if (kf.select)
    return 0
    
kf.select = true
    
with (kf.tl)
{
    keyframe_select = kf
    keyframe_select_amount++
    tl_select()
}
