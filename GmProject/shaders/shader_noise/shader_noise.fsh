varying vec2 vTexCoord;

#pragma shady: inline(common_effect.EFFECT_NOISE_LIB)

void main()
{
	gl_FragColor = applyNoise(texture2D(gm_BaseTexture, vTexCoord), vTexCoord);
}
