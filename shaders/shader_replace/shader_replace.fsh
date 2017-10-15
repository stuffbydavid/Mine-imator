uniform sampler2D uTexture;
uniform vec2 uTexScale;
uniform vec4 uReplaceColor;

varying vec2 vTexCoord;

void main()
{
	vec2 tex = vTexCoord;
	if (uTexScale.x < 1.0 || uTexScale.y < 1.0)
		tex = mod(tex * uTexScale, uTexScale); // GM sprite bug workaround
	gl_FragColor = vec4(uReplaceColor.rgb, ceil(texture2D(uTexture, tex).a));
	
	if (gl_FragColor.a == 0.0)
		discard;
}

