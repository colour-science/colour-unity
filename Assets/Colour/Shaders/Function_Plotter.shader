Shader "Camera/Function Plotter" {
	Properties {
		_MainTex ("", 2D) = "black" {}
		[Header(Grid)] _range ("Range", Range (1, 50)) = 10
	}
	
	CGINCLUDE
	
	#include "UnityCG.cginc"

	struct v2f {
		float4 pos : SV_POSITION;
		float2 uv : TEXCOORD0;
	};

	sampler2D _MainTex;
	float4 _MainTex_ST;

	float _range;

	v2f vert( appdata_img v ) 
	{
		v2f o;
		o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
		o.uv = v.texcoord.xy;
		return o;
	}

	float grid(
		float2 uv, 
		float axis_thickness, 
		float grid_thickness, 
		float axis_luminance, 
		float grid_luminance) 
	{
		float width = 0.1;
		float grid_c;
		grid_c = step(abs(uv.x), axis_thickness) * axis_luminance;
		grid_c = max(step(abs(uv.y), axis_thickness) * axis_luminance, grid_c);
		grid_c = max(step(frac(uv.x + grid_thickness / 2.0), grid_thickness) * grid_luminance, grid_c);
		grid_c = max(step(frac(uv.y + grid_thickness / 2.0), grid_thickness) * grid_luminance, grid_c);

		return grid_c;
	}

	float FUNCTION(float x) 
	{
			  return sin(x*x*x)*sin(x);
	//  return sin(x*x*x)*sin(x) + 0.1*sin(x*x);
	//	return sin(x);
	}
	 
	//note: does one sample per x, thresholds on distance in y
	float discreteEval( float2 uv ) {
	  const float threshold = 0.005;
	  float x = uv.x;
	  float fx = FUNCTION(x);
	  float dist = abs( uv.y - fx );
	  float hit = step( dist, threshold );
	  return hit;
	}

	float function_multisample(float2 uv, float thickness, float gain, float exponent)
	{
		// https://www.shadertoy.com/view/4sB3zz
		float aspect_ratio = _ScreenParams.x / _ScreenParams.y;

		const int samples = 255;
		const float samples_f = float(samples);
		float2 max_distance = float2(thickness / 10.0, thickness / 10.0) * float2(aspect_ratio, 1.0);
		float2 half_max_distance = float2(thickness, thickness) * max_distance;
		float step_size = max_distance.x / samples_f;
		float initial_offset_x = -0.5 * samples_f * step_size;
		uv.x += initial_offset_x;
		float accumulate = 0.0;
		for(int i=0; i<samples; ++i)
		{
			float x = uv.x + step_size * float(i);
			float y = uv.y;
			float f_x = FUNCTION(x);
			accumulate += step(abs(y - f_x), half_max_distance.y);
		}
		return gain * pow(accumulate / samples_f, exponent);
	}

	float4 function_plotter(v2f i) : SV_Target
	{
		float4 RGBA = tex2D(_MainTex, UnityStereoScreenSpaceUVAdjust(i.uv, _MainTex_ST));

		float aspect_ratio = _ScreenParams.x / _ScreenParams.y;
		float _range_d = _range / 2.0;
		float2 uv = i.uv * float2(_range, _range / aspect_ratio) - float2(_range_d, _range_d / aspect_ratio);

		float grid_c = grid(
			uv, 
			10.0 / _ScreenParams.x * _range_d, 
			5.0 / _ScreenParams.x * _range_d, 
			1.0, 
			0.5);
		float4 function_c = float4(function_multisample(uv * float2(sin(_Time.g), 1.0), 0.25, 2.0, 0.8), 0.0, 0.0, 1.0);

		float4 RGB_o = float4(RGBA.r + grid_c + function_c.r, RGBA.g + grid_c, RGBA.b + grid_c, RGBA.a);

		return RGB_o;

	}
	ENDCG 
	
Subshader {
 Pass {
	  ZTest Always Cull Off ZWrite Off

      CGPROGRAM
      #pragma vertex vert
      #pragma fragment function_plotter
      ENDCG
  }
}

Fallback off
	
} // shader
