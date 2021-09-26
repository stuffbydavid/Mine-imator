uniform sampler2D uTexture;
uniform vec2 uTexScale;

uniform int uIsSky;

uniform int uLightAmount;
uniform vec4 uLightData[128];
uniform float uBrightness;
uniform int uIsWater;

uniform sampler2D uMaterialTexture;
uniform vec2 uMaterialTexScale;
uniform sampler2D uNormalTexture;
uniform vec2 uNormalTexScale;

varying vec3 vPosition;
varying vec3 vNormal;
varying vec4 vColor;
varying vec2 vTexCoord;
varying float vBrightness;
varying float vSSS;

#extension GL_OES_standard_derivatives : enable
vec3 getMappedNormal(vec3 normal, vec3 viewPos, vec3 worldPos, vec2 uv)
{
	if (uIsWater == 1)
		return normal;
	
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
	if (uNormalTexScale.x < 1.0 || uNormalTexScale.y < 1.0)
		normtex = mod(normtex * uNormalTexScale, uNormalTexScale); // GM sprite bug workaround
	
	vec3 normalCoord = texture2D(uNormalTexture, normtex).rgb * 2.0 - 1.0;
	
	if (normalCoord.z < 0.0)
		return normal;
	
	return normalize(TBN * normalCoord);
}

void main()
{
	vec2 tex = vTexCoord;
	if (uTexScale.x < 1.0 || uTexScale.y < 1.0)
		tex = mod(tex * uTexScale, uTexScale); // GM sprite bug workaround
	vec4 baseColor = vColor * texture2D(uTexture, tex); // Get base
	
	vec3 lightResult = vec3(0.0);
	
	if (uIsSky > 0)
		lightResult = vec3(1.0);
	else
	{
		// Get material data
		vec2 matTex = vTexCoord;
		if (uMaterialTexScale.x < 1.0 || uMaterialTexScale.y < 1.0)
			matTex = mod(matTex * uMaterialTexScale, uMaterialTexScale); // GM sprite bug workaround
		
		vec3 mat = texture2D(uMaterialTexture, matTex).rgb;
		float brightness = (vBrightness * mat.b);
		vec3 normal = getMappedNormal(normalize(vNormal), vPosition, vPosition, vTexCoord);
		
		for (int i = 0; i < uLightAmount; i++)
		{
			vec4 data1 = uLightData[i * 2];
			vec4 data2 = uLightData[i * 2 + 1];
			vec3 lightPosition = data1.xyz;
			float lightRange = data1.w, dis, att;
			float lightFadeSize = data2.w;
			
			// No use in shading a pixel if it's not in range
			if (distance(vPosition, lightPosition) > lightRange)
				continue;
			
			// Diffuse factor
			float dif = max(0.0, dot(normalize(normal), normalize(lightPosition - vPosition)));
			dif += vSSS;
			
			// Attenuation factor
			dif *= 1.0 - clamp((distance(vPosition, lightPosition) - lightRange * (1.0 - lightFadeSize)) / (lightRange * lightFadeSize), 0.0, 1.0);
		
			// Calculate light
			vec3 light;
			light = data2.rgb * dif;
			light = mix(light, vec3(1.0), brightness);
		
			lightResult.rgb += light;
		}
	}
	
	gl_FragColor = vec4(lightResult, baseColor.a);
	
	if (gl_FragColor.a == 0.0)
		discard;
}

