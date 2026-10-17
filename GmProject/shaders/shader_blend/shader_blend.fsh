uniform sampler2D uTexture; // static

varying vec3 vPosition;
varying vec2 vTexCoord;
varying vec4 vColor;

#pragma shady: inline(common_material.ALPHA_DISCARD_LIB)

void main()
{
	vec2 tex = vTexCoord;
	gl_FragColor = vColor * texture2D(uTexture, tex);
	
	handleAlphaDiscard(vPosition, gl_FragColor);
}