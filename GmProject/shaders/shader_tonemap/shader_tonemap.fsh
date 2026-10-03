varying vec2 vTexCoord;

uniform int uTonemapper;
uniform float uExposure;
uniform float uGamma;

#pragma shady: inline(common_color.TONEMAP_LIB)

void main()
{
	vec4 baseColor = texture2D(gm_BaseTexture, vTexCoord);
	gl_FragColor = vec4(applyToneMapper(baseColor.rgb, uTonemapper, uExposure, uGamma), baseColor.a);
}