/// render_high_update_aa_jitter()

function render_high_update_aa_jitter()
{
	if (app.project_render_aa && app.project_render_aa_mode = e_aa_mode.PROGRESSIVE)
	{
		var haltonx, haltony, jitterx, jittery;
		haltonx = 2 * halton(render_sample_current + 1, 2) - 1
		haltony = 2 * halton(render_sample_current + 1, 3) - 1
		jitterx = haltonx * (1 / render_width) * app.project_render_aa_power
		jittery = haltony * (1 / render_height) * app.project_render_aa_power
		aa_jitter_matrix = [1, 0, 0, 0,
							 0, 1, 0, 0,
							 0, 0, 1, 0,
							 jitterx, jittery, 0, 1]
		aa_matrix = aa_jitter_matrix
	}
	else
	{
		aa_jitter_matrix = MAT_IDENTITY
		aa_matrix = MAT_IDENTITY
	}
}
