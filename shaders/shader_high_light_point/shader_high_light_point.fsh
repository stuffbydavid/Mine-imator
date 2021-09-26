#define SQRT05 0.707106781
#define PI 3.14159265

uniform sampler2D uTexture;
uniform vec2 uTexScale;
uniform vec4 uBlendColor;
uniform int uIsSky;
uniform int uIsWater;

uniform vec3 uLightPosition;
uniform vec4 uLightColor;
uniform float uLightStrength;
uniform float uLightNear;
uniform float uLightFar;
uniform float uLightFadeSize;
uniform vec3 uShadowPosition;

uniform sampler2D uDepthBuffer;

uniform sampler2D uMaterialTexture;
uniform vec2 uMaterialTexScale;
uniform sampler2D uNormalTexture;
uniform vec2 uNormalTexScale;

uniform float uSSS;
uniform vec3 uSSSRadius;
uniform vec4 uSSSColor;

varying vec3 vPosition;
varying vec3 vNormal;
varying vec2 vTexCoord;
varying float vBrightness;
varying float vBlockSSS;

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

float unpackDepth(vec4 c)
{
	return c.r + c.g / 255.0 + c.b / (255.0 * 255.0);
}

vec2 getShadowMapCoord(vec3 look)
{
	float tFOV = tan(PI / 4.0);
	vec3 u, v, toPoint = vPosition - uShadowPosition;
	vec2 coord;
	
	// Prepare 3D to 2D conversion
	look /= sqrt(dot(look, look));
	u = vec3(-look.z * look.x, -look.z * look.y, 1.0 - look.z * look.z);
	u /= sqrt(dot(u, u));
	u *= tFOV; 
	v = vec3(u.y * look.z - look.y * u.z, u.z * look.x - look.z * u.x, u.x * look.y - look.x * u.y);
	
	// Convert
	toPoint /= dot(toPoint,look);
	coord.x = (dot(toPoint, v) / (tFOV * tFOV) + 1.0) * 0.5;
	coord.y = (1.0 - dot(toPoint, u) / (tFOV * tFOV)) * 0.5;
	
	coord.x /= 3.0;
	coord.y *= 0.5;
	
	return coord;
}

