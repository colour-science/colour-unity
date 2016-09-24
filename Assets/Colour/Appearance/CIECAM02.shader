Shader "Unlit/CIECAM02"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		[HDR] _Sample ("Sample", Color) = (0.0, 0.0, 0.0, 1.0)
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			// #pragma multi_compile_fog
			
			#include "UnityCG.cginc"
			#include "../Models/sRGB.cginc"
			#include "CIECAM02.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			float4 frag (v2f i) : SV_Target
			{
				// sample the texture
				// fixed4 col = tex2D(_MainTex, i.uv);
				float3 XYZ = {19.01, 20.00, 21.78};
				float3 XYZ_w = {95.05, 100.00, 108.88};
				float L_A = 318.31;
				float Y_b = 20.0;

				CIECAM02_Specification specification = XYZ_to_CIECAM02(
					XYZ, XYZ_w, L_A, Y_b, CIECAM02_VIEWING_CONDITIONS_AVERAGE, false); 

				// apply fog
				// UNITY_APPLY_FOG(i.fogCoord, col);
				return float4(specification.J, specification.C, specification.h, 1.0);;
			}
			ENDCG
		}
	}
}
