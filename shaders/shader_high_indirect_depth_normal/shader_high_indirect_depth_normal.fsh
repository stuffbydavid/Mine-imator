uniform vec4 uBlendColor;
uniform float uBrightness;
uniform int uIsWater;

uniform sampler2D uTexture;
uniform vec2 uTexScale;
uniform sampler2D uTextureMaterial;
uniform vec2 uTexScaleMaterial;
uniform sampler2D uTextureNormal;
uniform vec2 uTexScaleNormal;

varying vec4 vPosition;
varying vec2 vTexCoord;
varying float vDepth;
varying vec3 vNormal;
varying vec4 vColor;
varying vec4 vCustom;
varying vec3 vWorldPosition;
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

#extension GL_OES_standard_derivatives : enable
vec3 getMappedNormal(vec3 normal, vec3 worldPos, vec2 uv)
{
	// Get edge derivatives
	vec3 posDx = dFdx(worldPos);
	vec3 posDy = dFdy(worldPos);
	vec2 texDx = dFdx(uv);
	vec2 texDy = dFdy(uv);
	
	// Calculate tangent/bitangent
	vec3 posPx = cross(normal, posDx);
	vec3 posPy = cross(posDy, normal);
	vec3 T = posPy * texDx.x + posPx * texDy.x;
	vec3 B = posPy * texDx.y + posPx * texDy.y;
	
	// Create a Scale-invariant frame
	float invmax = pow(max(dot(T, T), dot(B, B)), -0.5);  
	
	// Build TBN matrix to transform mapped normal with mesh
	mat3 TBN = mat3(T * invmax, B * invmax, normal);
	
	// Get normal value from normal map
	vec2 normtex = uv;
	if (uTexScaleNormal.x < 1.0 || uTexScaleNormal.y < 1.0)
		normtex = mod(normtex * uTexScaleNormal, uTexScaleNormal); // GM sprite bug workaround
	
	if (uIsWater > 0)
	{
		vec2 angle = vec2(cos(vWindDirection), sin(vWindDirection)) * .125 * vTime;
		normtex = (worldPos.xy + angle) / 128.0;
	}
	
	vec3 normalCoord = texture2D(uTextureNormal, normtex).rgb * 2.0 - 1.0;
	
	if (uIsWater > 0)
		normalCoord = mix(normalCoord, vec3(0.0, 0.0, 1.0), .9);
	
	if (normalCoord.z < 0.0)
		return normal;
	
	return normalize(TBN * normalCoord);
}

void main()
{
	vec2 tex = vTexCoord;
	if (uTexScale.x < 1.0 || uTexScale.y < 1.0)
		tex = mod(tex * uTexScale, uTexScale); // GM sprite bug workaround
	
	vec4 baseColor = uBlendColor * vColor * texture2D(uTexture, tex);
	
	if (floor(baseColor.a * 255.0) < 254.0)
		discard;
	
	// Depth
	gl_FragData[0] = packDepth(vDepth);
	
	// Calculate normal
	vec3 N = getMappedNormal(normalize(vNormal), vWorldPosition, vTexCoord);
	N = normalize(N * vWorldInv);
	N = normalize(vWorldViewInv * N);
	N = packNormal(N).xyz;
	
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
	
	// Brightness
	vec2 texMat = vTexCoord;
	if (uTexScaleMaterial.x < 1.0 || uTexScaleMaterial.y < 1.0)
		texMat = mod(tex * uTexScaleMaterial, uTexScaleMaterial); // GM sprite bug workaround
	
	float mat = texture2D(uTextureMaterial, texMat).b;
	float br = max(0.0, baseColor.a * ((uBrightness + vCustom.z) * mat));
	
	gl_FragData[3] = vec4(br, br, br, 1.0);
}