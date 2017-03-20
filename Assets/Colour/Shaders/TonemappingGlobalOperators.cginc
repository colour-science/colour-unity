#include "ModelsRGB.cginc"

float3 tonemapping_operator_simple(float3 RGB) 
{
	return RGB / (RGB + 1.0);
}

float3 tonemapping_operator_simple_max(float3 RGB) 
{
	float peak = max(max(RGB.r, RGB.g), RGB.b);
	float3 ratio = RGB / peak;

	peak = peak / (peak + 1.0);

	return ratio * peak;
}

float3 tonemapping_operator_filmic(float3 RGB, float a, float b, float c, float d, float e) 
{
	return (RGB * (a * RGB + b)) / (RGB * (c * RGB + d) + e);
}

float3 tonemapping_operator_pseudo_ACES_ODT_monitor_100nits_dim(float3 RGB) 
{
	// Fitting of ODT.RGBmonitor_100nits_dim(RRT), RMSE=0.00128461661677

	const float a = 278.508452016034312;
	const float b = 10.777173236228062;
	const float c = 293.604480035671997;
	const float d = 88.712248853759547;
	const float e = 80.688937129502875;

	float3 RGB_p = mul(sRGB_TO_ACES_CG_MATRIX, RGB);
	RGB_p = tonemapping_operator_filmic(RGB, a, b, c, d, e);

	return mul(ACES_CG_TO_sRGB_MATRIX, RGB_p);
}

float3 tonemapping_operator_pseudo_ACES_ODT_Rec2020_ST2084_1000nits(float3 RGB) 
{
	// Fitting of ODT.hdr_st2084.Rec2020_ST2084_1000nits(RRT), RMSE=2.64275589942

	const float a = 199.286971538934438;
	const float b = 58.742750614266164;
	const float c = 0.191004610964162;
	const float d = 1.544048545409732;
	const float e = 1.290780253036490;

	float3 RGB_p = mul(sRGB_TO_ACES_CG_MATRIX, RGB);
	RGB_p = tonemapping_operator_filmic(RGB, a, b, c, d, e);

	return mul(ACES_CG_TO_sRGB_MATRIX, RGB_p);
}
