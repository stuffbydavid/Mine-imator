uniform sampler2D uTexture;
uniform float uAlpha;
uniform float uBrightness;

varying vec2 vTexCoord;
varying float vBrightness;

void main()
{
	vec4 baseColor = texture2D(uTexture, vTexCoord);
	gl_FragColor = vec4(vec3(vBrightness + uBrightness), uAlpha * baseColor.a);
	
	if (gl_FragColor.a == 0.0)
		discard;
}
