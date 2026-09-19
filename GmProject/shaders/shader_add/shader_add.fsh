uniform sampler2D uAddTexture;
uniform vec4 uBlendColor;
uniform float uAmount;
uniform float uPower;
uniform vec2 uAddTexelSize;
uniform int uTentFilter;

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
	
	float value = (addColor.r + addColor.g + addColor.b) / 3.0;
	addColor.a = value;
	
	vec4 finalColor;
	finalColor.rgb = baseColor.rgb + ((addColor.rgb * uBlendColor.rgb) * vec3(uAmount));
	
	finalColor.a = min(baseColor.a + addColor.a, 1.0);
	
	gl_FragColor = vec4(finalColor);
}