void main()
{
	vec3 light;
	int sssEnabled = (vBlockSSS + uSSS > 0.0 ? 1 : 0);
	
	if (uIsSky > 0)
		light = vec3(1.0);
	else
	{
		// Get material data
		vec2 matTex = vTexCoord;
		if (uMaterialTexScale.x < 1.0 || uMaterialTexScale.y < 1.0)
			matTex = mod(matTex * uMaterialTexScale, uMaterialTexScale); // GM sprite bug workaround
		
		vec3 mat = texture2D(uMaterialTexture, matTex).rgb;
		float brightness = (vBrightness * mat.b);
		
		float shadow = 1.0;
		float att = 0.0;
		vec3 subsurf = vec3(0.0);
		
		// Diffuse factor
		vec3 normal = getMappedNormal(normalize(vNormal), vPosition, vPosition, vTexCoord);
		float dif = max(0.0, dot(normalize(normal), normalize(uLightPosition - vPosition))); 
		
		// Attenuation factor
		att = 1.0 - clamp((distance(vPosition, uLightPosition) - uLightFar * (1.0 - uLightFadeSize)) / (uLightFar * uLightFadeSize), 0.0, 1.0); 
		dif *= att;
		
		if ((dif > 0.0 && brightness < 1.0) || sssEnabled > 0)
		{
			int buffer;
			vec2 fragCoord;
			vec3 toLight = vPosition - uShadowPosition;
			vec4 lookDir = vec4( // Get the direction from the pixel to the light
				toLight.x / distance(vPosition.xy, uShadowPosition.xy),
				toLight.y / distance(vPosition.xy, uShadowPosition.xy),
				toLight.z / distance(vPosition.xz, uShadowPosition.xz),
				toLight.z / distance(vPosition.yz, uShadowPosition.yz)
			);
		
			// Get shadow map and texture coordinate
		
			// Z+
			// ooo
			// oxo
			if (lookDir.z > SQRT05 && lookDir.w > SQRT05)
			{ 
				buffer = 4;
				fragCoord = getShadowMapCoord(vec3(0.0, -0.0001, 1.0));
				fragCoord.x += 1.0/3.0;
				fragCoord.y += 0.5;
			}
			
			// Z-
			// ooo
			// oox
			else if (lookDir.z < -SQRT05 && lookDir.w < -SQRT05)
			{
				buffer = 5;
				fragCoord = getShadowMapCoord(vec3(0.0, -0.0001, -1.0));
				fragCoord.x += 2.0/3.0;
				fragCoord.y += 0.5;
			}
		
			// X+
			// xoo
			// ooo
			else if (lookDir.x > SQRT05)
			{ 
				buffer = 0;
				fragCoord = getShadowMapCoord(vec3(1.0, 0.0, 0.0));
			}
		
			// X-
			// oxo
			// ooo
			else if (lookDir.x < -SQRT05)
			{
				buffer = 1;
				fragCoord = getShadowMapCoord(vec3(-1.0, 0.0, 0.0));
				fragCoord.x += 1.0/3.0;
			}
		
			// Y+
			// oox
			// ooo
			else if (lookDir.y > SQRT05)
			{ 
				buffer = 2;
				fragCoord = getShadowMapCoord(vec3(0.0, 1.0, 0.0));
				fragCoord.x += 2.0/3.0;
			}
		
			// Y-
			// ooo
			// xoo
			else
			{ 
				buffer = 3;
				fragCoord = getShadowMapCoord(vec3(0.0, -1.0, 0.0));
				fragCoord.y += 0.5;
			}
			
			// Calculate bias
			float bias = 1.0;
			
			// Shadow
			float fragDepth = distance(vPosition, uShadowPosition);
			float sampleDepth = uLightNear + (uLightFar - uLightNear) * unpackDepth(texture2D(uDepthBuffer, fragCoord));
			shadow = ((fragDepth - bias) > sampleDepth) ? 0.0 : 1.0;
			
			// Get subsurface translucency
			vec3 dis = vec3(uSSSRadius * max(uSSS, vBlockSSS));
			float lightdis = (fragDepth + bias) - sampleDepth;
			
			subsurf = vec3(vec3(1.0) - clamp(vec3(lightdis) / dis, vec3(0.0), vec3(1.0)));
			subsurf *= att;
		}
		
		// Translucency
		float transDif = max(0.0, dot(normalize(-normal), normalize(uLightPosition - vPosition)));
		transDif = clamp(transDif, 0.0, 1.0);
		subsurf *= (uLightColor.rgb * uLightStrength * uSSSColor.rgb * transDif);
		
		// Disable translucency on diffuse
		subsurf *= (dif > 0.0 ? 0.0 : 1.0);
		
		// Calculate light
		if (uIsWater == 1)
			light = uLightColor.rgb * uLightStrength * dif;
		else
			light = uLightColor.rgb * uLightStrength * dif * shadow;
		
		light += subsurf;
		light *= mix(vec3(1.0), uSSSColor.rgb, clamp(uSSS/16.0, 0.0, 1.0));
		
		light = mix(light, vec3(1.0), brightness);
	}
	
	// Set final color
	vec2 tex = vTexCoord;
	if (uTexScale.x < 1.0 || uTexScale.y < 1.0)
		tex = mod(tex * uTexScale, uTexScale); // GM sprite bug workaround
	vec4 baseColor = texture2D(uTexture, tex);
	gl_FragColor = vec4(light, uBlendColor.a * baseColor.a);
	
	if (gl_FragColor.a == 0.0)
		discard;
}
