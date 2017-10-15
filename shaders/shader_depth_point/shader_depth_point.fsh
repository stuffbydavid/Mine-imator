uniform sampler2D uTexture;
uniform vec2 uTexScale;

uniform vec3 uEye;
uniform float uNear;
uniform float uFar;

varying vec3 vPosition;
varying vec2 vTexCoord;

vec4 packDepth(float f)
{
	 return vec4(floor(f * 255.0) / 255.0, fract(f * 255.0), fract(f * 255.0 * 255.0), 1.0);
}

void main()
{
	vec2 tex = vTexCoord;
	if (uTexScale.x < 1.0 || uTexScale.y < 1.0)
		tex = mod(tex * uTexScale, uTexScale); // GM sprite bug workaround
	if (texture2D(uTexture, tex).a == 0.0)
		discard;
	
	gl_FragColor = packDepth((distance(vPosition, uEye) - uNear) / (uFar - uNear));
}

