/// history_build_shift(restore, index)

function history_build_shift(restore, index)
{
	if (!restore)
	{
		// Remove the live preview from the history array
		for (var h = index; h < history_amount - 1; h++)
			history[h] = history[h + 1]
		history_amount--
		
		return 0
	}

	// Insert the live preview back at its history position
	for (var h = history_amount; h > index; h--)
		history[h] = history[h - 1]
	
	history[index] = place_history
	history_amount++
}
