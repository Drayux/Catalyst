//Converted to OpenGL by Q-mii & Exeldro February 21, 2022
uniform	float innerRadius<
    string label = "inner radius";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 5.0;
    float step = 0.001;
> = 0.9;
uniform	float outerRadius<
    string label = "outer radius";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 5.0;
    float step = 0.001;
> = 1.5;
uniform	float opacity<
    string label = "opacity";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 1.0;
    float step = 0.001;
> = 0.8;
uniform string notes<
    string widget_type = "info";
> = "inner radius will always be shown, outer radius is the falloff";

float4 mainImage(VertData v_in) : TARGET
{
	float PI = 3.1415926535897932384626433832795;//acos(-1);

	float4 c0 = image.Sample(textureSampler, v_in.uv);
	float verticalDim = 0.5 + sin (v_in.uv.y * PI) * 0.9 ;
	
	float xTrans = (v_in.uv.x * 2) - 1;
	float yTrans = 1 - (v_in.uv.y * 2);
	
	float radius = sqrt(pow(xTrans, 2) + pow(yTrans, 2));

	float subtraction = max(0, radius - innerRadius) / max((outerRadius - innerRadius), 0.01);
	float factor = 1 - subtraction;

	float4 vignetColor = c0 * factor;
	vignetColor *= verticalDim;

	vignetColor *= opacity;
	c0 *= 1-opacity;

	float4 output_color = c0 + vignetColor;	
	
	return float4(output_color);
}
