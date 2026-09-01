uniform sampler2D uTexture; // static
uniform vec2 uTextureSize;

uniform float uGamma;

varying vec3 vPosition;
varying vec4 vColor;
varying vec2 vTexCoord;

#pragma shady: inline(common_material.ALPHA_DISCARD_LIB)
#pragma shady: inline(common_effect.EFFECT_GLINT_LIB)

void main()
{
	vec2 tex = vTexCoord;
	vec4 baseColor = vColor * texture2D(uTexture, tex);
	
	handleAlphaDiscard(vPosition, baseColor);
	baseColor.rgb = getGlint(baseColor, tex, uTextureSize, uGamma);
	
	gl_FragColor = baseColor;
}
