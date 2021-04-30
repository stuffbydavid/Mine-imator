uniform sampler2D uTexture;
uniform vec2 uTexScale;

uniform vec3 uCameraPosition;
uniform float uMetallic;
uniform float uRoughness;

varying vec3 vPosition;
varying vec3 vNormal;
varying vec4 vColor;
varying vec2 vTexCoord;

// Fresnel Schlick approximation
float fresnelSchlick(float cosTheta, float F0)
{
	return F0 + (1.0 - F0) * pow(max(1.0 - cosTheta, 0.0), 5.0);
}

void main()
{
	vec2 tex = vTexCoord;
	if (uTexScale.x < 1.0 || uTexScale.y < 1.0)
		tex = mod(tex * uTexScale, uTexScale); // GM sprite bug workaround
	
	vec4 baseColor = vColor * texture2D(uTexture, tex);
	
	vec3 mat;
	
	// Metallic
	mat.r = uMetallic;
	
	// Roughness
	mat.g = uRoughness;
	
	// Fresnel
	float F0 = 0.04;
	F0 = mix(F0, 0.0, uMetallic);
	
	vec3 V = normalize(vPosition - uCameraPosition);
	vec3 L = -normalize(reflect(V, normalize(vNormal)));
	vec3 H = V + L;
	float F = fresnelSchlick(max(dot(H, V), 0.0), F0);
	F *= 1.0 - pow(uRoughness, 8.0);
	
	mat.b = F;
	
	if (baseColor.a > 0.0)
		gl_FragColor = vec4(mat, 1.0);
	else
		discard;
}
