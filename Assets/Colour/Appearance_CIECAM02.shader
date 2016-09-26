Shader "Unlit/CIECAM02"
{
	Properties
	{
		[Header(CIECAM02)] _Image ("Image", 2D) = "white" {}

		// [HDR] Color seems to be clamping / messing with input.
		[Header(Reference Viewing Conditions)]  _X_w ("Reference White (X)", Range (0.1, 1000)) = 95.05
		_Y_w ("Reference White (Y)", Range (0.1, 1000)) = 100.00
		_Z_w ("Reference White (Z)", Range (0.1, 1000)) = 108.88
		_L_A ("Adapting Field Absolute Luminance", Range (0.1, 1000)) = 318.31
		_Y_b ("Background Relative Luminance", Range (0.1, 100)) = 20.0
		[KeywordEnum(Average, Dim, Dark)] _Surround("Surround", Int) = 0

		[Header(Test Viewing Conditions)] [HDR] _X_w_v ("Reference White (X)", Range (0.1, 1000)) = 95.05
		_Y_w_v ("Reference White (Y)", Range (0.1, 1000)) = 100.00
		_Z_w_v ("Reference White (Z)", Range (0.1, 1000)) = 108.88
		_L_A_v ("Adapting Field Absolute Luminance", Range (0.1, 1000)) = 318.31
		_Y_b_v ("Background Relative Luminance", Range (0.1, 100)) = 20.0
		[KeywordEnum(Average, Dim, Dark)] _Surround_v("Surround", Int) = 0

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
			#include "Models_sRGB_Colourspace.cginc"
			#include "Appearance_CIECAM02.cginc"

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

			float _X_w;
			float _Y_w;
			float _Z_w;
			float _L_A;
			float _Y_b;
			float _Surround;

			float _X_w_v;
			float _Y_w_v;
			float _Z_w_v;
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
				float3 XYZ = mul(sRGB_TO_XYZ_MATRIX, RGB.rgb) * 100.0;
				// float3 XYZ = {19.01, 20.00, 21.78};

				CIECAM02_InductionFactors I_F;
				if (_Surround == 0)
					I_F = CIECAM02_VIEWING_CONDITIONS_AVERAGE;
				if (_Surround == 1)
					I_F = CIECAM02_VIEWING_CONDITIONS_DIM;
				if (_Surround == 2)
					I_F = CIECAM02_VIEWING_CONDITIONS_DARK;

				CIECAM02_Specification specification = XYZ_to_CIECAM02(
					XYZ, float3(_X_w, _Y_w, _Z_w), _L_A, _Y_b, I_F, false); 

				// float J = 41.731091132513917;
				// float C = 0.104707757171105;
				// float h = 219.04843265827190;

				CIECAM02_InductionFactors I_F_v;
				if (_Surround_v == 0)
					I_F_v = CIECAM02_VIEWING_CONDITIONS_AVERAGE;
				if (_Surround_v == 1)
					I_F_v = CIECAM02_VIEWING_CONDITIONS_DIM;
				if (_Surround_v == 2)
					I_F_v = CIECAM02_VIEWING_CONDITIONS_DARK;

				float3 XYZ_v = CIECAM02_to_XYZ(
					specification.J, specification.C, specification.h, float3(_X_w_v, _Y_w_v, _Z_w_v), _L_A_v, _Y_b_v, 
					I_F_v, false);

				float3 RGB_v = mul(XYZ_TO_sRGB_MATRIX, XYZ_v / 100.0);

				return float4(RGB_v, 1.0);
			}
			ENDCG
		}
	}
}
