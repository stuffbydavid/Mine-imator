uniform sampler2D uTexture; // static
uniform vec4 uReplaceColor;
uniform int uColorsExt;
uniform vec3 uCameraPosition; // static

varying vec3 vPosition;
varying vec2 vTexCoord;
varying vec4 vColor;

#pragma shady: inline(common_material.ALPHA_DISCARD_LIB)
#pragma shady: inline(common_color.COLOR_ADJUST_LIB)
#pragma shady: inline(common_effect.EFFECT_FOG_LIB)

void main()
{
	vec2 tex = vTexCoord;
	vec4 basecolor = texture2D(uTexture, tex) * vColor;
	handleAlphaDiscard(vPosition, basecolor);
	if (uColorsExt > 0)
		applyColorTransform(basecolor, true);
	basecolor.rgb = mix(basecolor.rgb, uFogColor.rgb, getFog(vPosition, uCameraPosition));
	gl_FragColor = vec4(basecolor.rgb * uReplaceColor.rgb, basecolor.a);
}

