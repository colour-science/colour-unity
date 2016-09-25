// IEC 61966-2-1:1999 - sRGB normalised primary matrix.
float3x3 sRGB_TO_XYZ_MATRIX = {
    0.4124, 0.3576, 0.1805,
    0.2126, 0.7152, 0.0722,
    0.0193, 0.1192, 0.9505
};

// sRGB normalised primary matrix computed from the above.
float3x3 XYZ_TO_sRGB_MATRIX = {
     3.240625477320054, -1.537207972210318, -0.498628598698248,
    -0.968930714729320, 1.875756060885241, 0.041517523842954,
     0.055710120445511, -0.204021050598487, 1.056995942254388
};

//float3 oetf_sRGB(float3 L) {
//	float3 V = 1.055 * (pow(L, (1.0 / 2.4))) - 0.055));
//
//	if (L.r < 0.0031308) 
//		V.r = L.r * 12.92;
//	if (L.g < 0.0031308) 
//		V.g = L.g * 12.92;
//	if (L.b < 0.0031308) 
//		V.b = L.b * 12.92;
//
//    return V;
//}