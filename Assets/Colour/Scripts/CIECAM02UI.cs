using UnityEngine;
using UnityEngine.UI;
using System.Collections;
using UnityStandardAssets.ImageEffects;

public class CIECAM02UI : MonoBehaviour {

	//	for name, illuminant in sorted(colour.ILLUMINANTS_RELATIVE_SPDS.items()):
	//		XYZ = colour.spectral_to_XYZ(illuminant)
	//			XYZ /= XYZ[1]
	//
	//			print(name, XYZ * 100)
	private Vector3[] ILLUMINANTS_CIE_1931_2_DEGREE_STANDARD_OBSERVER = new [] {
		new Vector3(109.849538150881216f, 100.000000000000000f, 35.585111923478621f), // A
		new Vector3(99.087202067314152f, 100.000000000000000f, 85.312962145590404f), // B
		new Vector3(98.073307155429347f, 100.000000000000000f, 118.232536627931253f), // C
		new Vector3(96.421502084547555f, 100.000000000000000f, 82.520985375992566f), // D50
		new Vector3(95.681426099564220f, 100.000000000000000f, 92.147962290032964f), // D55
		new Vector3(95.294997332277291f, 100.000000000000000f, 101.014391334369861f), // D60
		new Vector3(95.046505745082385f, 100.000000000000000f, 108.897024100442707f), // D65
		new Vector3(94.972113762765247f, 100.000000000000000f, 122.636685419611922f), // D75
		new Vector3(100.007817123511899f, 100.000000000000000f, 100.034116792412121f), // E
		new Vector3(92.868465011895594f, 100.000000000000000f, 103.779175860702267f), // F1
		new Vector3(99.186352232104866f, 100.000000000000000f, 67.396642595906826f), // F10
		new Vector3(103.799511305231277f, 100.000000000000000f, 49.934562835111066f), // F11
		new Vector3(109.201789599129867f, 100.000000000000000f, 38.883008781504842f), // F12
		new Vector3(90.902773955559979f, 100.000000000000000f, 98.822853596156691f), // F2
		new Vector3(97.342998428219460f, 100.000000000000000f, 60.263133140897317f), // F3
		new Vector3(95.042910379275526f, 100.000000000000000f, 108.755100837555460f), // F4
		new Vector3(96.428049077366168f, 100.000000000000000f, 82.424058155658315f), // F5
		new Vector3(100.380151065504947f, 100.000000000000000f, 67.946175244894121f), // F6
		new Vector3(96.385300268362172f, 100.000000000000000f, 82.357429709808471f), // F7
		new Vector3(100.961462998902533f, 100.000000000000000f, 64.352789474327935f), // F8
		new Vector3(108.117286947434792f, 100.000000000000000f, 39.278619333875362f), // F9
		new Vector3(109.268024755194261f, 100.000000000000000f, 38.688833552235195f), // FL3.1
		new Vector3(101.987737110923533f, 100.000000000000000f, 65.856581570389167f), // FL3.10
		new Vector3(91.690051369716784f, 100.000000000000000f, 99.130565992750192f), // FL3.11
		new Vector3(109.543586891396245f, 100.000000000000000f, 37.785063683967948f), // FL3.12
		new Vector3(102.108942976638374f, 100.000000000000000f, 70.256710182921097f), // FL3.13
		new Vector3(96.890460954473042f, 100.000000000000000f, 80.890035628396532f), // FL3.14
		new Vector3(108.379073050999438f, 100.000000000000000f, 38.822957666511513f), // FL3.15
		new Vector3(99.686744199286963f, 100.000000000000000f, 61.290104379236169f), // FL3.2
		new Vector3(97.429684691340611f, 100.000000000000000f, 81.055778516353186f), // FL3.3
		new Vector3(97.065155755808092f, 100.000000000000000f, 83.872768392911055f), // FL3.4
		new Vector3(94.507820097352308f, 100.000000000000000f, 96.725642993117333f), // FL3.5
		new Vector3(108.424950824036628f, 100.000000000000000f, 39.305193050462876f), // FL3.6
		new Vector3(102.848672164390194f, 100.000000000000000f, 65.649936132023271f), // FL3.7
		new Vector3(95.507872788826432f, 100.000000000000000f, 81.550450355281967f), // FL3.8
		new Vector3(95.112037985200288f, 100.000000000000000f, 109.091895185021485f), // FL3.9
		new Vector3(128.448596304793540f, 100.000000000000000f, 12.543527278927098f), // HP1
		new Vector3(114.898193380482240f, 100.000000000000000f, 25.580194713734816f), // HP2
		new Vector3(105.574166892301776f, 100.000000000000000f, 39.816207398446231f), // HP3
		new Vector3(100.381607243405028f, 100.000000000000000f, 62.971511921253956f), // HP4
		new Vector3(101.679116009809363f, 100.000000000000000f, 67.610286897183414f), // HP5
	};
		
	void Start () {
		SetDefaults ();
	}

	void Update () {
	
	}

