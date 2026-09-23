/// action_bench_text(text)
/// @arg text

function action_bench_text(text)
{
	with (bench_settings)
	{
		self.text = text
		preview_zoom_text(preview, text, res_eval(text_font).font)
		preview.update = true
	}
}
