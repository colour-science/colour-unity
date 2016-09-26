using UnityEngine;
using System.Collections;

public class CIECAM02_UI : MonoBehaviour {
	
	public void Set_X_w(float value) {
		Material material = GetComponent<Renderer>().sharedMaterial;
		material.SetFloat("_X_w", value);
	}

	public void Set_Y_w(float value) {
		Material material = GetComponent<Renderer>().sharedMaterial;
		material.SetFloat("_Y_w", value);
	}

	public void Set_Z_w(float value) {
		Material material = GetComponent<Renderer>().sharedMaterial;
		material.SetFloat("_Z_w", value);
	}

	public void Set_L_A(float value) {
		Material material = GetComponent<Renderer>().sharedMaterial;
		material.SetFloat("_L_A", value);
	}

	public void Set_Y_b(float value) {
		Material material = GetComponent<Renderer>().sharedMaterial;
		material.SetFloat("_Y_b", value);
	}

	public void Set_Surround(int value) {
		Material material = GetComponent<Renderer>().sharedMaterial;
		material.SetInt("_Surround", value);
	}

	public void Set_X_w_v(float value) {
		Material material = GetComponent<Renderer>().sharedMaterial;
		material.SetFloat("_X_w_v", value);
	}

	public void Set_Y_w_v(float value) {
		Material material = GetComponent<Renderer>().sharedMaterial;
		material.SetFloat("_Y_w_v", value);
	}

	public void Set_Z_w_v(float value) {
		Material material = GetComponent<Renderer>().sharedMaterial;
		material.SetFloat("_Z_w_v", value);
	}

	public void Set_L_A_v(float value) {
		Material material = GetComponent<Renderer>().sharedMaterial;
		material.SetFloat("_L_A_v", value);
	}

	public void Set_Y_b_v(float value) {
		Material material = GetComponent<Renderer>().sharedMaterial;
		material.SetFloat("_Y_b_v", value);
	}

	public void Set_Surround_v(int value) {
		Material material = GetComponent<Renderer>().sharedMaterial;
		material.SetInt("_Surround_v", value);
	}
}
