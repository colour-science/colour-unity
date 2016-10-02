using UnityEngine;
using System.Collections;

public class FitToCamera : MonoBehaviour {
	void Update () {
		transform.localScale = Vector3.one;
	
		Vector3 size = GetComponent<Renderer>().bounds.size;
		float distance = Vector3.Distance(Camera.main.transform.position, transform.position);
		float diameter = Mathf.Tan(Mathf.Deg2Rad * Camera.main.fieldOfView / 2.0f) * (2.0f * (float)distance);

		Material material = GetComponent<Renderer>().material;
		Texture image = material.GetTexture ("_MainTex");

		transform.localScale = new Vector3(diameter * (1.0f / size[0]) * 
			((float)image.width / (float)image.height), 1.0f, diameter * (1.0f / size[1]));
	}
}
