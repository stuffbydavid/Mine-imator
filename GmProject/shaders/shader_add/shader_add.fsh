uniform sampler2D uAddTexture;
uniform vec4 uBlendColor;
uniform float uAmount;
uniform float uPower;
uniform vec2 uAddTexelSize;
uniform int uTentFilter;
uniform int uAffectAlpha;

varying vec2 vTexCoord;

void main()
{
	vec4 baseColor = texture2D(gm_BaseTexture, vTexCoord);
	vec4 addColor;
	if (uTentFilter != 0)
	{
		vec2 texel = uAddTexelSize;
		addColor = texture2D(uAddTexture, vTexCoord + vec2(-texel.x, -texel.y));
		addColor += texture2D(uAddTexture, vTexCoord + vec2(0.0, -texel.y)) * 2.0;
		addColor += texture2D(uAddTexture, vTexCoord + vec2(texel.x, -texel.y));
		addColor += texture2D(uAddTexture, vTexCoord + vec2(-texel.x, 0.0)) * 2.0;
		addColor += texture2D(uAddTexture, vTexCoord) * 4.0;
		addColor += texture2D(uAddTexture, vTexCoord + vec2(texel.x, 0.0)) * 2.0;
		addColor += texture2D(uAddTexture, vTexCoord + vec2(-texel.x, texel.y));
		addColor += texture2D(uAddTexture, vTexCoord + vec2(0.0, texel.y)) * 2.0;
		addColor += texture2D(uAddTexture, vTexCoord + texel);
		addColor /= 16.0;
	}
	else
		addColor = texture2D(uAddTexture, vTexCoord);
	addColor.rgb = pow(addColor.rgb, vec3(uPower));
	
	vec4 finalColor;
	vec3 contribution = (addColor.rgb * uBlendColor.rgb) * vec3(uAmount);
	finalColor.rgb = baseColor.rgb + contribution;
	finalColor.a = baseColor.a;
	if (uAffectAlpha > 0)
	{
		vec3 effectColor = max(contribution, vec3(0.0));
		float effectAlpha = clamp(max(effectColor.r, max(effectColor.g, effectColor.b)), 0.0, 1.0);
		finalColor.a += effectAlpha * (1.0 - finalColor.a);
	}
	
	gl_FragColor = vec4(finalColor);
}