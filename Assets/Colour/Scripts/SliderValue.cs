using UnityEngine;
using UnityEngine.UI;

public class SliderValue : MonoBehaviour {
	
	public void SetText(float value) {
		value = Mathf.Round (value * 10f) / 10f;
		GetComponent<Text>().text = value.ToString();
	}
}