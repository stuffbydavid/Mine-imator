varying vec2 vTexCoord;

uniform float uContrast;
uniform float uBrightness;
uniform float uSaturation;
uniform float uVibrance;
uniform vec4 uColorBurn;

#pragma shady: inline(common_color.COLOR_TRANSFORM_LIB)

void main()
{
	// Get base
	vec4 baseColor = texture2D(gm_BaseTexture, vTexCoord);
	
	// Brightness and contrast
	baseColor.rgb = (baseColor.rgb - vec3(0.5)) * vec3(uContrast) + vec3(uBrightness + 0.5);
	baseColor.rgb = clamp(baseColor.rgb, vec3(0.0), vec3(1.0));
	
	// Saturation
	vec3 W = vec3(0.2125, 0.7154, 0.0721);
	vec3 satIntensity = vec3(dot(baseColor.rgb, W));
	baseColor.rgb = mix(satIntensity, baseColor.rgb, uSaturation);
	baseColor.rgb = clamp(baseColor.rgb, vec3(0.0), vec3(1.0));
	
	// Vibrance(Saturates desaturated colors)
	satIntensity = vec3(dot(baseColor.rgb, W));
	float sat = rgbtohsb(baseColor).g;
	float vibrance = 1.0 - pow(pow(sat, 8.0), .15);
	baseColor.rgb = mix(satIntensity, baseColor.rgb, 1.0 + (vibrance * uVibrance));
	baseColor.rgb = clamp(baseColor.rgb, vec3(0.0), vec3(1.0));
	
	// Color burn
	baseColor.rgb = 1.0 - (1.0 - baseColor.rgb) / uColorBurn.rgb; 
	
	gl_FragColor = baseColor;
}
