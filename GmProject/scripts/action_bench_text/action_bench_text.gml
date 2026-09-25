/// action_bench_text(text)
/// @arg text

function action_bench_text(text)
{
	with (bench_settings)
	{
		self.text = text
		preview_zoom_text(preview, text, text_font)
		preview.update = true
	}
}
