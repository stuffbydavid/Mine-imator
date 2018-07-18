varying vec2 vTexCoord;

uniform vec2 uScreenSize;
uniform float uRadius;
uniform float uSoftness;
uniform float uStrength;

void main()
{
	vec2 centerCoord = (vTexCoord) - vec2(0.5);
	
	float len = length(centerCoord);
	float amount = smoothstep(uRadius, uRadius - clamp(uSoftness, 0.005, 1.0), len);
	
	// Get base
	vec4 baseColor = texture2D(gm_BaseTexture, vTexCoord);
	
	baseColor.rgb = mix(baseColor.rgb, baseColor.rgb * vec3(amount), uStrength);
	
	gl_FragColor = baseColor;
}