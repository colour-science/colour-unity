using System;
using UnityEngine;

namespace UnityStandardAssets.ImageEffects
{
	[ExecuteInEditMode]
	[AddComponentMenu("Image Effects/Function Plotter")]
	public class Function_Plotter : ImageEffectBase {
		[Range(1.0f, 50.0f)]
		public float    range;

		// Called by camera to apply image effect
		void OnRenderImage (RenderTexture source, RenderTexture destination) {
			material.SetFloat("_range", range);
			Graphics.Blit (source, destination, material);
		}
	}
}
