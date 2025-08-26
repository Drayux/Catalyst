// Seasick - an effect for OBS Studio
//
uniform string notes<
    string widget_type = "info";
> = "Seasick - from the game Snavenger\n\n(available on Google Play/Amazon Fire)";
uniform float amplitude<
    string label = "amplitude";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 1.0;
    float step = 0.001;
> = 0.03;
uniform float speed<
    string label = "speed";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 10.0;
    float step = 0.01;
> = 1.0;
uniform float frequency<
    string label = "frequency";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 100.0;
    float step = 0.01;
> = 6.0;
uniform float opacity<
    string label = "opacity";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 1.0;
    float step = 0.001;
> = 0.5;

float4 mainImage(VertData v_in) : TARGET
{
	float2 pulse = sin(elapsed_time*speed - frequency * v_in.uv);
	float2 coord = v_in.uv + amplitude * float2(pulse.x, -pulse.y);
	return image.Sample(textureSampler, coord) * opacity;
}
