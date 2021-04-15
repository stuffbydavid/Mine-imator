/// keybinds_reset_default()

for (var i = 0; i < e_keybind.amount; i++)
	keybind_restore(i, true)

keybinds_update_match()
settings_save()
