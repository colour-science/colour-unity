#include "../Adaptation/CAT.cginc"
#include "../Utilities/Common.cginc"

struct CIECAM02_InductionFactors
{
    float F;
    float c;
    float N_c;
};

static const CIECAM02_InductionFactors CIECAM02_VIEWING_CONDITIONS_AVERAGE = {
    1, 0.69, 1
};

static const CIECAM02_InductionFactors CIECAM02_VIEWING_CONDITIONS_DIM = {
    0.9, 0.59, 0.95
};

static const CIECAM02_InductionFactors CIECAM02_VIEWING_CONDITIONS_DARK = {
    0.8, 0.525, 0.8
};

static const CIECAM02_InductionFactors CIECAM02_VIEWING_CONDITIONS[3] = {
	CIECAM02_VIEWING_CONDITIONS_AVERAGE, 
	CIECAM02_VIEWING_CONDITIONS_DIM, 
	CIECAM02_VIEWING_CONDITIONS_DARK};

struct CIECAM02_Specification
{
	float J;
	float C;
	float h;
	float s;
	float Q;
	float M;
	float H;
	float HC;
};

// Hunt colour appearance model *CIE XYZ* tristimulus values to
// *Hunt-Pointer-Estevez* :math:`\\rho\gamma\\beta` colourspace matrix.
static const float3x3 XYZ_TO_HPE_MATRIX = {
	0.38971, 0.68898, -0.07868,
    -0.22981, 1.18340, 0.04641,
    0.00000, 0.00000, 1.00000
};

static const float3x3 HPE_TO_XYZ_MATRIX = {
	1.910196834052035, -1.112123892787875, 0.201907956767499,
    0.370950088248689, 0.629054257392613, -0.000008055142184,
    0.000000000000000, 0.000000000000000, 1.000000000000000
};

float luminance_level_adaptation_factor(float L_A) {

	float k = 1.0 / (5.0 * L_A + 1.0);
	float k4 = pow(k, 4.0);

	float F_L = (0.2 * k4 * (5.0 * L_A) + 0.1 * pow((1.0 - k4), 2.0) * 
		pow((5.0 * L_A), (1.0 / 3.0)));

	return F_L;
}

float2 chromatic_induction_factors(float n) {
	float N_bbcb = 0.725 * pow((1.0 / n), 0.2);

	return N_bbcb;
}

float base_exponential_non_linearity(float n) {
    float z = 1.48 + sqrt(n);

	return z;
}

float4 viewing_condition_dependent_parameters(float Y_b, float Y_w, float L_A) {

    float n = Y_b / Y_w;
    float F_L = luminance_level_adaptation_factor(L_A);
    // We deviate from reference implementation to fit return data in a float4.
    float2 N_bbcb = chromatic_induction_factors(n);
    float z = base_exponential_non_linearity(n);

    return float4(n, F_L, N_bbcb.r, z);
}

float degree_of_adaptation(float F, float L_A) {
    float D = F * (1.0 - (1.0 / 3.6) * exp((-L_A - 42.0) / 92.0));

    return D;
}

float3 full_chromatic_adaptation_forward(float3 RGB, float3 RGB_w, float Y_w, float D) {
    float3 RGB_c = ((Y_w * D / RGB_w) + 1.0 - D) * RGB;

    return RGB_c;
}

float3 full_chromatic_adaptation_reverse(float3 RGB, float3 RGB_w, float Y_w, float D) {
    float3 RGB_c = ((Y_w * D / RGB_w) + 1.0 - D) * RGB;

    return RGB_c;
}

float3 RGB_to_rgb(float3 RGB) {
	// TODO: Check operations order correctness.
	return mul(mul(XYZ_TO_HPE_MATRIX, CAT02_INVERSE_CAT), RGB);
}

float3 rgb_to_RGB(float3 rgb) {
	// TODO: Check operations order correctness.
	return mul(mul(CAT02_CAT, HPE_TO_XYZ_MATRIX), rgb);
}

float3 post_adaptation_non_linear_response_compression_forward(float3 RGB, float F_L) {
	float3 RGB_c = (((400.0 * pow((F_L * RGB / 100.0), 0.42)) /
    	(27.13 + pow((F_L * RGB / 100.0), 0.42)))) + 0.1;

    return RGB_c;
}

