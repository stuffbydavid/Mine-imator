uniform sampler2D uTexture;
uniform vec2 uTexScale;

varying vec2 vTexCoord;

void main()
{
	vec2 tex = vTexCoord;
	if (uTexScale.x < 1.0 || uTexScale.y < 1.0)
		tex = mod(tex * uTexScale, uTexScale); // GM sprite bug workaround
	vec4 baseColor = texture2D(uTexture, tex);
	if (baseColor.a >= 1.0)
		discard;
	
	gl_FragColor = vec4(0.0, 0.0, 0.0, baseColor.a);
}

