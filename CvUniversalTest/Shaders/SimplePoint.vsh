// Vertex Shader

static const char* SimplePointVS = STRINGIFY
(
 
attribute vec4 position;
uniform mat4 uProjectionMatrix;
uniform mat4 uRotationMatrix;
 
void main(void)
{
    vec4 final_position = position;
    
    final_position = uProjectionMatrix * position;
    
    gl_Position = uRotationMatrix * final_position;
    gl_PointSize = 10.0;
}
 
);