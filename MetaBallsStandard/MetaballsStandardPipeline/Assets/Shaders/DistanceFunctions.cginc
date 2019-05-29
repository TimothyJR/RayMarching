// Resource where these equations were found on Inigo Quilez's blog
// http://www.iquilezles.org/www/articles/distfunctions/distfunctions.htm
// Sphere
float signedDistanceSphere(float3 position, float radius)
{
	return length(position) - radius;
}

// Box
float signedDistanceBox(float3 position, float3 dimensions)
{
	float3 d = abs(position) - dimensions;
	return min(max(d.x, max(d.y, d.z)), 0.0) +
		length(max(d, 0.0));
}

//Torus
float signedDistanceTorus(float3 position, float2 thickness)
{
	float2 d = float2(length(position.xz) - thickness.x, position.y);
	return length(d) - thickness.y;
}

// BOOLEAN OPERATORS //

// Union
float opUnion(float d1, float d2)
{
	return min(d1, d2);
}

// Smooth Union
float opSmoothUnion(float d1, float d2, float k)
{
	float h = clamp(0.5 + 0.5 * (d2 - d1) / k, 0.0, 1.0);
	return lerp(d2, d1, h) - k * h*(1.0 - h);
}

// Subtraction
float opSubtraction(float d1, float d2)
{
	return max(-d1, d2);
}

// Smooth Subtraction
float opSmoothSubtraction(float d1, float d2, float k)
{
	float h = clamp(0.5 - 0.5 * (d2 + d1) / k, 0.0, 1.0);
	return lerp(d2, -d1, h) + k * h * (1.0 - h);
}

// Intersection
float opIntersection(float d1, float d2)
{
	return max(d1, d2);
}

// Smooth Intersection
float opSmoothIntersection(float d1, float d2, float k)
{
	float h = clamp(0.5 - 0.5 * (d2 - d1) / k, 0.0, 1.0);
	return lerp(d2, d1, h) + k * h * (1.0 - h);
}

// Mod Position Axis
float pMod1 (inout float p, float size)
{
	float halfsize = size * 0.5;
	float c = floor((p+halfsize)/size);
	p = fmod(p+halfsize,size)-halfsize;
	p = fmod(-p+halfsize,size)-halfsize;
	return c;
}