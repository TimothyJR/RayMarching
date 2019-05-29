// Helpful resource for metaballs by Inigo Quilez:
// https://www.shadertoy.com/view/ld2GRz
Shader "Metaballs/RayMarch"
{
Properties
{
	 _MainTex ("Texture", 2D) = "white" {}
}
SubShader
{
	// No culling or depth
	Cull Off ZWrite Off ZTest Always
	
	Pass
	{
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#pragma target 3.0
	
		#include "UnityCG.cginc"
		#include "DistanceFunctions.cginc"

		sampler2D _MainTex;
		uniform float4 _MainTex_TexelSize;
		uniform sampler2D _CameraDepthTexture;
		uniform float4x4 _CameraFrustum;
		uniform float4x4 _CameraViewMatrix;
		uniform float _MaxDistance;
		uniform float4 _Sphere;
		uniform float4 _Box;
		uniform float3 _LightDirection;
		uniform fixed4 _MainColor;
		uniform float4 _Spheres[100];
		uniform float4 _Colors[100];
		uniform int _SphereCount;

		struct appdata
		{
			float4 vertex : POSITION;
			float2 uv : TEXCOORD0;
		};
	
		struct v2f
		{
			float2 uv : TEXCOORD0;
			float4 vertex : SV_POSITION;
			float3 ray : TEXCOORD1;
		};
	
		v2f vert (appdata v)
		{
			v2f o;
			half index = v.vertex.z;
			v.vertex.z = 0;
			o.vertex = UnityObjectToClipPos(v.vertex);
			o.uv = v.uv.xy;

			if (_MainTex_TexelSize.y < 0)
			{
				o.uv.y = 1 - o.uv.y;
			}

			o.ray = _CameraFrustum[(int)index].xyz;
			o.ray /= abs(o.ray.z);
			o.ray = mul(_CameraViewMatrix, o.ray);

			return o;
		}

		// Metaballs
		float signedDistanceMetaballs(float3 position)
		{
			float m = 0.0;
			float p = 0.0;
			float dmin = 1e20;
			float h = 1.0;

			for (int i = -0; i < _SphereCount; i++)
			{
				// Calculate bounding sphere
				float db = length(_Spheres[i].xyz - position);
				if (db < _Spheres[i].w)
				{
					float x = db / _Spheres[i].w;
					p += 1.0 - x * x * x * (x * (x * 6.0 - 15.0) + 10.0);
					m += 1.0;
					h = max(h, 0.5333 * _Spheres[i].w);
				}
				else
				{
					dmin = min(dmin, db - _Spheres[i].w);
				}
			}

			float d = dmin + 0.1;

			if (m > 0.5)
			{
				float th = 0.2;
				d = h * (th - p);
			}

			return d;
		}

		float distanceField(float3 position)
		{
			float returnValue = signedDistanceMetaballs(position);

			return returnValue;
		}

		float3 getNormal(float3 position)
		{
			const float2 offset = float2(0.001, 0);
			float3 normal = float3(
				distanceField(position + offset.xyy) - distanceField(position - offset.xyy),
				distanceField(position + offset.yxy) - distanceField(position - offset.yxy),
				distanceField(position + offset.yyx) - distanceField(position - offset.yyx));

			return normalize(normal);
		}

		fixed4 rayMarching(float3 rayOrigin, float3 direction, float depth)
		{
			fixed4 result = fixed4(1, 1, 1, 1);
			const int MAX_ITERATION = 128;
			float distanceTravelled = 0;

			for (int i = 0; i < MAX_ITERATION; i++)
			{
				if (distanceTravelled > _MaxDistance || distanceTravelled >= depth)
				{
					result = fixed4(direction, 0);
					break;
				}

				float3 position = rayOrigin + direction * distanceTravelled;
				float distance = distanceField(position);

				if (distance < 0.01) // Hit something
				{
					// Shading
					float3 normal = getNormal(position);
					float light = dot(-_LightDirection, normal);


					result = fixed4(_MainColor.rgb * light, 1);
					break;
				}

				distanceTravelled += distance;
			}

			return result;
		}
	
		fixed4 frag (v2f i) : SV_Target
		{
			float depth = LinearEyeDepth(tex2D(_CameraDepthTexture, i.uv).r);
			depth *= length(i.ray);

			fixed3 col = tex2D(_MainTex, i.uv);
			float3 rayDirection = normalize(i.ray.xyz);
			float3 rayOrigin = _WorldSpaceCameraPos;

			fixed4 rayMarchResult = rayMarching(rayOrigin, rayDirection, depth);

			return fixed4(col * (1 - rayMarchResult.w) + rayMarchResult.xyz * rayMarchResult.w, 1);
		}
		ENDCG
	}
}
}
