/// tab_control_textfield([toplabel, [size]])
/// @arg [toplabel
/// @arg [size]]

var toplabel, size;

if (argument_count > 0)
	toplabel = argument[0]
else
	toplabel = true

if (argument_count > 1)
	size = argument[1]
else
	size = 24

tab_control(size + ((label_height + 8) * toplabel))
