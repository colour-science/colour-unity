Shader "Camera/Function Plotter" {
	Properties {
		_MainTex ("", 2D) = "black" {}
		[Header(Grid)] _graph ("Graph", Range (0, 3)) = 0.0
		_log_base ("Log Base", Range (1, 10)) = 1.0
		 _min_x ("Min X", Range (-10000, 10000)) = 0.0
		 _max_x ("Max X", Range (-10000, 10000)) = 10.0
		 _min_y ("Min Y", Range (-10000, 10000)) = 0.0
		 _max_y ("Max Y", Range (-10000, 10000)) = 10.0
		 _ticks_x ("Ticks X", Range (1, 100)) = 10
		 _ticks_y ("Ticks Y", Range (1, 100)) = 10
		 _axis_thickness ("Axis Thickness", Range (1, 40)) = 10.0
		 _ticks_thickness ("Ticks Thickness", Range (1, 40)) = 5.0
		 _axis_opacity ("Axis Opacity", Range (0, 1)) = 0.5
		 _ticks_opacity ("Ticks Opacity", Range (0, 1)) = 0.05
		 _function_thickness ("Function Thickness", Range (1, 40)) = 0.05
		 _function_opacity ("Function Opacity", Range (0, 1)) = 1.0

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
	int _ticks_x;
	int _ticks_y;
	float _axis_thickness;
	float _ticks_thickness;
	float _axis_opacity;
	float _ticks_opacity;
	float _function_thickness;
	float _function_opacity;

	v2f vert( appdata_img v ) 
	{
		v2f o;
		o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
		o.uv = v.texcoord.xy;
		return o;
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

	float axes(
		float2 uv,
		float range_x,
		float range_y,
		int ticks_x,
		int ticks_y,
		float axis_thickness, 
		float ticks_thickness, 
		float axis_luminance, 
		float ticks_luminance) 
	{
		float range_x_h = range_x / 2.0;
		float range_y_h = range_y / 2.0;
		float ticks_x_r = range_x / float(ticks_x);
		float ticks_y_r = range_y / float(ticks_y);

		float2 one_pixel = float2(1.0, 1.0) / _ScreenParams;

		float axis_t_x = axis_thickness * one_pixel.x * range_x_h;
		float axis_t_y = axis_thickness * one_pixel.y * range_y_h;
		float axis_t_x_h = axis_t_x / 2.0;
		float axis_t_y_h = axis_t_y / 2.0;
		float ticks_t_x = ticks_thickness * one_pixel.x * range_x_h;
		float ticks_t_y = ticks_thickness * one_pixel.y * range_y_h;
		float ticks_t_x_h = ticks_t_x / 2.0;
		float ticks_t_y_h = ticks_t_y / 2.0;

		float axes_c = step(uv.x + axis_t_x_h, axis_t_x) * axis_luminance;
		axes_c = max(step(uv.y + axis_t_y_h, axis_t_y) * axis_luminance, axes_c);
		axes_c = max(step(frac((uv.x + ticks_t_x_h) / ticks_x_r), ticks_t_x / ticks_x_r) * ticks_luminance, axes_c);
		axes_c = max(step(frac((uv.y + ticks_t_y_h) / ticks_y_r), ticks_t_y / ticks_y_r) * ticks_luminance, axes_c);
			
		return axes_c;
	}

	float FUNCTION(float x) 
	{
		return x;
	}

	float function_sample(
		float2 uv,
		float range_x,
		float range_y,
		float thickness,
		float function_luminance)
	{
	  float range_xy = (range_x + range_y) / 2.0;

	  float x = uv.x;
	  float f_x = FUNCTION(x);
	  float distance_f = (1.0 - abs(uv.y - f_x));
	  // Arbitrary scaling to approximate axes visual style.
	  float function_t = linear_conversion(thickness / 2.0, 1.0, 40.0, 0.9975, 0.975);
	  float function = smoothstep((1.0 - range_xy) + (function_t * range_xy), 1.0, distance_f);
	  return clamp(thickness * function * function_luminance, 0.0, 1.0);
	}

	float4 function_plotter(v2f i) : SV_Target
	{
		float4 RGBA = tex2D(_MainTex, UnityStereoScreenSpaceUVAdjust(i.uv, _MainTex_ST));
		float2 uv_f = float2(
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

//		float2 uv_r = graph_forward(float2(
//			linear_conversion(
//				i.uv.x, 
//				_min_x,
//				_max_x,
//				graph_reverse(float2(0.0, 0.0)).x, 
//				graph_reverse(float2(1.0, 1.0)).x), 
//			linear_conversion(
//				i.uv.y, 
//				_min_y,
//				_max_y,
//				graph_reverse(float2(0.0, 0.0)).y, 
//				graph_reverse(float2(1.0, 1.0)).y)));

		float range_x = abs(_min_x) + abs(_max_x);
		float range_y = abs(_min_y) + abs(_max_y);

		float axes_c = axes(
			uv_f,
			range_x,
			range_y,
			_ticks_x,
			_ticks_y,
			_axis_thickness, 
			_ticks_thickness, 
			_axis_opacity, 
			_ticks_opacity);
				
		float4 function_c = float4(
			function_sample(
				uv_f, 
				range_x, 
				range_y, 
				_function_thickness, 
				_function_opacity), 
			0.0, 0.0, 1.0);

		float4 RGB_o = float4(RGBA.r + axes_c + function_c.r, RGBA.g + axes_c, RGBA.b + axes_c, RGBA.a);

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