float3 post_adaptation_non_linear_response_compression_reverse(float3 RGB, float F_L) {
	float3 RGB_p = (sign(RGB - 0.1) * (100.0 / F_L) * pow((27.13 * abs(RGB - 0.1)) /
    	(400.0 - abs(RGB - 0.1)), 1.0 / 0.42));

	return RGB_p;
}

float2 opponent_colour_dimensions_forward(float3 RGB) {
	float a = RGB.r - 12.0 * RGB.g / 11.0 + RGB.b / 11.0;
	float b = (RGB.r + RGB.g - 2.0 * RGB.b) / 9.0;

	return float2(a, b);
}

float2 opponent_colour_dimensions_reverse(float3 P_n, float h) {
	float P_1 = P_n.r;
	float P_2 = P_n.g;
	float P_3 = P_n.b;
	float hr = radians(h);

	float sin_hr = sin(hr);
	float cos_hr = cos(hr);

	float P_4 = P_1 / sin_hr;
	float P_5 = P_1 / cos_hr;
	float n = P_2 * (2.0 + P_3) * (460.0 / 1403.0);

	float a = hr * 0.0;
	float b = hr * 0.0;

	if (abs(sin_hr) >= abs(cos_hr))
		b = (n / (P_4 + (2.0 + P_3) * (220.0 / 1403.0) * (cos_hr / sin_hr) -
        	(27.0 / 1403.0) + P_3 * (6300.0 / 1403.0)));

    if (abs(sin_hr) >= abs(cos_hr))
    	a = b * (cos_hr / sin_hr);

    if (abs(sin_hr) < abs(cos_hr))
    	a = (n / (P_5 + (2.0 + P_3) * (220.0 / 1403.0) - 
    		((27.0 / 1403.0) - P_3 * (6300.0 / 1403.0)) * (sin_hr / cos_hr)));

    if (abs(sin_hr) < abs(cos_hr))
    	b = a * (sin_hr / cos_hr);

    return float2(a, b);
}

float hue_angle(float2 ab) {
	float h = degrees(atan2(ab.g, ab.r)) % 360;
	if (h < 0) h += 360;

	return h;
}

float hue_quadrature(float h) {
	float t = ((h - 237.53)/1.2) + ((360.0 - h + 20.14)/0.8);
	float H = 300.0 + ((100 * ((h - 237.53) / 1.2)) / t);

	if (h < 20.14) {
	    t = ((h + 122.47) / 1.2) + ((20.14 - h) / 0.8);
	    H = 300.0 + (100.0 * ((h + 122.47) / 1.2)) / t;
	}

	if (h < 90.0) {
	    t = ((h - 20.14) / 0.8) + ((90.00 - h) / 0.7);
	    H = (100.0 * ((h - 20.14) / 0.8)) / t;
	}

	if (h < 164.25) {
	    t = ((h - 90.00) / 0.7) + ((164.25 - h) / 1.0);
	    H = 100.0 + ((100.0 * ((h - 90.00) / 0.7)) / t);
	}

	if (h < 237.53) {
	    t = ((h - 164.25) / 1.0) + ((237.53 - h) / 1.2);
	    H = 200.0 + ((100.0 * ((h - 164.25) / 1.0)) / t);
	}

	return H;
}

float eccentricity_factor(float h) {
	float e_t = 1.0 / 4.0 * (cos(2.0 + h * PI / 180.0) + 3.8);

	return e_t;
}

float achromatic_response_forward(float3 RGB, float N_bb) {
	float A = (2.0 * RGB.r + RGB.g + (1.0 / 20.0) * RGB.b - 0.305) * N_bb;

    return A;
}

float achromatic_response_reverse(float A_w, float J, float c, float z) {
	float A = A_w * pow(J / 100.0, 1.0 / (c * z));

    return A;
}

float lightness_correlate(float A, float A_w, float c, float z) {
	float J = 100.0 * pow(A / A_w, c * z);

	return J;
}

float brightness_correlate(float c, float J, float A_w, float F_L) {
	float Q = (4.0 / c) * sqrt(J / 100.0) * (A_w + 4.0) * pow(F_L, 0.25);

    return Q;
}

