uniform sampler2D uTexture;
uniform vec2 uTexScale;

varying vec2 vTexCoord;
varying float vDepth;

vec4 packDepth(float f)
{
	 return vec4(floor(f * 255.0) / 255.0, fract(f * 255.0), fract(f * 255.0 * 255.0), fract(f * 255.0 * 255.0 * 255.0));
}

void main()
{
	gl_FragColor = packDepth(vDepth);
	
	vec2 tex = vTexCoord;
	if (uTexScale.x < 1.0 || uTexScale.y < 1.0)
		tex = mod(tex * uTexScale, uTexScale); // GM sprite bug workaround
	if (texture2D(uTexture, tex).a < 0.1)
		discard;
}

