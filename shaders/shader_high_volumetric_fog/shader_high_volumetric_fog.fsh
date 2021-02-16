#define PI 3.14159265
#define STEPS 16

varying vec2 vTexCoord;

uniform float uNear;
uniform float uFar;
uniform float uSunNear;
uniform float uSunFar;

uniform mat4 uOffset;

uniform int uRaysOnly;
uniform float uScattering;
uniform float uDensity;

uniform float uFogHeight;
uniform float uFogHeightFade;
uniform float uFogNoiseScale;
uniform float uFogNoiseContrast;

uniform float uTime;
uniform float uFogWind;
uniform float uWindDirection;
uniform float uWindDirectionalSpeed;

uniform vec3 uCameraPosition;
uniform vec3 uSunDirection;
uniform vec2 uScreenSize;

uniform mat4 uSunMatrix;
uniform mat4 uProjMatrixInv;
uniform mat4 uViewMatrixInv;

uniform sampler2D uDepthBuffer;
uniform sampler2D uSunDepthBuffer;

/*
	3D simplex noise
	
	Copyright © 2013 Nikita Miropolskiy
	https://www.shadertoy.com/view/XsX3zB
	
	=================================================================================
*/

/* skew constants for 3d simplex functions */
const float F3 =  0.3333333;
const float G3 =  0.1666667;

/* const matrices for 3d rotation */
const mat3 rot1 = mat3(-0.37, 0.36, 0.85,-0.14,-0.93, 0.34,0.92, 0.01,0.4);
const mat3 rot2 = mat3(-0.55,-0.39, 0.74, 0.33,-0.91,-0.24,0.77, 0.12,0.63);
const mat3 rot3 = mat3(-0.71, 0.52,-0.47,-0.08,-0.72,-0.68,-0.7,-0.45,0.56);

/* discontinuous pseudorandom uniformly distributed in [-0.5, +0.5]^3 */
vec3 random3(vec3 c) {
	float j = 4096.0*sin(dot(c,vec3(17.0, 59.4, 15.0)));
	vec3 r;
	r.z = fract(512.0*j);
	j *= .125;
	r.x = fract(512.0*j);
	j *= .125;
	r.y = fract(512.0*j);
	return r-0.5;
}

/* 3d simplex noise */
float simplex3d(vec3 p) {
	 /* 1. find current tetrahedron T and it's four vertices */
	 /* s, s+i1, s+i2, s+1.0 - absolute skewed (integer) coordinates of T vertices */
	 /* x, x1, x2, x3 - unskewed coordinates of p relative to each of T vertices*/
	 
	 /* calculate s and x */
	 vec3 s = floor(p + dot(p, vec3(F3)));
	 vec3 x = p - s + dot(s, vec3(G3));
	 
	 /* calculate i1 and i2 */
	 vec3 e = step(vec3(0.0), x - x.yzx);
	 vec3 i1 = e*(1.0 - e.zxy);
	 vec3 i2 = 1.0 - e.zxy*(1.0 - e);
	 	
	 /* x1, x2, x3 */
	 vec3 x1 = x - i1 + G3;
	 vec3 x2 = x - i2 + 2.0*G3;
	 vec3 x3 = x - 1.0 + 3.0*G3;
	 
	 /* 2. find four surflets and store them in d */
	 vec4 w, d;
	 
	 /* calculate surflet weights */
	 w.x = dot(x, x);
	 w.y = dot(x1, x1);
	 w.z = dot(x2, x2);
	 w.w = dot(x3, x3);
	 
	 /* w fades from 0.6 at the center of the surflet to 0.0 at the margin */
	 w = max(0.6 - w, 0.0);
	 
	 /* calculate surflet components */
	 d.x = dot(random3(s), x);
	 d.y = dot(random3(s + i1), x1);
	 d.z = dot(random3(s + i2), x2);
	 d.w = dot(random3(s + 1.0), x3);
	 
	 /* multiply d by w^4 */
	 w *= w;
	 w *= w;
	 d *= w;
	 
	 /* 3. return the sum of the four surflets */
	 return dot(d, vec4(52.0));
}

/* directional artifacts can be reduced by rotating each octave */
float simplex3dFractal(vec3 m) {
    return  0.5333333 * simplex3d(m * rot1)
			+ 0.2666667 * simplex3d(2.0 * m * rot2)
			+ 0.1333333 * simplex3d(4.0 * m * rot3);
}

// =================================================================================

// Cornette-Shanks phase function
float CSPhase(float dotView)
{
	float result = (3.0 * (1.0 - (uScattering * uScattering))) * (1.0 + dotView);
	result /= 2.0 * (2.0 + pow(uScattering, 2.0)) * pow(1.0 + pow(uScattering, 2.0) - 2.0 * uScattering * dotView, 1.5);
	return result;
}

// Rayleigh scatter
float reyleighPhase(float dotView)
{
	float result = 3.0 * (1.0 + dotView);
	result /= (16.0 * PI);
	return result;
}

