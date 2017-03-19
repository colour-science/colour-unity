#define PI 3.14159265359
#define EPSILON 0.0000001

float linear_conversion(float x, float in_min, float in_max, float out_min, float out_max)
{
	return (((x - in_min) / (in_max - in_min)) *
    	(out_max - out_min) + out_min);
}