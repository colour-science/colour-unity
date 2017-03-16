using System;
using UnityEngine;

namespace UnityStandardAssets.ImageEffects
{
	[ExecuteInEditMode]
	[AddComponentMenu("Image Effects/Function Plotter")]
	public class FunctionPlotter : ImageEffectBase 
	{

		public enum graphs {linearLinear, linearLog, logLinear, logLog};
		public graphs graph;

		[Range(1, 10)]
		public int logBase;
	
		public float minX;
		public float maxX;
		public float minY;
		public float maxY;

		[Range(0.0f, 1.0f)]
		public float gridOpacity;

		// Called by camera to apply image effect
		void OnRenderImage (RenderTexture source, RenderTexture destination) 
		{
			material.SetInt("_graph", (int)graph);
			material.SetInt("_log_base", logBase);
			material.SetFloat("_min_x", minX);
			material.SetFloat("_max_x", maxX);
			material.SetFloat("_min_y", minY);
			material.SetFloat("_max_y", maxY);
			material.SetFloat("_grid_opacity", gridOpacity);
			Graphics.Blit (source, destination, material);
		}
	}
}
