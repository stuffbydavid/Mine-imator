/// render_high_update_taa()

function render_high_update_taa()
{
	if (app.project_render_aa)
	{
		var haltonx, haltony, jitterx, jittery;
		haltonx = 2 * halton(render_sample_current + 1, 2) - 1
		haltony = 2 * halton(render_sample_current + 1, 3) - 1
		jitterx = haltonx * (1 / render_width) * app.project_render_aa_power
		jittery = haltony * (1 / render_height) * app.project_render_aa_power
		taa_jitter_matrix = [1, 0, 0, 0,
							 0, 1, 0, 0,
							 0, 0, 1, 0,
							 jitterx, jittery, 0, 1]
		taa_matrix = taa_jitter_matrix
	}
	else
	{
		taa_jitter_matrix = MAT_IDENTITY
		taa_matrix = MAT_IDENTITY
	}
}