uniform vec4 uBlendColor;
uniform float uBrightness;
uniform int uSSAOEnable;

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

vec4 packDepth(float f)
{
	 return vec4(floor(f * 255.0) / 255.0, fract(f * 255.0), fract(f * 255.0 * 255.0), 1.0);
}

vec4 packNormal(vec3 n)
{
	return vec4((n + vec3(1.0, 1.0, 1.0)) * 0.5, 1.0);
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
	vec3 T = normalize(posPy * texDx.x + posPx * texDy.x);
	T = normalize(T - dot(T, normal) * normal);
	vec3 B = cross(normal, T);
	
	// Create a Scale-invariant frame
	float invmax = pow(max(dot(T, T), dot(B, B)), -0.5);  
	
	// Build TBN matrix to transform mapped normal with mesh
	mat3 TBN = mat3(T * invmax, B * invmax, normal);
	
	// Get normal value from normal map
	vec2 normtex = uv;
	if (uTexScaleNormal.x < 1.0 || uTexScaleNormal.y < 1.0)
		normtex = mod(normtex * uTexScaleNormal, uTexScaleNormal); // GM sprite bug workaround
	
	vec3 normalCoord = texture2D(uTextureNormal, normtex).rgb * 2.0 - 1.0;
	
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
	
	// Normal
	vec3 N = getMappedNormal(normalize(vNormal), vWorldPosition, vTexCoord);
	N = normalize(N * vWorldInv);
	N = normalize(vWorldViewInv * N);
	gl_FragData[1] = packNormal(N);
	
	// Brightness of SSAO
	float br;
	if (uSSAOEnable > 0)
	{
		vec2 texMat = vTexCoord;
		if (uTexScaleMaterial.x < 1.0 || uTexScaleMaterial.y < 1.0)
			texMat = mod(tex * uTexScaleMaterial, uTexScaleMaterial); // GM sprite bug workaround
		
		float mat = texture2D(uTextureMaterial, texMat).b;
		br = max(0.0, baseColor.a - ((uBrightness + vCustom.z) * mat));
	}
	else
		br = 0.0;
	
	gl_FragData[2] = vec4(br, br, br, 1.0);
}