uniform sampler2D uTexture;
uniform vec2 uTexScale;
uniform vec4 uBlendColor;

varying vec2 vTexCoord;
varying float vBrightness;

void main()
{
	vec2 tex = vTexCoord;
	if (uTexScale.x < 1.0 || uTexScale.y < 1.0)
		tex = mod(tex * uTexScale, uTexScale); // GM sprite bug workaround
	vec4 baseColor = uBlendColor * texture2D(uTexture, tex);
	gl_FragColor = vec4(vec3(vBrightness), baseColor.a);
	
	if (gl_FragColor.a == 0.0)
		discard;
}
