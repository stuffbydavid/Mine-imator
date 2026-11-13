/// CppOnly #define CPP_DEPTH_ONLY 1

uniform sampler2D uTexture; // static

varying vec2 vTexCoord;
varying float vDepth;
varying vec4 vColor;

varying vec3 vPosition;

#pragma shady: inline(common_material.ALPHA_DISCARD_LIB)

void main()
{
	vec2 tex = vTexCoord;
	vec4 col = texture2D(uTexture, tex) * vColor;
	handleAlphaDiscard(vPosition, col);

	#ifndef CPP_DEPTH_ONLY
		gl_FragColor = vec4(vDepth);
	#endif
}
