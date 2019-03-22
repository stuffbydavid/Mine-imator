uniform sampler2D uAddTexture;
uniform vec4 uBlendColor;
uniform float uAmount;
uniform float uPower;

varying vec2 vTexCoord;

void main()
{
	vec4 baseColor = texture2D(gm_BaseTexture, vTexCoord);
	vec4 addColor = texture2D(uAddTexture, vTexCoord);
	addColor.rgb = pow(addColor.rgb, vec3(uPower));
	
	float value = (addColor.r + addColor.g + addColor.b) / 3.0;
	addColor.a = value;
	
	vec4 finalColor;
	finalColor.rgb = baseColor.rgb + ((addColor.rgb * uBlendColor.rgb) * vec3(uAmount));
	
	finalColor.a = min(baseColor.a + addColor.a, 1.0);
	
	gl_FragColor = vec4(finalColor);
}