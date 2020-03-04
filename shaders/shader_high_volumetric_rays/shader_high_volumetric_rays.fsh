#define PI 3.14159265
#define STEPS 64

mat4 dither = mat4( 0.0, 0.5, 0.125, 0.625,
					0.75, 0.22, 0.875, 0.375,
					0.1875, 0.6875, 0.0625, 0.5625,
					0.9375, 0.4375, 0.8125, 0.3125);

varying vec2 vTexCoord;

uniform float uNear;
uniform float uFar;
uniform float uSunNear;
uniform float uSunFar;
uniform float uScattering;
uniform float uDensity;
uniform vec3 uCameraPosition;
uniform vec3 uSunDirection;
uniform vec2 uScreenSize;

uniform vec4 uColor;
uniform vec4 uSunColor;
uniform vec4 uEmissiveColor;
uniform mat4 uSunMatrix;
uniform mat4 uProjMatrixInv;
uniform mat4 uViewMatrixInv;

uniform sampler2D uDepthBuffer;
uniform sampler2D uSunDepthBuffer;

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

// Beer-lambert law function
float beerLambertLaw(float light, float extinction, float depth)
{
	return clamp(1.0 - (extinction / depth), 0.0, 1.0);
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
	return c.r + c.g / 255.0 + c.b / (255.0 * 255.0);
}

float getShadow(vec3 pos)
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

void main()
{
	vec4 depth = texture2D(uDepthBuffer, vTexCoord);
	vec3 wp = posFromBuffer(vTexCoord, unpackDepth(depth));
    vec3 startPos = uCameraPosition;
	
    vec3 rayVector = wp - startPos;
    float rayLength = length(rayVector);
    vec3 rayDirection = normalize(rayVector);

    float stepLength = rayLength / float(STEPS);
    vec3 stepSize = rayDirection * stepLength;
	
	// Offset starting position with dither
	startPos += stepSize * dither[int(mod(vTexCoord.x * uScreenSize.x, 4.0))][int(mod(vTexCoord.y * uScreenSize.y, 4.0))];
	
    vec3 currentPos = startPos;
	
	float theta = dot(rayDirection, uSunDirection);
	float scatter = CSPhase(theta) * reyleighPhase(theta);
	
	// Result alpha represents transmittance
    vec4 result = vec4(0.0, 0.0, 0.0, 1.0);
	vec3 sampleResult = vec3(0.0);
	vec3 sampleLighting = vec3(0.0);
	float extinction = mix((1.0 - uDensity), 0.0, 0.5);
	
	// Ray march
    for (int i = 0; i < STEPS; i++)
    {	
		// Calulate sample lighting
		sampleLighting = vec3(0.0);
		sampleLighting += getShadow(currentPos) * uSunColor.rgb;
		
		// Apply lighting to sample color
		sampleResult.rgb = uEmissiveColor.rgb + (uColor.rgb * sampleLighting);
		
		result.a *= beerLambertLaw(result.a, extinction, stepLength);
		sampleResult.rgb *= scatter;
		result.rgb += sampleResult;
		
        currentPos += stepSize;
    }
	
    gl_FragColor = vec4(result.rgb * result.a * depth.a, 1.0);
}
