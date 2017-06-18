/// particle_get_animation_percent(starttime, startframe, endframe, speed, onend)
/// @arg starttime
/// @arg startframe
/// @arg endframe
/// @arg speed
/// @arg onend

var time, startframe, endframe, anispeed, onend, perc;
time = (current_step - argument0) / 60
startframe = argument1
endframe = argument2
anispeed = argument3
onend = argument4

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
