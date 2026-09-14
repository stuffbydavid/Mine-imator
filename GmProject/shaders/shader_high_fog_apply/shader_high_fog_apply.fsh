uniform sampler2D uFogBuffer;
uniform vec4 uFogColor;
uniform float uGamma;

varying vec2 vTexCoord;

void main()
{
	float fog = texture2D(uFogBuffer, vTexCoord).r;
	vec4 color = texture2D(gm_BaseTexture, vTexCoord);
	color.rgb = mix(color.rgb, pow(uFogColor.rgb, vec3(uGamma)), fog);
	gl_FragColor = color;
}
