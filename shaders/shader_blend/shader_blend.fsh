uniform sampler2D uTexture;
uniform vec2 uTexScale;

varying vec2 vTexCoord;
varying vec4 vColor;

void main()
{
	vec2 tex = vTexCoord;
	if (uTexScale.x < 1.0 || uTexScale.y < 1.0)
		tex = mod(tex * uTexScale, uTexScale); // GM sprite bug workaround
	gl_FragColor = vColor * texture2D(uTexture, tex);
	
	if (gl_FragColor.a == 0.0)
		discard;
}

