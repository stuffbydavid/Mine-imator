uniform sampler2D uTexture;
uniform float uSampleIndex;
uniform int uAlphaHash;
uniform vec4 uReplaceColor;
uniform float uGmDepth;

varying vec3 vPosition;
varying vec2 vTexCoord;
varying float vClipDepth;
varying vec3 vNormal;
varying vec4 vColor;

vec4 packDepth(float depth)
{
	depth = 1.0 - depth;
	return vec4(floor(depth * 255.0) / 255.0, fract(depth * 255.0), fract(depth * 255.0 * 255.0), 1.0);
}

void main()
{
	gl_FragData[0] = uReplaceColor;
	gl_FragData[1] = vec4((normalize(vNormal) + vec3(1.0)) * 0.5, 1.0);
	
	if (uGmDepth > 0.0)
		gl_FragData[2] = packDepth(vClipDepth * gl_FragCoord.w * 0.5 + 0.5);
}
