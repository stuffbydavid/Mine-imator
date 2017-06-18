/// tab_timeline_editor_audio()

var wid = text_caption_width("timelineeditoraudioadd") + 30;

if (draw_button_normal("timelineeditoraudioadd", dx + floor(dw / 2 - wid / 2), dy, wid, 32))
    action_tl_add_sound()
