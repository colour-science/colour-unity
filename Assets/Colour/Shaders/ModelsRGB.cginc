// *IEC 61966-2-1:1999* - *sRGB* normalised primary matrix.
static const float3x3 sRGB_TO_XYZ_MATRIX = {
    0.4124, 0.3576, 0.1805,
    0.2126, 0.7152, 0.0722,
    0.0193, 0.1192, 0.9505
};

// *sRGB* inverse normalised primary matrix computed from the above.
static const float3x3 XYZ_TO_sRGB_MATRIX = {
    3.240625477320054, -1.537207972210318, -0.498628598698248,
    -0.968930714729320, 1.875756060885241, 0.041517523842954,
    0.055710120445511, -0.204021050598487, 1.056995942254388
};

float eotf_reverse_sRGB_scalar(float L) {
	float V = 1.055 * (pow(L, 1.0 / 2.4)) - 0.055;

	if (L <= 0.0031308)
		V = L * 12.92;

	return V;
}

float3 eotf_reverse_sRGB(float3 L) {
	return float3(eotf_reverse_sRGB_scalar(L.r), eotf_reverse_sRGB_scalar(L.g), eotf_reverse_sRGB_scalar(L.b));
}

float eotf_sRGB_scalar(float V) {
	float L = pow((V + 0.055) / 1.055, 2.4);

	if (V <= eotf_reverse_sRGB_scalar(0.0031308))
		L = V / 12.92;

	return L;
}

float3 eotf_sRGB(float3 V) {
	return float3(eotf_sRGB_scalar(V.r), eotf_sRGB_scalar(V.g), eotf_sRGB_scalar(V.b));
}

// *sRGB* to *ACEScg* matrix computed using *CAT02* chromatic adaptation transform.
static const float3x3 sRGB_TO_ACES_CG_MATRIX = {
    0.613117812906440, 0.341181995855625, 0.045787344282337,
    0.069934082307513, 0.918103037508581, 0.011932775530201,
    0.020462992637737, 0.106768663382511, 0.872715910619442
};

// *ACEScg* to *sRGB* matrix computed using *CAT02* chromatic adaptation transform.
static const float3x3 ACES_CG_TO_sRGB_MATRIX = {
    1.704887331049503, -0.624157274479025, -0.080886773895704,
    -0.129520935348888, 1.138399326040076, -0.008779241755018,
    -0.024127059936902, -0.124620612286390, 1.148822109913262
};

// *sRGB* to *ACES 2065-1* matrix computed using *CAT02* chromatic adaptation transform.
static const float3x3 sRGB_TO_ACES_2065_1_MATRIX = {
	0.439585644154173, 0.383929403013798, 0.176532736365944,
    0.089539573517554, 0.814749835091447, 0.095683606092672,
    0.017387183243411, 0.108739114321481, 0.873820587613957
};

// *ACES 2065-1* to *sRGB* matrix computed using *CAT02* chromatic adaptation transform.
static const float3x3 ACES_2065_1_TO_sRGB_MATRIX = {
	2.521649429843306, -1.136888554222259, -0.384917593194445,
    -0.275213551244026, 1.369705151026325, -0.094392450776520,
    -0.015925010090464, -0.147806368110800, 1.163805815942430
};

// *sRGB* to *Rec. 2020* matrix computed using *CAT02* chromatic adaptation transform.
static const float3x3 sRGB_TO_REC2020_MATRIX = {
    0.627441372057978, 0.329297459521909, 0.043351458394495,
    0.069027617147078, 0.919580666887028, 0.011361422575401,
    0.016364235071681, 0.088017162471727, 0.895564972725983
};

struct ST2084_Constants
{
    float m_1;
    float m_2;
    float c_1;
    float c_2;
    float c_3;
};

static const ST2084_Constants ST2084_CONSTANTS = {
    2610.0 / 4096.0 * (1.0 / 4.0), 
    2523.0 / 4096.0 * 128.0,
    3424.0 / 4096.0,
    2413.0 / 4096.0 * 32.0,
    2392.0 / 4096.0 * 32.0
};

float3 eotf_reverse_ST2084(float3 C, float L_p) {
    float3 Y_p = pow(C / L_p, ST2084_CONSTANTS.m_1);

    float3 N = pow((ST2084_CONSTANTS.c_1 + ST2084_CONSTANTS.c_2 * Y_p) / 
    	(ST2084_CONSTANTS.c_3 * Y_p + 1.0), ST2084_CONSTANTS.m_2);

    return(N);
}