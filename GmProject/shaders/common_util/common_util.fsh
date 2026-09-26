#pragma shady: skip_compilation
void main() {}

#region TBN_LIB
#pragma shady: macro_begin TBN_LIB

mat3 getTBN(vec3 normal, vec3 tangent)
{
	normal = normalize(normal);
	tangent = normalize(tangent - dot(tangent, normal) * normal);
	return mat3(tangent, cross(tangent, normal), normal);
}

#pragma shady: macro_end
#endregion

#region DEPTH_BUFFER_LIB
#pragma shady: macro_begin DEPTH_BUFFER_LIB

float readDepth(vec2 coord)
{
	return texture2D(uDepthBuffer, coord).r;
}

bool isDepthBackground(float depth)
{
	return depth >= 1.0;
}

#pragma shady: macro_end
#endregion

#region DEPTH_RECONSTRUCT_LIB
#pragma shady: macro_begin DEPTH_RECONSTRUCT_LIB

uniform float uNear;
uniform float uFar;
uniform mat4 uProjMatrixInv;

// Transform linear depth to exponential depth
float transformDepth(float depth)
{
	return (uFar - (uNear * uFar) / (depth * (uFar - uNear) + uNear)) / (uFar - uNear);
}

// Reconstruct a position from a screen space coordinate and linear depth
vec3 posFromBuffer(vec2 coord, float depth)
{
	vec4 pos = uProjMatrixInv * vec4(coord.x * 2.0 - 1.0, 1.0 - coord.y * 2.0, transformDepth(depth), 1.0);
	return pos.xyz / pos.w;
}

#pragma shady: macro_end
#endregion

#region NEIGHBOR_FILTER_LIB
#pragma shady: macro_begin NEIGHBOR_FILTER_LIB

// Assuming uNormalBuffer is defined in the shader, but we take centerNormal, should be fine.
float getNeighborSurfaceWeight(vec2 sampleCoord, vec3 centerPos, vec3 centerNormal)
{
	if (sampleCoord.x < 0.0 || sampleCoord.x > 1.0 || sampleCoord.y < 0.0 || sampleCoord.y > 1.0)
		return 0.0;
	
	float sampleDepth = readDepth(sampleCoord);
	if (isDepthBackground(sampleDepth))
		return 0.0;
	
	vec3 sampleNormal = unpackNormal(texture2D(uNormalBuffer, sampleCoord));
	vec3 samplePos = posFromBuffer(sampleCoord, sampleDepth);
	float normalWeight = smoothstep(0.8, 0.98, max(dot(centerNormal, sampleNormal), 0.0));
	float planeDistance = abs(dot(samplePos - centerPos, centerNormal));
	float depthTolerance = max(0.5, abs(centerPos.z) * 0.005);
	float depthWeight = 1.0 - smoothstep(depthTolerance * 0.25, depthTolerance, planeDistance);
	return normalWeight * depthWeight;
}

#pragma shady: macro_end
#endregion

#region BLUE_NOISE_DIRECTION_LIB
#pragma shady: macro_begin BLUE_NOISE_DIRECTION_LIB

#pragma shady: inline(common_constants.MATH)

// Creates a cosine-weighted hemisphere from noise
vec3 unpackBlueNoiseDirection(vec4 c)
{
	float phi = c.r * TWO_PI;
	float rad = sqrt(c.g);
	return vec3(rad * cos(phi), rad * sin(phi), sqrt(1.0 - c.g));
}

#pragma shady: macro_end
#endregion

#region PACK_VALUE_LIB
#pragma shady: macro_begin PACK_VALUE_LIB

vec3 packValue(float f)
{
	return vec3(floor(f * 255.0) / 255.0, fract(f * 255.0), fract(f * 255.0 * 255.0));
}

#pragma shady: macro_end
#endregion

#region UNPACK_VALUE_LIB
#pragma shady: macro_begin UNPACK_VALUE_LIB

float unpackValue(vec4 c)
{
	return c.r + c.g / 255.0 + c.b / (255.0 * 255.0);
}

#pragma shady: macro_end
#endregion

#region NORMAL_BUFFER_LIB
#pragma shady: macro_begin NORMAL_BUFFER_LIB

#define NORMAL_BUFFER_SCALE 8.0

vec4 packNormal(vec3 n)
{
	return vec4(((n + vec3(1.0)) * 0.5) * NORMAL_BUFFER_SCALE, 1.0);
}

vec3 unpackNormal(vec4 c)
{
	return (c.rgb / NORMAL_BUFFER_SCALE) * 2.0 - 1.0;
}

#pragma shady: macro_end
#endregion

#region SAMPLING_LIB
#pragma shady: macro_begin SAMPLING_LIB

// GGX importance sampling (https://learnopengl.com/PBR/IBL/Specular-IBL)
float radicalInverseBase2(int n)
{
    float invBase = 0.5;
    float result = 0.0;

    for (int i = 0; i < 16; i++)
    {
        if (n > 0)
        {
            float bit = mod(float(n), 2.0);
            result += bit * invBase;
            invBase *= 0.5;
            n = int(float(n) / 2.0);
        }
    }

    return result;
}

vec2 hammersley(int i, int sampleCount)
{
    return vec2(float(i) / float(sampleCount), radicalInverseBase2(i));
}

#pragma shady: macro_end
#endregion

#region MATH_FUNC_LIB
#pragma shady: macro_begin MATH_FUNC_LIB

float percent(float xx, float start, float end)
{
	return clamp((xx - start) / (end - start), 0.0, 1.0);
}

#pragma shady: macro_end
#endregion
