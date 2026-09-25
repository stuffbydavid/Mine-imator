/// action_bench_text_outline_size(value, add)

function action_bench_text_outline_size(val, add)
{
	bench_settings.text_outline_size = clamp(bench_settings.text_outline_size * add + val, 0, 8)
	bench_settings.preview.update = true
}
