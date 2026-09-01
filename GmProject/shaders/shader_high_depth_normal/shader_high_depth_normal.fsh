uniform sampler2D uTexture; // static

varying vec3 vPosition;
varying vec2 vTexCoord;
varying float vDepth;
varying vec4 vColor;
varying vec3 vNormal;
varying vec3 vTangent;

#pragma shady: inline(common_util.TBN_LIB)
#pragma shady: inline(common_material.NORMAL_MAP_LIB)
#pragma shady: inline(common_material.ALPHA_DISCARD_LIB)
#pragma shady: inline(common_util.NORMAL_BUFFER_LIB)

void main()
{
	vec2 tex = vTexCoord;
	vec4 baseColor = vColor * texture2D(uTexture, tex);
	
	handleAlphaDiscard(vPosition, baseColor);
	
	// Depth
	gl_FragData[0] = vec4(vDepth);
	
	// Normal
	gl_FragData[1] = packNormal(getMappedNormal(tex, getTBN(vNormal, vTangent)));
}
