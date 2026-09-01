uniform sampler2D uTexture; // static

varying vec3 vPosition;
varying vec2 vTexCoord;
varying float vDepth;
varying vec4 vColor;

#pragma shady: inline(common_material.ALPHA_DISCARD_LIB)
#pragma shady: inline(common_util.PACK_VALUE_LIB)

void main()
{
	gl_FragColor = vec4(packValue(vDepth), 1.0);
	
	vec2 tex = vTexCoord;
	vec4 col = texture2D(uTexture, tex) * vColor;
	handleAlphaDiscard(vPosition, col);
}

