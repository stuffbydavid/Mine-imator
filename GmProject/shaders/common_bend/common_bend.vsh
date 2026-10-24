#pragma shady: skip_compilation
void main() {}

#pragma shady: macro_begin BEND_LIB

uniform vec3 uBendAngle;
uniform vec3 uBendPivot;
uniform vec3 uBendMin;
uniform vec3 uBendMax;
uniform vec3 uBendDirection;
uniform vec4 uBendSettings; // Kind: 1 block, 2 plane, 3 extruded plane; sharp axis or -1
uniform vec3 uBendWind; // Wave type, minimum Z, maximum Z

float bendEase(float weight)
{
	float t = weight < 0.5 ? weight * 2.0 : (1.0 - weight) * 2.0;
	float halfEase = t * t * t * t * t * 0.5;
	return weight < 0.5 ? halfEase : 1.0 - halfEase;
}

vec3 bendNormalize(vec3 value)
{
	float lengthSquared = dot(value, value);
	return lengthSquared > 0.0 ? value / sqrt(lengthSquared) : vec3(0.0);
}

vec3 bendRotate(vec3 value, vec3 angle)
{
	// Match matrix_build's transposed GameMaker Euler convention: Y, X, Z
	vec3 s = sin(-angle * 0.017453292519943295);
	vec3 c = cos(-angle * 0.017453292519943295);
	value = vec3(c.y * value.x + s.y * value.z, value.y, -s.y * value.x + c.y * value.z);
	value = vec3(value.x, c.x * value.y - s.x * value.z, s.x * value.y + c.x * value.z);
	return vec3(c.z * value.x - s.z * value.y, s.z * value.x + c.z * value.y, value.z);
}

void bendTransform(float encodedWeight, out vec3 angle, out vec3 scale)
{
	bool start = encodedWeight < 0.0;
	float weight = start ? -1.0 - encodedWeight : encodedWeight;
	bool sharp = uBendSettings.y >= 0.0;
	if (sharp && uBendSettings.x > 2.5 && abs(weight - 0.5) > 0.001)
		weight = floor(weight + 0.5);

	bool useLinearAngle = sharp && (uBendSettings.x > 2.5 || (uBendSettings.x < 1.5 && !start));
	float eased = useLinearAngle ? weight : bendEase(weight);
	angle = uBendAngle * vec3(eased, eased, weight);
	// The CPU helper skips the range clamp for an exactly zero component
	angle = vec3(angle.x == 0.0 ? 0.0 : clamp(angle.x, uBendMin.x, uBendMax.x),
		angle.y == 0.0 ? 0.0 : clamp(angle.y, uBendMin.y, uBendMax.y),
		angle.z == 0.0 ? 0.0 : clamp(angle.z, uBendMin.z, uBendMax.z));
	angle *= uBendDirection;

	scale = vec3(1.0);
	if (sharp && weight > 0.0 && weight < 1.0 && (uBendSettings.x < 1.5 || uBendSettings.x > 2.5 || start))
	{
		float pinchAngle = uBendSettings.y < 0.5 ? abs(uBendAngle.x) :
			(uBendSettings.y < 1.5 ? abs(uBendAngle.y) : abs(uBendAngle.z));
		if (pinchAngle > 90.0)
			pinchAngle = 180.0 - pinchAngle;
		float pinch = min(weight, 1.0 - weight) * 2.0 * clamp(pinchAngle / 90.0, 0.0, 1.0);
		pinch = pinch * pinch * pinch / 2.5;
		scale += vec3(uBendSettings.y < 0.5 ? 0.0 : pinch,
			uBendSettings.y >= 0.5 && uBendSettings.y < 1.5 ? 0.0 : pinch,
			uBendSettings.y >= 1.5 ? 0.0 : pinch);
	}
	if (uBendSettings.x > 2.5 || (uBendSettings.x < 1.5 && !start))
		scale += vec3(weight * 0.005);
}

vec3 bendPoint(vec4 restPoint)
{
	vec3 angle, scale;
	bendTransform(restPoint.w, angle, scale);
	return bendRotate(restPoint.xyz - uBendPivot, angle) * scale + uBendPivot;
}

