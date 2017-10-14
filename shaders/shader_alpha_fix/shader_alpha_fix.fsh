uniform sampler2D uTexture;

varying vec2 vTexCoord;

void main()
{
	vec4 baseColor = texture2D(uTexture, vTexCoord);
	if (baseColor.a == 0.0)
		discard;
		
	gl_FragColor = vec4(0.0, 0.0, 0.0, baseColor.a);
}

