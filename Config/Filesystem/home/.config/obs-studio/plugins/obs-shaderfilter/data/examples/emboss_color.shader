// Color Emboss shader by Charles Fettinger for obs-shaderfilter plugin 4/2019
//https://github.com/Oncorporation/obs-shaderfilter
//Converted to OpenGL by Q-mii & Exeldro February 18, 2022
uniform int Angle_Steps<
    string label = "Angle Steps";
    string widget_type = "slider";
    int minimum = 1;
    int maximum = 20;
    int step = 1;
> = 9; //<range 1 - 20>
uniform int Radius_Steps<
    string label = "Radius Steps";
    string widget_type = "slider";
    int minimum = 0;
    int maximum = 20;
    int step = 1;
> = 4; //<range 0 - 20>
uniform float ampFactor<
    string label = "amp Factor";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 10.0;
    float step = 0.01;
> = 12.0;
uniform int Up_Down_Percent<
    string label = "Up Down Percent";
    string widget_type = "slider";
    int minimum = -100;
    int maximum = 100;
    int step = 1;
> = 0;
uniform bool Apply_To_Alpha_Layer = true;
uniform string notes<
    string widget_type = "info";
> = "Steps limited in range from 0 to 20. Edit shader to remove limits at your own risk.";

float4 mainImage(VertData v_in) : TARGET
{
	float radiusSteps = clamp(Radius_Steps, 0, 20);
	float angleSteps = clamp(Angle_Steps, 1, 20);
	float PI = 3.1415926535897932384626433832795;//acos(-1);
	int totalSteps = int(radiusSteps * angleSteps);
	float minRadius = (1 * uv_pixel_interval.y);
	float maxRadius = (6 * uv_pixel_interval.y);

	float angleDelta = ((2 * PI) / angleSteps);
	float radiusDelta = ((maxRadius - minRadius) / radiusSteps);
	float embossAngle = 0.25 * PI;

	float4 c0 = image.Sample(textureSampler, v_in.uv);
	float4 origColor = c0;
	float4 accumulatedColor = float4(0,0,0,0);

	if (c0.a > 0.0 || Apply_To_Alpha_Layer == false)
	{
		for (int radiusStep = 0; radiusStep < radiusSteps; radiusStep++) {
			float radius = minRadius + radiusStep * radiusDelta;

			for (float angle = 0; angle < (2 * PI); angle += angleDelta) {
				float2 currentCoord;

				float xDiff = radius * cos(angle);
				float yDiff = radius * sin(angle);

				currentCoord = v_in.uv + float2(xDiff, yDiff);
				float4 currentColor = image.Sample(textureSampler, currentCoord);
				float4 colorDiff = abs(c0 - currentColor);
				float currentFraction = ((radiusSteps + 1 - radiusStep)) / (radiusSteps + 1);
				accumulatedColor += currentFraction * colorDiff / totalSteps * sign(angle - PI);;

			}
		}
		accumulatedColor *= ampFactor;

		c0 = lerp(c0 + accumulatedColor, c0 - accumulatedColor, (Up_Down_Percent * 0.01));
	}
	//return c0 + accumulatedColor; // down;
	//return c0 - accumulatedColor; // up
	return c0;
}
