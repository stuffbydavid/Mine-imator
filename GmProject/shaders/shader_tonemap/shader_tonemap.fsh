varying vec2 vTexCoord;

uniform sampler2D uMask;

uniform int uTonemapper;
uniform float uExposure;
uniform float uGamma;

#pragma shady: inline(common_color.TONEMAP_LIB)

void main()
{
	vec4 baseColor = texture2D(gm_BaseTexture, vTexCoord);
	vec4 color = vec4(applyToneMapper(baseColor.rgb, uTonemapper, uExposure, uGamma), baseColor.a);
	
	gl_FragColor = mix(baseColor, color, texture2D(uMask, vTexCoord).r);
}