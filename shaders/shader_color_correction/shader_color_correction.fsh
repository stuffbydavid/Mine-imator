varying vec2 vTexCoord;

uniform float uContrast;
uniform float uBrightness;
uniform float uSaturation;

void main()
{
	// Get base
	vec4 baseColor = texture2D(gm_BaseTexture, vTexCoord);
	
	// Brightness and contrast
	baseColor.rgb = (baseColor.rgb - vec3(0.5)) * vec3(uContrast) + vec3(uBrightness + 0.5);
	
	// Saturation
	vec3 W = vec3(0.2125, 0.7154, 0.0721);
	vec3 satIntensity = vec3(dot(baseColor.rgb, W));
	baseColor.rgb = mix(satIntensity, baseColor.rgb, uSaturation);
	
	gl_FragColor = baseColor;
}