using System;
using UnityEngine;

namespace UnityStandardAssets.ImageEffects
{
	#if UNITY_5_4_OR_NEWER
	[ImageEffectAllowedInSceneView]
	#endif
	[ExecuteInEditMode]
	[RequireComponent(typeof (Camera))]
	[AddComponentMenu("Image Effects/Color Adjustments/CIECAM02 Tonemapper")]
	public class CIECAM02Tonemapper : PostEffectsBase
	{
	
		public Shader shader = null;
		public Material material = null;

		public override bool CheckResources()
		{
			CheckSupport(false, true);

			material = CheckShaderAndCreateMaterial(shader, material);

			if (!isSupported)
				ReportAutoDisable();
			return isSupported;
		}
			

		private void OnDisable()
		{
			if (material)
			{
				DestroyImmediate(material);
				material = null;
			}
		}

		[ImageEffectTransformsToLDR]
		private void OnRenderImage(RenderTexture source, RenderTexture destination)
		{
			if (CheckResources() == false)
			{
				Graphics.Blit(source, destination);
				return;
			}

			Graphics.Blit(source, destination, material, 0);
			return;
		}
	}
}
