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

uniform sampler2D uDepthBufferXp;
uniform sampler2D uDepthBufferXn;
uniform sampler2D uDepthBufferYp;
uniform sampler2D uDepthBufferYn;
uniform sampler2D uDepthBufferZp;
uniform sampler2D uDepthBufferZn;

uniform float uSSS;
uniform vec3 uSSSRadius;
uniform vec4 uSSSColor;
uniform float uMetallic;

varying vec3 vPosition;
varying vec3 vNormal;
varying vec2 vTexCoord;
varying float vBrightness;
varying float vBlockSSS;

float unpackDepth(vec4 c)
{
	return c.r + c.g / 255.0 + c.b / (255.0 * 255.0);
}

vec4 texture2Dmap(int map, vec2 tex)
{
	if (map == 0) return texture2D(uDepthBufferXp, tex);
	else if (map == 1) return texture2D(uDepthBufferXn, tex);
	else if (map == 2) return texture2D(uDepthBufferYp, tex);
	else if (map == 3) return texture2D(uDepthBufferYn, tex);
	else if (map == 4) return texture2D(uDepthBufferZp, tex);
	else return texture2D(uDepthBufferZn, tex);
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
		float shadow = 1.0;
		float att = 0.0;
		vec3 subsurf = vec3(0.0);
		
		// Diffuse factor
		float dif = max(0.0, dot(normalize(vNormal), normalize(uLightPosition - vPosition))); 
		
		// Attenuation factor
		att = 1.0 - clamp((distance(vPosition, uLightPosition) - uLightFar * (1.0 - uLightFadeSize)) / (uLightFar * uLightFadeSize), 0.0, 1.0); 
		dif *= att;
		
		// Material
		dif *= 1.0 - uMetallic;
		
		if ((dif > 0.0 && vBrightness < 1.0) || sssEnabled > 0)
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
			if (lookDir.z > SQRT05 && lookDir.w > SQRT05)
			{ 
				buffer = 4;
				fragCoord = getShadowMapCoord(vec3(0.0, -0.0001, 1.0));
			}
		
			// Z-
			else if (lookDir.z < -SQRT05 && lookDir.w < -SQRT05)
			{
				buffer = 5;
				fragCoord = getShadowMapCoord(vec3(0.0, -0.0001, -1.0));
			}
		
			// X+
			else if (lookDir.x > SQRT05)
			{ 
				buffer = 0;
				fragCoord = getShadowMapCoord(vec3(1.0, 0.0, 0.0));
			}
		
			// X-
			else if (lookDir.x < -SQRT05)
			{
				buffer = 1;
				fragCoord = getShadowMapCoord(vec3(-1.0, 0.0, 0.0));
			}
		
			// Y+
			else if (lookDir.y > SQRT05)
			{ 
				buffer = 2;
				fragCoord = getShadowMapCoord(vec3(0.0, 1.0, 0.0));
			}
		
			// Y-
			else
			{ 
				buffer = 3;
				fragCoord = getShadowMapCoord(vec3(0.0, -1.0, 0.0));
			}
			
			// Calculate bias
			float bias = 1.0;
			
			// Shadow
			float fragDepth = distance(vPosition, uShadowPosition);
			float sampleDepth = uLightNear + (uLightFar - uLightNear) * unpackDepth(texture2Dmap(buffer, fragCoord));
			shadow = ((fragDepth - bias) > sampleDepth) ? 0.0 : 1.0;
			
			// Get subsurface translucency
			vec3 dis = vec3(uSSSRadius * max(uSSS, vBlockSSS));
			float lightdis = (fragDepth + bias) - sampleDepth;
			
			subsurf = vec3(vec3(1.0) - clamp(vec3(lightdis) / dis, vec3(0.0), vec3(1.0)));
			subsurf *= att;
		}
		
		// Translucency
		float transDif = max(0.0, dot(normalize(-vNormal), normalize(uLightPosition - vPosition)));
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
		
		light = mix(light, vec3(1.0), vBrightness);
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
