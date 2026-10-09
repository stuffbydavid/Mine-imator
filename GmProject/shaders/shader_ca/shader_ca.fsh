varying vec2 vTexCoord;

#pragma shady: inline(common_effect.EFFECT_CHROMATIC_ABERRATION_LIB)

void main()
{
	gl_FragColor = applyChromaticAberration(vTexCoord);
}
