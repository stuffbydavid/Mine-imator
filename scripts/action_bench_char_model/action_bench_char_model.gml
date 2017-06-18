/// action_bench_char_model(model)
/// @arg model

bench_settings.char_model = argument0
bench_settings.char_bodypart = min(bench_settings.char_bodypart, bench_settings.char_model.part_amount - 1)

bench_settings.preview.update = true
