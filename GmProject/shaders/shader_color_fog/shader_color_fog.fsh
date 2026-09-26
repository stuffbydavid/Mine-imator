uniform sampler2D uTexture; // static

uniform int uColorsExt;

uniform vec3 uCameraPosition; // static

varying vec3 vPosition;
varying vec4 vColor;
varying vec2 vTexCoord;

#pragma shady: inline(common_material.ALPHA_DISCARD_LIB)
#pragma shady: inline(common_color.COLOR_ADJUST_LIB)
#pragma shady: inline(common_effect.EFFECT_FOG_LIB)

void main()
{
	vec2 tex = vTexCoord;
	gl_FragColor = vColor * texture2D(uTexture, tex); // Get base
	
	handleAlphaDiscard(vPosition, gl_FragColor);
	
	if (uColorsExt > 0)
		applyColorTransform(gl_FragColor, true);

	gl_FragColor = mix(gl_FragColor, vec4(uFogColor.rgb, 1.0), getFog(vPosition, uCameraPosition)); // Mix fog
}
