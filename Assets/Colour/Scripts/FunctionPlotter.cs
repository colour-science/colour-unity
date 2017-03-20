using System;
using UnityEngine;

namespace UnityStandardAssets.ImageEffects
{
	[ExecuteInEditMode]
	[AddComponentMenu("Image Effects/Function Plotter")]
	public class FunctionPlotter : ImageEffectBase 
	{

		public enum graphs {linearLinear, linearLog, logLinear, logLog};

		[Header("Graph")]
		public graphs graph;

		[Range(1, 10)]
		public int logBase;
	
		[Header("Axes (Domain - Range)")]
		public float minX;
		public float maxX;
		public float minY;
		public float maxY;

		[Header("Axes (Visual)")]
		[Range(1, 100)]
		public int ticksX;
		[Range(1, 100)]
		public int ticksY;
		[Range(1.0f, 40f)]
		public float axisThickness;
		[Range(1.0f, 40f)]
		public float ticksThickness;
		[Range(0.0f, 1.0f)]
		public float axisOpacity;
		[Range(0.0f, 1.0f)]
		public float ticksOpacity;

		[Header("Function (Visual)")]
		[Range(1.0f, 40f)]
		public float functionThickness;
		[Range(0.0f, 1.0f)]
		public float functionOpacity;

		[Header("Function (Controls)")]
		[Range(-10.0f, 10.0f)]
		public float a;
		[Range(-10.0f, 10.0f)]
		public float b;
		[Range(-10.0f, 10.0f)]
		public float c;
		[Range(-10.0f, 10.0f)]
		public float d;
		[Range(-10.0f, 10.0f)]
		public float e;

		[Header("Image (Visual)")]
		[Range(0.0f, 1.0f)]
		public float imageOpacity;

		// Called by camera to apply image effect
		void OnRenderImage (RenderTexture source, RenderTexture destination) 
		{
			material.SetInt("_graph", (int)graph);
			material.SetInt("_log_base", logBase);

			material.SetFloat("_min_x", minX);
			material.SetFloat("_max_x", maxX);
			material.SetFloat("_min_y", minY);
			material.SetFloat("_max_y", maxY);

			material.SetInt("_ticks_x", ticksX);
			material.SetInt("_ticks_y", ticksY);
			material.SetFloat("_axis_thickness", axisThickness);
			material.SetFloat("_ticks_thickness", ticksThickness);
			material.SetFloat("_axis_opacity", axisOpacity);
			material.SetFloat("_ticks_opacity", ticksOpacity);

			material.SetFloat("_function_thickness", functionThickness);
			material.SetFloat("_function_opacity", functionOpacity);

			material.SetFloat("_a", a);
			material.SetFloat("_b", b);
			material.SetFloat("_c", c);
			material.SetFloat("_d", d);
			material.SetFloat("_e", e);

			material.SetFloat("_image_opacity", imageOpacity);

			Graphics.Blit (source, destination, material);
		}
	}
}
