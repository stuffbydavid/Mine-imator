uniform sampler2D uTexture; // static

uniform float uSampleIndex;
uniform int uAlphaHash;

uniform vec3 uEye; // static
uniform float uNear; // static
uniform float uFar; // static

varying vec3 vPosition;
varying vec2 vTexCoord;
varying vec4 vColor;

vec4 packDepth(float f)
{
	 return vec4(floor(f * 255.0) / 255.0, fract(f * 255.0), fract(f * 255.0 * 255.0), 1.0);
}

float hash(vec2 c)
{
	return fract(10000.0 * sin(17.0 * c.x + 0.1 * c.y) *
	(0.1 + abs(sin(13.0 * c.y + c.x))));
}

void main()
{
	vec2 tex = vTexCoord;
	vec4 col = texture2D(uTexture, tex) * vColor;
	if (col.a < 0.001)
		discard;
	
	if (uAlphaHash > 0 && (col.a < hash(vec2(hash(vPosition.xy + (uSampleIndex / 255.0)), vPosition.z + (uSampleIndex / 255.0)))))
		discard;
	
	gl_FragColor = packDepth((distance(vPosition, uEye) - uNear) / (uFar - uNear));
}

