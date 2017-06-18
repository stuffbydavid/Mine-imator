uniform vec2 uTexSize;

varying vec2 vTexCoord;

bool isHighlight(vec2 off)
{
	vec2 pos = vec2(vTexCoord.x + off.x * (1.0 / uTexSize.x),
					vTexCoord.y + off.y * (1.0 / uTexSize.y));
	return (texture2D(gm_BaseTexture, pos).a > 0.0);
}

void main()
{
	float size = 2.0;
	if (texture2D(gm_BaseTexture, vTexCoord).a > 0.0)
		discard;
	else if (isHighlight(vec2(size, size))
		 || isHighlight(vec2(-size, size))
		 || isHighlight(vec2(size, -size))
		 || isHighlight(vec2(-size, -size)))
		 gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);
	else
		discard;
}