	public void SetDefaults () {
		GameObject.Find("Tonemapper Dropdown").GetComponent<Dropdown>().value = 0;
		GameObject.Find("Exposure Slider").GetComponent<Slider>().value = 0.0f;
		GameObject.Find("Exposure InputField").GetComponent<InputField>().text = "0.0";
	
		// Moroney, N. (n.d.). Usage guidelines for CIECAM97s. Defaults for *sRGB* viewing conditions,
		// assuming 64 lux ambient / 80 cd/m2 CRT and D65 as whitepoint.
		GameObject.Find("Illuminant Dropdown").GetComponent<Dropdown>().value = 6;
		GameObject.Find("XYZ_w_Scale Slider").GetComponent<Slider>().value = 1.0f;
		GameObject.Find("XYZ_w_Scale InputField").GetComponent<InputField>().text = "1.0";
		GameObject.Find("L_A Slider").GetComponent<Slider>().value = 4.0f;
		GameObject.Find("L_A InputField").GetComponent<InputField>().text = "4.0";
		GameObject.Find("Y_b Slider").GetComponent<Slider>().value = 20.0f;
		GameObject.Find("Y_b InputField").GetComponent<InputField>().text = "20.0";
		GameObject.Find("Surround Dropdown").GetComponent<Dropdown>().value = 0;
		GameObject.Find("DiscountIlluminant Toggle").GetComponent<Toggle>().isOn = true;

		GameObject.Find("Illuminant_v Dropdown").GetComponent<Dropdown>().value = 6;
		GameObject.Find("XYZ_w_v_Scale Slider").GetComponent<Slider>().value = 1.0f;
		GameObject.Find("XYZ_w_v_Scale InputField").GetComponent<InputField>().text = "1.0";
		GameObject.Find("L_A_v Slider").GetComponent<Slider>().value = 4.0f;
		GameObject.Find("L_A_v InputField").GetComponent<InputField>().text = "4.0";
		GameObject.Find("Y_b_v Slider").GetComponent<Slider>().value = 20.0f;
		GameObject.Find("Y_b_v InputField").GetComponent<InputField>().text = "20.0";
		GameObject.Find("Surround_v Dropdown").GetComponent<Dropdown>().value = 0;
		GameObject.Find("DiscountIlluminant_v Toggle").GetComponent<Toggle>().isOn = true;
	}

	private Material _GetCIECAM02Material() {
		if (Camera.main.GetComponent<CIECAM02Tonemapper>() != null)
			return Camera.main.GetComponent<CIECAM02Tonemapper>().material;
		else
			return null;
	}

	public void Set_tonemapper(int value) {
		Material material = _GetCIECAM02Material();
		if (material == null)
			return;

		material.SetFloat("_tonemapper", value);
	}

	public void Set_exposure(float value) {
		Material material = _GetCIECAM02Material();
		if (material == null)
			return;

		material.SetFloat("_exposure", value);
	}

	public void SetIlluminant(int value) {
		Material material = _GetCIECAM02Material();
		if (material == null)
			return;
		
		Vector3 XYZ = ILLUMINANTS_CIE_1931_2_DEGREE_STANDARD_OBSERVER [value];
		material.SetFloat("_X_w", XYZ[0]);
		material.SetFloat("_Y_w", XYZ[1]);
		material.SetFloat("_Z_w", XYZ[2]);
	}

	public void Set_XYZ_w_scale(float value) {
		Material material = _GetCIECAM02Material();
		if (material == null)
			return;

		material.SetFloat("_XYZ_w_scale", value);
	}

	public void Set_L_A(float value) {
		Material material = _GetCIECAM02Material();
		if (material == null)
			return;

		material.SetFloat("_L_A", value);
	}

	public void Set_Y_b(float value) {
		Material material = _GetCIECAM02Material();
		if (material == null)
			return;

		material.SetFloat("_Y_b", value);
	}

	public void Set_surround(int value) {
		Material material = _GetCIECAM02Material();
		if (material == null)
			return;

		material.SetInt("_surround", value);
	}

	public void Set_discount_illuminant(bool value) {
		Material material = _GetCIECAM02Material();
		if (material == null)
			return;

		material.SetInt("_discount_illuminant", value ? 1 : 0);
	}

	public void SetIlluminant_v(int value) {
		Material material = _GetCIECAM02Material();
		if (material == null)
			return;

		Vector3 XYZ = ILLUMINANTS_CIE_1931_2_DEGREE_STANDARD_OBSERVER [value];
		material.SetFloat("_X_w_v", XYZ[0]);
		material.SetFloat("_Y_w_v", XYZ[1]);
		material.SetFloat("_Z_w_v", XYZ[2]);
	}

	public void Set_XYZ_w_v_scale(float value) {
		Material material = _GetCIECAM02Material();
		if (material == null)
			return;

		material.SetFloat("_XYZ_w_v_scale", value);
	}

	public void Set_L_A_v(float value) {
		Material material = _GetCIECAM02Material();
		if (material == null)
			return;

		material.SetFloat("_L_A_v", value);
	}

	public void Set_Y_b_v(float value) {
		Material material = _GetCIECAM02Material();
		if (material == null)
			return;

		material.SetFloat("_Y_b_v", value);
	}

	public void Set_surround_v(int value) {
		Material material = _GetCIECAM02Material();
		if (material == null)
			return;

		material.SetInt("_surround_v", value);
	}

	public void Set_discount_illuminant_v(bool value) {
		Material material = _GetCIECAM02Material();
		if (material == null)
			return;

		material.SetInt("_discount_illuminant_v", value ? 1 : 0);
	}
}
