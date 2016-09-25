Shader "Unlit/CIECAM02"
{
	Properties
	{
		[Header(CIECAM02)] _Image ("Image", 2D) = "white" {}

		[Header(Reference Viewing Conditions)] [HDR] _XYZ_w ("Reference White (XYZ)", Color) = (95.05, 100.00, 108.88)
		_L_A ("Adapting Field Luminance", Range (0.1, 1000)) = 318.31
		_Y_b ("Background Relative Luminance", Range (0.1, 100)) = 20.0
		[KeywordEnum(Average, Dim, Dark)] _Surround("Surround", Float) = 0

		[Header(Test Viewing Conditions)] [HDR] _XYZ_w_v ("Reference White (XYZ)", Color) = (95.05, 100.00, 108.88)
		_L_A_v ("Adapting Field Luminance", Range (0.1, 1000)) = 318.31
		_Y_b_v ("Background Relative Luminance", Range (0.1, 100)) = 20.0
		[KeywordEnum(Average, Dim, Dark)] _Surround_v("Surround", Float) = 0

		[Header(Miscellaneous)][HDR] _Sampler ("Sampler", Color) = (0.0, 0.0, 0.0, 1.0)
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

			sampler2D _Image;
			float4 _Image_ST;

			float3 _XYZ_w;
			float _L_A;
			float _Y_b;
			float _Surround;

			float3 _XYZ_w_v;
			float _L_A_v;
			float _Y_b_v;
			float _Surround_v;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _Image);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			float4 frag (v2f i) : SV_Target
			{
				fixed4 RGB = tex2D(_Image, i.uv);
				float3 XYZ = mul(sRGB_TO_XYZ_MATRIX, RGB);
				// float3 XYZ = {19.01, 20.00, 21.78};

				CIECAM02_Specification specification = XYZ_to_CIECAM02(
					XYZ, _XYZ_w, _L_A, _Y_b, CIECAM02_VIEWING_CONDITIONS[int(_Surround)], false); 

				float3 XYZ_v = CIECAM02_to_XYZ(
					specification.J, specification.C, specification.h, _XYZ_w_v, _L_A_v, _Y_b_v, 
					CIECAM02_VIEWING_CONDITIONS[int(_Surround_v)], false);

				float3 RGB_v = mul(XYZ_TO_sRGB_MATRIX, XYZ_v);

				return float4(RGB_v, 1.0);
			}
			ENDCG
		}
	}
}
