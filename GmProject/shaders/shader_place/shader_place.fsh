uniform sampler2D uTexture;
uniform float uSampleIndex;
uniform int uAlphaHash;
uniform vec4 uReplaceColor;
uniform float uGmDepth;
uniform float uIsBlock;

varying vec3 vPosition;
varying vec2 vTexCoord;
varying float vClipDepth;
varying vec3 vNormal;
varying vec4 vColor;

#pragma shady: inline(common_place.PLACE_FRAGMENT_LIB)

void main()
{
	// Ignore transparent texels on non-block objects
	if (uIsBlock == 0.0 && (vColor * texture2D(uTexture, vTexCoord)).a < 0.05)
		discard;
	
	gl_FragData[0] = getPlaceColor(uReplaceColor.rgb, vNormal);
	
	if (uGmDepth > 0.0)
		gl_FragData[1] = vec4(max(0.0, 1.0 - (vClipDepth * gl_FragCoord.w * 0.5 + 0.5)));
}
