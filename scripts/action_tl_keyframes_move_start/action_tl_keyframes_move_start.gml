/// action_tl_keyframes_move_start(keyframe)
/// @arg keyframe

with (obj_keyframe)
{
    if (!select)
        continue
    moveindex = index
    movepos = pos
}

timeline_move_kf = argument0
timeline_move_kf_mousepos = timeline_mouse_pos
window_busy = "timelinemovekeyframes"
