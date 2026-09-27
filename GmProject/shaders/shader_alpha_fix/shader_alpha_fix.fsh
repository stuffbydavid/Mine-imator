uniform sampler2D uTexture; // static

varying vec3 vPosition;
varying vec2 vTexCoord;

#pragma shady: inline(common_material.ALPHA_DISCARD_LIB)

void main()
{
	vec2 tex = vTexCoord;
	vec4 baseColor = texture2D(uTexture, tex);
	handleAlphaDiscard(vPosition, baseColor);
	
	gl_FragColor = vec4(0.0, 0.0, 0.0, baseColor.a);
}

