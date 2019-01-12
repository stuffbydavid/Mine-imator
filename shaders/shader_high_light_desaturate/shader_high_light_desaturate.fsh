uniform sampler2D uShadowBuffer;
uniform float uAmount;

varying vec2 vTexCoord;

void main()
{
	vec4 baseColor = texture2D(gm_BaseTexture, vTexCoord);
	vec4 lightColor = texture2D(uShadowBuffer, vTexCoord);
	float amount = ((lightColor.r + lightColor.g + lightColor.b) / 3.0);
	
	// Exponential
	amount = -pow(2.0, -10.0 * amount) + 1.0;
	
	amount = min(1.0, max(0.0, amount) + uAmount);
	
	// Desaturate
	vec3 W = vec3(0.2125, 0.7154, 0.0721);
	vec3 satIntensity = vec3(dot(baseColor.rgb, W));
	baseColor.rgb = mix(satIntensity, baseColor.rgb, amount);
	
	gl_FragColor = baseColor;
	gl_FragColor.a = baseColor.a;
}
