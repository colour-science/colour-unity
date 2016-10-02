float3 tonemapping_operator_simple(float3 RGB) {
	return RGB / (RGB + 1.0);
}

float3 tonemapping_operator_simple_luminance(float3 RGB, float s) {
		float luminance = Luminance(RGB); 
		float luminance_t = luminance / (1 + luminance);

		return pow(RGB / luminance, s) * luminance_t;
}