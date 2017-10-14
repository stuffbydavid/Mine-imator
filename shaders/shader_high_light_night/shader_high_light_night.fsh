uniform sampler2D uTexture;
uniform vec4 uBlendColor;
uniform float uAlpha;

varying vec2 vTexCoord;
varying float vBrightness;

void main()
{
	vec4 baseColor = uBlendColor * texture2D(uTexture, vTexCoord);
	gl_FragColor = vec4(vec3(vBrightness), baseColor.a);
	
	if (gl_FragColor.a == 0.0)
		discard;
}
