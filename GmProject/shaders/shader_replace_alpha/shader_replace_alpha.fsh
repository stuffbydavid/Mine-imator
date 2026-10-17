uniform sampler2D uTexture; // static
uniform vec4 uReplaceColor;

varying vec3 vPosition;
varying vec2 vTexCoord;
varying vec4 vColor;

#pragma shady: inline(common_material.ALPHA_DISCARD_LIB)

void main()
{
	vec2 tex = vTexCoord;
	vec4 basecolor = texture2D(uTexture, tex) * vColor;
	gl_FragColor = vec4(uReplaceColor.rgb, basecolor.a);
	
	handleAlphaDiscard(vPosition, gl_FragColor);
}

