varying vec2 vTexCoord;

#pragma shady: inline(common_effect.EFFECT_COLOR_CORRECTION_LIB)

void main()
{
	gl_FragColor = applyColorCorrection(texture2D(gm_BaseTexture, vTexCoord));
}
