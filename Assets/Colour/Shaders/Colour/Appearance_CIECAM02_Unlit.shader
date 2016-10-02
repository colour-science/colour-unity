Shader "Unlit/CIECAM02"
{
	Properties
	{
		[Header(CIECAM02)] _MainTex ("Image", 2D) = "white" {}

		// Moroney, N. (n.d.). Usage guidelines for CIECAM97s. Defaults for *sRGB* viewing conditions,
		// assuming 64 lux ambient / 80 cd/m2 CRT and D65 as whitepoint.

		// NOTE: *[HDR] Color* seems to be clamping / messing with input, using *Range* instead.
		[Header(Reference Viewing Conditions)]  _X_w ("XYZ_w (X))", Range (50, 150)) = 95.046505745082385
		_Y_w ("XYZ_w (Y)", Range (50, 150)) = 100.000000000000000
		_Z_w ("XYZ_w (Z)", Range (50, 150)) = 108.897024100442707
		_XYZ_w_scale ("XYZ_w Scale", Range (0.1, 100)) = 1.0
		_L_A ("L_A", Range (0.01, 1000)) = 4.0
		_Y_b ("Y_b", Range (0.01, 100)) = 20.0
		[KeywordEnum(Average, Dim, Dark)] _surround("Surround", Int) = 0
		[Toggle] _discount_illuminant("Discount Illuminant", Int) = 0

		// NOTE: *[HDR] Color* seems to be clamping / messing with input, using *Range* instead.
		[Header(Test Viewing Conditions)] [HDR] _X_w_v ("XYZ_w (X)", Range (50, 150)) = 95.046505745082385
		_Y_w_v ("XYZ_w (Y)", Range (50, 150)) = 100.000000000000000
		_Z_w_v ("XYZ_w (Z)", Range (50, 150)) = 108.897024100442707
		_XYZ_w_v_scale ("XYZ_w Scale", Range (0.1, 100)) = 1.0
		_L_A_v ("L_A", Range (0.01, 1000)) = 4.0
		_Y_b_v ("Y_b", Range (0.01, 100)) = 20.0
		[KeywordEnum(Average, Dim, Dark)] _surround_v("Surround", Int) = 0
		[Toggle] _discount_illuminant_v("Discount Illuminant", Int) = 0
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

			sampler2D _MainTex;
			float4 _MainTex_ST;

			float _X_w;
			float _Y_w;
			float _Z_w;
			float _XYZ_w_scale;
			float _L_A;
			float _Y_b;
			float _surround;
			int _discount_illuminant;

			float _X_w_v;
			float _Y_w_v;
			float _Z_w_v;
			float _XYZ_w_v_scale;
			float _L_A_v;
			float _Y_b_v;
			float _surround_v;
			int _discount_illuminant_v;

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
				float4 RGBA = tex2D(_MainTex, i.uv);
				// Assuming an RGBM input.
				float3 XYZ = mul(sRGB_TO_XYZ_MATRIX, RGBA.rgb * eotf_sRGB(RGBA.a * 5.0)) * 100.0;

				// CIECAM02 forward model.
				CIECAM02_InductionFactors I_F;
				if (_surround == 0)
					I_F = CIECAM02_VIEWING_CONDITIONS_AVERAGE;
				if (_surround == 1)
					I_F = CIECAM02_VIEWING_CONDITIONS_DIM;
				if (_surround == 2)
					I_F = CIECAM02_VIEWING_CONDITIONS_DARK;

				CIECAM02_Specification specification = XYZ_to_CIECAM02(
					XYZ, float3(_X_w, _Y_w, _Z_w) * _XYZ_w_scale, _L_A, _Y_b, I_F, 
					bool(_discount_illuminant));

				// CIECAM02 reverse model.
				CIECAM02_InductionFactors I_F_v;
				if (_surround_v == 0)
					I_F_v = CIECAM02_VIEWING_CONDITIONS_AVERAGE;
				if (_surround_v == 1)
					I_F_v = CIECAM02_VIEWING_CONDITIONS_DIM;
				if (_surround_v == 2)
					I_F_v = CIECAM02_VIEWING_CONDITIONS_DARK;

				float3 XYZ_v = CIECAM02_to_XYZ(
					specification.J, specification.C, specification.h, 
					float3(_X_w_v, _Y_w_v, _Z_w_v) * _XYZ_w_v_scale, _L_A_v, _Y_b_v, I_F_v, 
					bool(_discount_illuminant_v));

				float3 RGB_v = mul(XYZ_TO_sRGB_MATRIX, XYZ_v / 100.0);

				return float4(RGB_v, 1.0);
			}
			ENDCG
		}
	}
}
