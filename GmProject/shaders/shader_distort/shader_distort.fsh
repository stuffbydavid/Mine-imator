varying vec2 vTexCoord;

#pragma shady: inline(common_effect.EFFECT_DISTORT_LIB)

void main()
{
	gl_FragColor = applyDistortion(vTexCoord);
}