float temporary_magnitude_quantity_forward(float N_c, float N_cb, float e_t, float2 ab, float3 RGB_a) {
	float t = (((50000.0 / 13.0) * N_c * N_cb) * (e_t * pow(pow(ab.r, 2.0) + pow(ab.g, 2.0), 0.5)) /
         (RGB_a.r + RGB_a.g + 21.0 * RGB_a.b / 20.0));

    return t;
}

float temporary_magnitude_quantity_reverse(float C, float J, float n) {
	float t = pow(C / (sqrt(J / 100.0) * pow(1.64 - pow(0.29, n), 0.73)), 1.0 / 0.9);

    return t;
}

float chroma_correlate(float J, float n, float N_c, float N_cb, float e_t, float2 ab, float3 RGB_a) {
	float t = temporary_magnitude_quantity_forward(N_c, N_cb, e_t, ab, RGB_a);
	float C = pow(t, 0.9) * pow(J / 100.0, 0.5) * pow(1.64 - pow(0.29, n), 0.73);

    return C;
}

float colourfulness_correlate(float C, float F_L) {
	float M = C * pow(F_L, 0.25);

	return M;
}

float saturation_correlate(float M, float Q) {
	float s = 100.0 * pow(M / Q, 0.5);

	return s;
}

float3 P(float N_c, float N_cb, float e_t, float t, float A, float N_bb) {

    float P_1 = ((50000.0 / 13.0) * N_c * N_cb * e_t) / t;
    float P_2 = A / N_bb + 0.305;
    float P_3 = (P_1 * 0.0 + 1.0) * (21.0 / 20.0);

    return float3(P_1, P_2, P_3);
}

float3 post_adaptation_non_linear_response_compression_matrix(float P_2, float2 ab) {

    float R_a = (460.0 * P_2 + 451.0 * ab.r + 288.0 * ab.g) / 1403.0;
    float G_a = (460.0 * P_2 - 891.0 * ab.r - 261.0 * ab.g) / 1403.0;
    float B_a = (460.0 * P_2 - 220.0 * ab.r - 6300.0 * ab.g) / 1403.0;

    return float3(R_a, G_a, B_a);
}

CIECAM02_Specification XYZ_to_CIECAM02(float3 XYZ,
				                       float3 XYZ_w,
				                       float L_A,
				                       float Y_b,
				                       CIECAM02_InductionFactors surround,
				                       bool discount_illuminant) {

    float Y_w = XYZ_w.g;

    float4 vcdp = viewing_condition_dependent_parameters(Y_b, Y_w, L_A);
    float n = vcdp.r;
    float F_L = vcdp.g;
    float N_bb = vcdp.b;
    float N_cb = vcdp.b;
    float z = vcdp.a;

    // Converting *CIE XYZ* tristimulus values to CMCCAT2000 transform
    // sharpened *RGB* values.
    float3 RGB = mul(CAT02_CAT, XYZ);
    float3 RGB_w = mul(CAT02_CAT, XYZ_w);

    // Computing degree of adaptation :math:`D`.
    float D = 1.0;
    if (discount_illuminant == false)
        D = degree_of_adaptation(surround.F, L_A);

    // Computing full chromatic adaptation.
    float3 RGB_c = full_chromatic_adaptation_forward(
        RGB, RGB_w, Y_w, D);
    float3 RGB_wc = full_chromatic_adaptation_forward(
        RGB_w, RGB_w, Y_w, D);

    // Converting to *Hunt-Pointer-Estevez* colourspace.
    float3 RGB_p = RGB_to_rgb(RGB_c);
    float3 RGB_pw = RGB_to_rgb(RGB_wc);

    // Applying forward post-adaptation non linear response compression.
    float3 RGB_a = post_adaptation_non_linear_response_compression_forward(
        RGB_p, F_L);
    float3 RGB_aw = post_adaptation_non_linear_response_compression_forward(
        RGB_pw, F_L);
 
    // Converting to preliminary cartesian coordinates.
    float2 ab = opponent_colour_dimensions_forward(RGB_a);
    
    // Computing the *hue* angle :math:`h`.
    float h = hue_angle(ab);

    // Computing hue :math:`h` quadrature :math:`H`.
    float H = hue_quadrature(h);
    // TODO: Compute hue composition.

    // Computing eccentricity factor *e_t*.
    float e_t = eccentricity_factor(h);
 
    // Computing achromatic responses for the stimulus and the whitepoint.
    float A = achromatic_response_forward(RGB_a, N_bb);
    float A_w = achromatic_response_forward(RGB_aw, N_bb);

    // Computing the correlate of *Lightness* :math:`J`.
    float J = lightness_correlate(A, A_w, surround.c, z);

    // Computing the correlate of *brightness* :math:`Q`.
    float Q = brightness_correlate(surround.c, J, A_w, F_L);

    // Computing the correlate of *chroma* :math:`C`.
    float C = chroma_correlate(J, n, surround.N_c, N_cb, e_t, ab, RGB_a);

    // Computing the correlate of *colourfulness* :math:`M`.
    float M = colourfulness_correlate(C, F_L);

    // Computing the correlate of *saturation* :math:`s`.
    float s = saturation_correlate(M, Q);

    CIECAM02_Specification specification = {J, C, h, s, Q, M, H, 0};

    return specification;
}

