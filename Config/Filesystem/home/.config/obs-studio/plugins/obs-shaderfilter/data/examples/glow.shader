//Converted to OpenGL by Exeldro February 21, 2022
uniform int glow_percent<
    string label = "Glow percent";
    string widget_type = "slider";
    int minimum = 0;
    int maximum = 100;
    int step = 1;
> = 10;
uniform int blur<
    string label = "Blur";
    string widget_type = "slider";
    int minimum = 0;
    int maximum = 100;
    int step = 1;
> = 1;
uniform int min_brightness<
    string label = "Min brightness";
    string widget_type = "slider";
    int minimum = 0;
    int maximum = 100;
    int step = 1;
> = 27;
uniform int max_brightness<
    string label = "Max brightness";
    string widget_type = "slider";
    int minimum = 0;
    int maximum = 100;
    int step = 1;
> = 100;
uniform int pulse_speed<
    string label = "Pulse speed";
    string widget_type = "slider";
    int minimum = 0;
    int maximum = 100;
    int step = 1;
> = 0;
uniform bool ease;
uniform string notes<
    string widget_type = "info";
> = "'ease' - makes the animation pause at the begin and end for a moment,'glow_percent' - how much brightness to add (recommend 0-100). 'blur' - how far should the glow extend (recommend 1-4).'pulse_speed' - (0-100). 'min/max brightness' - floor and ceiling brightness level to target for glows.";


float EaseInOutCircTimer(float t,float b,float c,float d){
	t /= d/2.0;
	if (t < 1.0) return -c/2.0 * (sqrt(1.0 - t*t) - 1.0) + b;
	t -= 2.0;
	return c/2.0 * (sqrt(1.0 - t*t) + 1.0) + b;	
}

float BlurStyler(float t,float b,float c,float d,bool ease)
{
	if (ease) return EaseInOutCircTimer(t,0.0,c,d);
	return t;
}

float4 mainImage(VertData v_in) : TARGET
{
	float2 offsets[4];
    offsets[0] = float2(-0.1,  0.125);
    offsets[1] = float2(-0.1, -0.125);
    offsets[2] = float2(0.1, -0.125);
    offsets[3] = float2(0.1,  0.125);

	// convert input for vector math
	float4 col = image.Sample(textureSampler, v_in.uv);
	float blur_amount = float(blur) /100.0;
	float glow_amount = float(glow_percent) * 0.01;
	float speed = float(pulse_speed) * 0.01;	
	float luminance_floor = float(min_brightness) /100.0;
	float luminance_ceiling = float(max_brightness) /100.0;

	if (col.a > 0.0)
	{
		//circular easing variable
		float t = 1.0 + sin(elapsed_time * speed);
		float b = 0.0; //start value
		float c = 2.0; //change value
		float d = 2.0; //duration

		// simple glow calc
		for (int n = 0; n < 4; n++) {
			b = BlurStyler(t, 0, c, d, ease);
			float4 ncolor = image.Sample(textureSampler, v_in.uv + (blur_amount * b) * offsets[n]);
			float intensity = ncolor.r * 0.299 + ncolor.g * 0.587 + ncolor.b * 0.114;
			if ((intensity >= luminance_floor) && (intensity <= luminance_ceiling))
			{
				ncolor.a = clamp(ncolor.a * glow_amount, 0.0, 1.0);
				col += (ncolor * (glow_amount * b));
			}
		}
	}
	return col;

}
