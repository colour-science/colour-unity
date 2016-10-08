#include "Models_RGB.cginc"

float3 tonemapping_operator_simple(float3 RGB) {
	return RGB / (RGB + 1.0);
}

float3 tonemapping_operator_simple_luminance(float3 RGB, float s) {
	float luminance = Luminance(RGB); 
	float luminance_t = luminance / (1 + luminance);

	return pow(RGB / luminance, s) * luminance_t;
}

float3 tonemapping_operator_pseudo_ACES_ODT_monitor_100nits_dim(float3 RGB) {
	// Fitting of ODT.RGBmonitor_100nits_dim(RRT), RMSE=0.00128461661677

	float a = 33.262486518812636;
	float b = 1.287129513082916;
	float c = 35.065419539489810;
	float d = 10.594971406163753;
	float e = 9.636750946518040;

	float3 RGB_p = mul(sRGB_TO_ACESCG_MATRIX, RGB);
	RGB_p = (RGB_p * (a * RGB_p + b)) / (RGB_p * (c * RGB_p + d) + e);

	return mul(ACESCG_TO_sRGB_MATRIX, RGB_p);
}

float3 tonemapping_operator_pseudo_ACES_ODT_Rec2020_ST2084_1000nits(float3 RGB) {
	// Fitting of ODT.hdr_st2084.Rec2020_ST2084_1000nits(RRT), RMSE=2.64275589942

	float a = 199.286971538934438;
	float b = 58.742750614266164;
	float c = 0.191004610964162;
	float d = 1.544048545409732;
	float e = 1.290780253036490;

	float3 RGB_p = mul(sRGB_TO_ACESCG_MATRIX, RGB);
	RGB_p = (RGB_p * (a * RGB_p + b)) / (RGB_p * (c * RGB_p + d) + e);

	return mul(ACESCG_TO_sRGB_MATRIX, RGB_p);
}