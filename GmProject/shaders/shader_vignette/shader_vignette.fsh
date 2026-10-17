varying vec2 vTexCoord;

#pragma shady: inline(common_effect.EFFECT_VIGNETTE_LIB)

void main()
{
	gl_FragColor = applyVignette(texture2D(gm_BaseTexture, vTexCoord), vTexCoord);
}