float3 CIECAM02_to_XYZ(float J,
                       float C,
                       float h,
                       float3 XYZ_w,
                       float L_A,
                       float Y_b,
                       CIECAM02_InductionFactors surround,
                       bool discount_illuminant) {

	float Y_w = XYZ_w.g;

    float4 vcdp = viewing_condition_dependent_parameters(Y_b, Y_w, L_A);
    float n = vcdp.r;
    float F_L = vcdp.g;
    float N_bb = vcdp.b;
    float N_cb = vcdp.b;
    float z = vcdp.a;

    // Converting *CIE XYZ* tristimulus values to CMCCAT2000 transform
    // sharpened *RGB* values.
    float3 RGB_w = mul(CAT02_CAT, XYZ_w);

    // Computing degree of adaptation :math:`D`.
    float D = 1.0;
    if (discount_illuminant == false)
        D = degree_of_adaptation(surround.F, L_A);

    // Computing full chromatic adaptation.
    float3 RGB_wc = full_chromatic_adaptation_forward(
        RGB_w, RGB_w, Y_w, D);

    // Converting to *Hunt-Pointer-Estevez* colourspace.
    float3 RGB_pw = RGB_to_rgb(RGB_wc);

    // Applying forward post-adaptation non linear response compression.
    float3 RGB_aw = post_adaptation_non_linear_response_compression_forward(
        RGB_pw, F_L);

    // Computing achromatic response for the whitepoint.
    float A_w = achromatic_response_forward(RGB_aw, N_bb);

	// Computing temporary magnitude quantity :math:`t`.
    float t = temporary_magnitude_quantity_reverse(C, J, n);

    // Computing eccentricity factor *e_t*.
    float e_t = eccentricity_factor(h);

    // Computing achromatic response :math:`A` for the stimulus.
    float A = achromatic_response_reverse(A_w, J, surround.c, z);

    // Computing *P_1* to *P_3*.
    float3 P_n = P(surround.N_c, N_cb, e_t, t, A, N_bb);

    // Computing opponent colour dimensions :math:`a` and :math:`b`.
    float2 ab = opponent_colour_dimensions_reverse(P_n, h);

    // Computing post-adaptation non linear response compression matrix.
    float3 RGB_a = post_adaptation_non_linear_response_compression_matrix(
        P_n.g, ab);

    // Applying reverse post-adaptation non linear response compression.
    float3 RGB_p = post_adaptation_non_linear_response_compression_reverse(
        RGB_a, F_L);

    // Converting to *Hunt-Pointer-Estevez* colourspace.
    float3 RGB_c = rgb_to_RGB(RGB_p);

    // Applying reverse full chromatic adaptation.
    float3 RGB = full_chromatic_adaptation_reverse(RGB_c, RGB_w, Y_w, D);

    // Converting CMCCAT2000 transform sharpened *RGB* values to *CIE XYZ*
    // tristimulus values.
    float3 XYZ = mul(CAT02_INVERSE_CAT, RGB);

    return XYZ;   
}