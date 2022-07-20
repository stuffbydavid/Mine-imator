uniform vec4 uBlendColor;
uniform int uIsWater;

uniform sampler2D uTexture;
uniform vec2 uTexScale;
uniform sampler2D uTextureNormal;
uniform vec2 uTexScaleNormal;

varying vec3 vPosition;
varying vec2 vTexCoord;
varying float vDepth;
varying vec3 vNormal;
varying vec3 vTangent;
varying vec4 vColor;
varying vec4 vCustom;
varying mat3 vWorldInv;
varying mat3 vWorldViewInv;
varying float vTime;
varying float vWindDirection;

vec4 packDepth(float f)
{
	return vec4(floor(f * 255.0) / 255.0, fract(f * 255.0), fract(f * 255.0 * 255.0), 1.0);
}

vec4 packNormal(vec3 n)
{
	return vec4((n + vec3(1.0, 1.0, 1.0)) * 0.5, 1.0);
}

vec2 packFloat2(float f)
{
	return vec2(floor(f / 255.0) / 255.0, fract(f / 255.0));
}

vec3 getMappedNormal(vec2 uv)
{
	vec3 texColor = normalize(texture2D(uTextureNormal, uv).rgb * 2.0 - 1.0);
	
	if ((texColor.r + texColor.g + texColor.b) < 0.001)
		return vNormal;
	
	mat3 TBN = mat3(vTangent, cross(vTangent, vNormal), vNormal);
	return normalize(TBN * texColor);
}

void main()
{
	vec2 tex = vTexCoord;
	if (uTexScale.x < 1.0 || uTexScale.y < 1.0)
		tex = mod(tex * uTexScale, uTexScale); // GM sprite bug workaround
	
	vec2 normalTex = vTexCoord;
	if (uTexScaleNormal.x < 1.0 || uTexScaleNormal.y < 1.0)
		normalTex = mod(normalTex * uTexScaleNormal, uTexScaleNormal); // GM sprite bug workaround
	
	vec4 baseColor = uBlendColor * vColor * texture2D(uTexture, tex);
	
	if (baseColor.a == 0.0)
		discard;
	
	// Depth
	gl_FragData[0] = packDepth(vDepth);
	
	// Calculate normal
	vec3 N = packNormal(getMappedNormal(normalTex)).xyz;
	
	// Normal X
	vec2 channel = vec2(0.0);
	channel = packFloat2(N.r * 255.0 * 255.0);
	gl_FragData[1].r = channel.y;
	gl_FragData[2].r = channel.x;
	
	// Normal Y
	channel = packFloat2(N.g * 255.0 * 255.0);
	gl_FragData[1].g = channel.y;
	gl_FragData[2].g = channel.x;
	
	// Normal Z
	channel = packFloat2(N.b * 255.0 * 255.0);
	gl_FragData[1].b = channel.y;
	gl_FragData[2].b = channel.x;
	
	gl_FragData[1].a = 1.0;
	gl_FragData[2].a = 1.0;
}