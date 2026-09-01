uniform vec4 uRGBAdd;
uniform vec4 uRGBSub;
uniform vec4 uHSBAdd;
uniform vec4 uHSBSub;
uniform vec4 uHSBMul;
uniform vec4 uMixColor;

varying vec4 vColor;
varying vec2 vTexCoord;

uniform vec4 uBlendColor;
uniform float uBrightness;

#pragma shady: inline(common_color.COLOR_TRANSFORM_LIB)

void main()
{
	vec4 baseColor = vec4(uBlendColor.rgb, 1.0) * texture2D(gm_BaseTexture, vTexCoord); // Get base
	
	gl_FragColor = clamp(baseColor + uRGBAdd - uRGBSub, 0.0, 1.0); // Transform RGB
	gl_FragColor = hsbtorgb(clamp(rgbtohsb(gl_FragColor) + uHSBAdd - uHSBSub, 0.0, 1.0) * uHSBMul); // Transform HSB
	gl_FragColor = mix(gl_FragColor, vec4(uMixColor.rgb, 1.0), uMixColor.a); // Mix
	gl_FragColor = mix(gl_FragColor, vec4(1.0), uBrightness); // Brightness
	gl_FragColor = mix(gl_FragColor, vec4(0.0, 0.0, 0.0, 1.0), 1.0 - uBlendColor.a); // Alpha
}
