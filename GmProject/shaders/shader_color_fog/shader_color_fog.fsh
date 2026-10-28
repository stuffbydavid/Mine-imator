uniform sampler2D uTexture; // static

uniform int uColorsExt;
uniform vec4 uReplaceColor;
uniform int uTonemapper;
uniform float uExposure;
uniform float uGamma;

uniform vec3 uCameraPosition; // static
uniform int uFogPass; // static

varying vec3 vPosition;
varying vec4 vColor;
varying vec2 vTexCoord;

#pragma shady: inline(common_material.ALPHA_DISCARD_LIB)
#pragma shady: inline(common_color.COLOR_ADJUST_LIB)
#pragma shady: inline(common_color.TONEMAP_LIB)
#pragma shady: inline(common_effect.EFFECT_FOG_LIB)

void main()
{
	vec2 tex = vTexCoord;
	gl_FragData[0] = vColor * texture2D(uTexture, tex); // Get base
	
	handleAlphaDiscard(vPosition, gl_FragData[0]);
	
	if (uColorsExt > 0)
		applyColorTransform(gl_FragData[0], true);

	if (uTonemapper > 0)
		gl_FragData[0].rgb = applyToneMapper(gl_FragData[0].rgb, uTonemapper, uExposure, uGamma);
	
	float fog = getFog(vPosition, uCameraPosition);
	if (uFogPass > 0)
		gl_FragData[2] = vec4(vec3(fog), 1.0);
	else
	{
		gl_FragData[2] = vec4(0.0);
		gl_FragData[0].rgb = mix(gl_FragData[0].rgb, uFogColor.rgb, fog); // Mix fog
	}
	
	gl_FragData[1] = vec4(uReplaceColor.rgb, gl_FragData[0].a);
}
