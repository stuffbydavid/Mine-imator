/// particle_get_animation_percent(step, starttime, startframe, endframe, speed, onend)
/// @arg step
/// @arg starttime
/// @arg startframe
/// @arg endframe
/// @arg speed
/// @arg onend

function particle_get_animation_percent(step, time, startframe, endframe, anispeed, onend)
{
	var perc;
	time = (step - time) / 60
	
	if (startframe = endframe) // No animation
		return startframe
	
	perc = (time * anispeed) / abs(startframe - endframe)
	
	if (onend = 0) // Stop
		perc = min(perc, 1)
	else if (onend = 1) // Loop
		perc = perc mod 1
	else if (onend = 2) // Reverse
	{
		if (floor(perc mod 2))
			perc = 1-(perc mod 1)
		else
			perc = perc mod 1
	}
	
	return perc
}
