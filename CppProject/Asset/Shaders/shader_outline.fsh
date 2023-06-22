uniform vec2 uTexSize;

varying vec2 vTexCoord;

bool outline(vec2 off)
{
	vec2 pos = vec2(vTexCoord.x + off.x * (1.0 / uTexSize.x),
					vTexCoord.y + off.y * (1.0 / uTexSize.y));
	return (texture2D(gm_BaseTexture, pos).a > 0.0);
}

void main()
{
	float size = 1.0;
	if (texture2D(gm_BaseTexture, vTexCoord).a > 0.0)
		discard;
	else if (outline(vec2(size, size))
		 || outline(vec2(-size, size))
		 || outline(vec2(size, -size))
		 || outline(vec2(-size, -size))
		 || outline(vec2(0.0, -size))
		 || outline(vec2(0.0, size))
		 || outline(vec2(-size, 0.0))
		 || outline(vec2(+size, 0.0)))
		 gl_FragColor = vec4(1.0);
	else
		discard;
}