void applyBendFull(inout vec3 position, inout vec3 normal, inout vec3 tangent, inout vec4 wave, vec4 data, vec4 pointA, vec4 pointB, vec4 pointC)
{
	if (uBendSettings.x < 0.5)
		return;
	if (max(max(abs(uBendAngle.x), abs(uBendAngle.y)), abs(uBendAngle.z)) >= 0.0001)
	{
		vec3 angle, scale;
		bendTransform(data.x, angle, scale);
		position = bendRotate(position - uBendPivot, angle) * scale + uBendPivot;
		vec3 a = bendPoint(pointA) - position;
		vec3 b = bendPoint(pointB) - position;
		if (abs(data.y) < 0.5)
		{
			bendTransform(pointC.w, angle, scale);
			normal = bendNormalize(bendRotate(pointC.xyz, angle) * scale);
		}
		else
		{
			vec3 area = cross(a, b);
			if (abs(data.y) > 1.5)
			{
				vec3 c = bendPoint(pointC) - position;
				if (abs(data.y) < 2.5)
					area = cross(c, a) + cross(a, b);
				else if (abs(data.y) < 3.5)
					area = cross(a, c) + cross(c, b);
				else
					area = cross(a, b) + cross(b, c);
			}
			normal = bendNormalize(area) * (data.y < 0.0 ? -1.0 : 1.0);
		}
		tangent = bendNormalize(a * data.z + b * data.w);
	}
	if (position.z <= uBendWind.y || position.z >= uBendWind.z)
		wave.xy = vec2(0.0);
}

void bendPrepare(float weight, out vec3 sine, out vec3 cosine, out vec3 scale)
{
	vec3 angle;
	bendTransform(weight, angle, scale);
	sine = sin(-angle * 0.017453292519943295);
	cosine = cos(-angle * 0.017453292519943295);
}

vec3 bendRotatePrepared(vec3 value, vec3 sine, vec3 cosine)
{
	value = vec3(cosine.y * value.x + sine.y * value.z, value.y, -sine.y * value.x + cosine.y * value.z);
	value = vec3(value.x, cosine.x * value.y - sine.x * value.z, sine.x * value.y + cosine.x * value.z);
	return vec3(cosine.z * value.x - sine.z * value.y, sine.z * value.x + cosine.z * value.y, value.z);
}

vec3 bendApplyPrepared(vec3 value, float selector, vec3 sine0, vec3 cosine0, vec3 scale0, vec3 sine1, vec3 cosine1, vec3 scale1)
{
	vec3 sine = selector < 0.5 ? sine0 : sine1;
	vec3 cosine = selector < 0.5 ? cosine0 : cosine1;
	vec3 scale = selector < 0.5 ? scale0 : scale1;
	return bendRotatePrepared(value, sine, cosine) * scale;
}

void applyBend(inout vec3 position, inout vec3 normal, inout vec3 tangent, inout vec4 wave, vec4 data, vec4 pointA, vec4 pointB, vec4 pointC)
{
	if (data.y < 256.0)
	{
		applyBendFull(position, normal, tangent, wave, data, pointA, pointB, pointC);
		return;
	}
	if (uBendSettings.x < 0.5)
		return;
	if (max(max(abs(uBendAngle.x), abs(uBendAngle.y)), abs(uBendAngle.z)) >= 0.0001)
	{
		// Compact records share two exact weights across the vertex and its neighbors
		float tag = data.y - 256.0;
		float normalMode = mod(tag, 16.0) - 4.0;
		float selectorA = mod(floor(tag / 16.0), 2.0);
		float selectorB = mod(floor(tag / 32.0), 2.0);
		float selectorC = mod(floor(tag / 64.0), 2.0);
		vec3 valueC = vec3(pointB.w, pointC.x, pointC.y);
		vec3 sine0, cosine0, scale0, sine1, cosine1, scale1;
		bendPrepare(data.x, sine0, cosine0, scale0);
		if (pointA.w == data.x)
		{
			sine1 = sine0;
			cosine1 = cosine0;
			scale1 = scale0;
		}
		else
			bendPrepare(pointA.w, sine1, cosine1, scale1);

		position = bendRotatePrepared(position - uBendPivot, sine0, cosine0) * scale0 + uBendPivot;
		vec3 a = bendApplyPrepared(pointA.xyz - uBendPivot, selectorA, sine0, cosine0, scale0, sine1, cosine1, scale1) + uBendPivot - position;
		vec3 b = bendApplyPrepared(pointB.xyz - uBendPivot, selectorB, sine0, cosine0, scale0, sine1, cosine1, scale1) + uBendPivot - position;
		if (abs(normalMode) < 0.5)
			normal = bendNormalize(bendApplyPrepared(valueC, selectorC, sine0, cosine0, scale0, sine1, cosine1, scale1));
		else
		{
			vec3 area = cross(a, b);
			if (abs(normalMode) > 1.5)
			{
				vec3 c = bendApplyPrepared(valueC - uBendPivot, selectorC, sine0, cosine0, scale0, sine1, cosine1, scale1) + uBendPivot - position;
				if (abs(normalMode) < 2.5)
					area = cross(c, a) + cross(a, b);
				else if (abs(normalMode) < 3.5)
					area = cross(a, c) + cross(c, b);
				else
					area = cross(a, b) + cross(b, c);
			}
			normal = bendNormalize(area) * (normalMode < 0.0 ? -1.0 : 1.0);
		}
		tangent = bendNormalize(a * data.z + b * data.w);
	}
	if (position.z <= uBendWind.y || position.z >= uBendWind.z)
		wave.xy = vec2(0.0);
}

#pragma shady: macro_end
