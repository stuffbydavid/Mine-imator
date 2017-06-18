/// tl_keyframe_save(keyframe)
/// @arg keyframe

var kf = argument0;

if (kf.value[ATTRACTOR])
    with (kf.value[ATTRACTOR])
        tl_save()
    
if (kf.value[TEXTUREOBJ])
{
    kf.value[TEXTUREOBJ].save = true
    if (kf.value[ATTRACTOR].type = "camera")
        with (kf.value[ATTRACTOR])
            tl_save()
}

if (kf.value[SOUNDOBJ])
    kf.value[SOUNDOBJ].save = true
