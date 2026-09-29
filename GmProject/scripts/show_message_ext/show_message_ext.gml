/// CppSeparate IntType show_message_ext(StringType, StringType, StringType, StringType, StringType)
/// @desc Shows 3 buttons with custom text, returns the ID of the button pressed. Pressing X will act as button3.

function show_message_ext(title, text, button1, button2, button3)
{
	return question(text) ? 0 : 1
}
