Shader "Camera/Function Plotter" {
	Properties {
		_MainTex ("", 2D) = "black" {}
		[Header(Grid)] _graph ("Graph", Range (0, 3)) = 0.0
		_log_base ("Log Base", Range (1, 10)) = 1.0
		 _min_x ("Min X", Range (-10000, 10000)) = 0.0
		 _max_x ("Max X", Range (-10000, 10000)) = 10.0
		 _min_y ("Min Y", Range (-10000, 10000)) = 0.0
		 _max_y ("Max Y", Range (-10000, 10000)) = 10.0
		 _grid_opacity ("Grid Opacity", Range (0, 1)) = 0.8
	}
	
	CGINCLUDE
	
	#include "UnityCG.cginc"
	#include "UtilitiesCommon.cginc"

	struct v2f {
		float4 pos : SV_POSITION;
		float2 uv : TEXCOORD0;
	};

	sampler2D _MainTex;
	float4 _MainTex_ST;

	float _graph;
	float _log_base;
	float _min_x;
	float _max_x;
	float _min_y;
	float _max_y;
	float _grid_opacity;


	v2f vert( appdata_img v ) 
	{
		v2f o;
		o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
		o.uv = v.texcoord.xy;
		return o;
	}

	float linear_conversion(float x, float in_min, float in_max, float out_min, float out_max)
	{
		return (((x - in_min) / (in_max - in_min)) *
        	(out_max - out_min) + out_min);
	}


	float graph_forward(float x)
	{
		if (_log_base == 1)
			return log(x);
		else
			return log(x) / log(_log_base);
	}

	float2 graph_forward(float2 x)
	{
		if (_graph == 1) 
			return float2(x.x, graph_forward(x.y));
		if (_graph == 2) 
			return float2(graph_forward(x.x), x.y);
		if (_graph == 3) 
			return float2(graph_forward(x.x), graph_forward(x.y));
		else
			return x;
		
	}

	float graph_reverse(float x)
	{
		if (_log_base == 1)
			return exp(x);
		else
			return pow(_log_base, x);
	}

	float2 graph_reverse(float2 x)
	{
		if (_graph == 1) 
			return float2(x.x, graph_reverse(x.y));
		if (_graph == 2) 
			return float2(graph_reverse(x.x), x.y);
		if (_graph == 3) 
			return float2(graph_reverse(x.x), graph_reverse(x.y));
		else
			return x;
	}

	float grid(
		float2 uv,
		float axis_thickness, 
		float grid_thickness, 
		float axis_luminance, 
		float grid_luminance) 
	{

		float2 one_pixel = float2(1.0, 1.0) / _ScreenParams;

		float range_x = (abs(_min_x) + abs(_max_x)) / 2.0;
		float range_y = (abs(_min_y) + abs(_max_y)) / 2.0;
//		float compensate_u = graph_forward(uv.x);
//		float compensate_v = graph_forward(uv.y);

		float axis_t_x = axis_thickness * one_pixel * range_x;
		float axis_t_y = axis_thickness * one_pixel * range_y;
		float grid_t_x = grid_thickness * one_pixel * range_x ;//* compensate_u;
		float grid_t_y = grid_thickness * one_pixel * range_y ;//* compensate_v;

		float grid_c = 0.0;
		grid_c = step(uv.x, axis_t_x) * axis_luminance;
		grid_c = max(step(uv.y, axis_t_y) * axis_luminance, grid_c);
		grid_c = max(step(frac(uv.x), grid_t_x) * axis_luminance, grid_c);
		grid_c = max(step(frac(uv.y), grid_t_y) * axis_luminance, grid_c);

		return grid_c;
	}

	float FUNCTION(float x) 
	{
		return x;
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
		float2 uv = float2(
			linear_conversion(
				graph_reverse(float2(i.uv.x, 1.0)).x, 
				graph_reverse(float2(0.0, 0.0)).x, 
				graph_reverse(float2(1.0, 1.0)).x, 
				_min_x, 
				_max_x), 
			linear_conversion(
				graph_reverse(float2(1.0, i.uv.y)).y, 
				graph_reverse(float2(0.0, 0.0)).y, 
				graph_reverse(float2(1.0, 1.0)).y, 
				_min_y, 
				_max_y));

		float grid_c = grid(
			uv,
			10.0, 
			10.0, 
			1.0, 
			0.5) * _grid_opacity;

		float4 function_c = float4(function_multisample(uv, 0.25, 2.0, 0.8), 0.0, 0.0, 1.0);

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
