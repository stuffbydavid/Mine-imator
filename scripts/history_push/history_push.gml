/// history_push()
/// @desc Reserves a new slot at the beginning of the history list.

history_amount++
for (var h = history_amount; h > 0; h--)
	history[h] = history[h - 1]
