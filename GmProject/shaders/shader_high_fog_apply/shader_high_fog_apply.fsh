uniform sampler2D uFogBuffer;
uniform vec4 uFogColor;
uniform float uBackgroundBrightness;
uniform float uGamma;

varying vec2 vTexCoord;

void main()
{
	float fog = texture2D(uFogBuffer, vTexCoord).r;
	vec4 color = texture2D(gm_BaseTexture, vTexCoord);
	vec3 fogColor = pow(uFogColor.rgb, vec3(uGamma)) * uBackgroundBrightness;
	color.rgb = mix(color.rgb, fogColor, fog);
	gl_FragColor = color;
}
