/// tl_keyframe_deselect(keyframe)
/// @arg keyframe

var kf = argument0;

if (!kf.select)
    return 0
    
kf.select = false

with (kf.tl)
{
    keyframe_select_amount--
    if (keyframe_select = kf)
	{
        keyframe_select = null
        with (obj_keyframe)
            if (select && tl = other.id)
                other.keyframe_select = id
    }
    if (!keyframe_select)
        tl_deselect()
}
