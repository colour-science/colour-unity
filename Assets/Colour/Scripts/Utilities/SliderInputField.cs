using UnityEngine;
using UnityEngine.UI;
using System.Collections;

public class SliderInputField : MonoBehaviour {

	private Slider slider;
	private InputField field;

	void Start() {
		slider = gameObject.GetComponent<UnityEngine.UI.Slider>();
		field = gameObject.GetComponent<UnityEngine.UI.InputField>();
	}

	public void UpdateValueFromFloat(float value) {
		if (slider) { 
			slider.value = value;
		}
		if (field) {
			field.text = value.ToString();
		}
	}

	public void UpdateValueFromString(string value) {
		if (slider) {
			slider.value = float.Parse(value);
		}

		if (field) {
			field.text = value;
		}
	}


}
