varying vec4 vColor;
varying vec2 vTexCoord;

uniform vec4 uBlendColor;
uniform float uBrightness;

#pragma shady: inline(common_color.COLOR_ADJUST_LIB)

void main()
{
	gl_FragColor = vec4(uBlendColor.rgb, 1.0) * texture2D(gm_BaseTexture, vTexCoord); // Get base
	
	applyColorTransformMixAlpha(gl_FragColor, false, 1.0);
	gl_FragColor = mix(gl_FragColor, vec4(1.0), uBrightness); // Brightness
	gl_FragColor = mix(gl_FragColor, vec4(0.0, 0.0, 0.0, 1.0), 1.0 - uBlendColor.a); // Alpha
}
