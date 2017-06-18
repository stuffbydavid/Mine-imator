/// action_toolbar_redo()

if (history_pos = 0)
    return 0

action_toolbar_play_break()

history_pos--

history_data = history[history_pos]
temp_edit = iid_find(history_data.save_temp_edit)
ptype_edit = iid_find(history_data.save_ptype_edit)
tl_edit = iid_find(history_data.save_tl_edit)
res_edit = iid_find(history_data.save_res_edit)
axis_edit = history_data.save_axis_edit
iid_current = history_data.save_iid_current

log("Redo", script_get_name(history_data.script))

history_redo = true
script_execute(history_data.script)
history_redo = false
