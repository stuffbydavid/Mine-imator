uniform sampler2D uFogBuffer;
uniform vec4 uFogColor;
uniform float uBackgroundBrightness;
uniform float uGamma;

varying vec2 vTexCoord;

void main()
{
	vec4 fogData = texture2D(uFogBuffer, vTexCoord);
	float fog = fogData.a > 0.0001 ? fogData.r / fogData.a : 0.0;
	vec4 color = texture2D(gm_BaseTexture, vTexCoord);
	vec3 fogColor = pow(uFogColor.rgb, vec3(uGamma)) * uBackgroundBrightness;
	if (color.a > 0.0001)
	{
		color.rgb /= color.a;
		color.rgb = mix(color.rgb, fogColor, fog);
		color.rgb *= color.a;
	}
	gl_FragColor = color;
}
