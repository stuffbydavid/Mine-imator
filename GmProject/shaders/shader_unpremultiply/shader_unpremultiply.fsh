varying vec2 vTexCoord;

void main()
{
	vec4 color = texture2D(gm_BaseTexture, vTexCoord);
	if (color.a > 0.0001)
	{
		color.rgb /= color.a;
		float peak = max(color.r, max(color.g, color.b));
		if (peak > 1.0)
		{
			color.rgb /= peak;
			color.a = min(color.a * peak, 1.0);
		}
	}
	else
		color.rgb = vec3(0.0);

	gl_FragColor = color;
}
