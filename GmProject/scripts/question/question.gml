/// question(text)
/// @arg text

function question(text)
{
	var answer;
	
	window_set_caption("Mine-imator")
	answer = show_question(text)
	window_set_caption("")
	
	return answer;
}
