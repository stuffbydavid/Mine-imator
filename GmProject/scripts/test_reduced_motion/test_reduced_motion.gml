/// test_reduced_motion(a, b)

function test_reduced_motion(a, b)
{
	if (app.setting_reduced_motion)
		return a
	return b
}