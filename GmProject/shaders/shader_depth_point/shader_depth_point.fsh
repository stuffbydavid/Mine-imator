uniform sampler2D uTexture; // static

uniform vec3 uEye; // static
uniform float uNear; // static
uniform float uFar; // static

varying vec3 vPosition;
varying vec2 vTexCoord;
varying vec4 vColor;

#pragma shady: inline(common_material.ALPHA_DISCARD_LIB)
#pragma shady: inline(common_util.PACK_VALUE_LIB)

void main()
{
	vec2 tex = vTexCoord;
	vec4 col = texture2D(uTexture, tex) * vColor;
	handleAlphaDiscard(vPosition, col);
	
	gl_FragColor = vec4(packValue((distance(vPosition, uEye) - uNear) / (uFar - uNear)), 1.0);
}