// Transform linear depth to exponential depth
float transformDepth(float depth)
{
	return (uFar - (uNear * uFar) / (depth * (uFar - uNear) + uNear)) / (uFar - uNear);
}

// Reconstruct a position from a screen space coordinate and (linear) depth
vec3 posFromBuffer(vec2 coord, float depth)
{
	vec4 pos = uProjMatrixInv * vec4(coord.x * 2.0 - 1.0, 1.0 - coord.y * 2.0, transformDepth(depth), 1.0);
	pos /= pos.w;
	return (uViewMatrixInv * pos).xyz;
}

float unpackDepth(vec4 c)
{
	return c.r + c.g / 255.0 + c.b / (255.0 * 255.0) + c.a / (255.0 * 255.0 * 255.0);
}

// Determine if point is in sun light
float getLight(vec3 pos)
{
	vec4 screenCoord = uSunMatrix * vec4(pos, 1.0);
		
    float fragDepth = screenCoord.z * .5 + .5;
    vec2 fragCoord = vec2(screenCoord.x, -screenCoord.y) * .5 + .5;
	
    if (fragCoord.x > 0.0 && fragCoord.y > 0.0 && fragDepth > 0.0 && fragCoord.x < 1.0 && fragCoord.y < 1.0 && fragDepth < 1.0)
	{	
        float sampleDepth = unpackDepth(texture2D(uSunDepthBuffer, fragCoord));
		float bias = 1.0 / abs(uSunFar - uSunNear);
		
        if ((fragDepth - bias) < sampleDepth)
            return 1.0;
		else
			return 0.0;
    }
	
	return 1.0;
}

float getFog(vec3 pos)
{
	if (pos.z > (uFogHeight - uFogHeightFade))
	{
		float start = (uFogHeight - uFogHeightFade);
		float end = uFogHeight;
		
		return clamp((pos.z - end) / (start - end), 0.0, 1.0);
	}
	else
		return 1.0;
}

float getDensity(vec3 pos, vec3 wind)
{
	float fogDensity = simplex3dFractal((pos / uFogNoiseScale) + wind);
	fogDensity = getFog(pos) * ((fogDensity * .5) + .5);
	return clamp((fogDensity - 0.5) * uFogNoiseContrast + 0.5, 0.0, 1.0) * uDensity;
}

void main()
{
	// Get start/end points of ray
	float depth = unpackDepth(texture2D(uDepthBuffer, vTexCoord));
	vec3 wp = posFromBuffer(vTexCoord, depth);
    vec3 startPos = uCameraPosition;
	
	// Get ray direction
    vec3 rayVector = wp - startPos;
    float rayLength = length(rayVector);
    vec3 rayDirection = rayVector / rayLength;
	
	// Get ray step size
    float stepLength = rayLength / float(STEPS);
    vec3 stepSize = rayDirection * stepLength;
	
	// Get sun scatter
	float theta = dot(rayDirection, uSunDirection);
	float scatter = CSPhase(theta) * reyleighPhase(theta);
	
	// Wind offset
	vec3 fogOffset = vec3(uTime * uWindDirectionalSpeed * uFogWind * vec2(cos(uWindDirection), sin(uWindDirection)), 0.0);
	
	// Opacity determine mix % when applying to scene
	float fogOpacity = 0.0;
	
	// Lighting of fog, 0 = ambient, 1 = ambient + sun
	float fogLight = 0.0;
	
	// Determines visibility of each density sample along ray
	float fogTransmittance = 1.0;
	
	// Ray march (Offset starting position with dither)
	vec3 rayPos = startPos;
	float offset = uOffset[int(mod(vTexCoord.x * uScreenSize.x, 4.0))][int(mod(vTexCoord.y * uScreenSize.y, 4.0))];
	rayPos += stepSize * offset;
	
	float sampleDensity;
	
	// Volumetric rays
	float raysOpacity = 1.0;
	float extinction = mix((1.0 - uDensity), 0.0, 0.5);
	
	// Sample steps along ray
    for (int i = 0; i < STEPS; i++)
    {	
		// Volumetric fog
		if (uRaysOnly == 0)
		{
			sampleDensity = stepLength * getDensity(rayPos, fogOffset);
		
			float extinction = sampleDensity;
			fogTransmittance *= clamp(1.0 - (extinction / stepLength), 0.0, 1.0);
		
			fogLight += getLight(rayPos) * sampleDensity * fogTransmittance * scatter;
			fogOpacity += sampleDensity;
		}
		else // Only calculate volumetric rays
		{
			fogLight += getLight(rayPos) * mix(uDensity, 0.0, 0.5);
			raysOpacity *= clamp(1.0 - (extinction / stepLength), 0.0, 1.0);
		}
		
		rayPos += stepSize;
	}
	
	if (uRaysOnly == 1)
		fogLight *= raysOpacity;
	
	fogOpacity = clamp(fogOpacity, 0.0, 1.0);
	fogLight = clamp(fogLight, 0.0, 4.0) * 0.25;
	
	// Alpha channel isn't reliable, use RGB for data
	gl_FragColor = vec4(fogOpacity, fogLight, 0.0, 1.0);
}
