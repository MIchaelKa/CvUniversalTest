// Vertex Shader

static const char* SimplePointVS = STRINGIFY
(
 
attribute vec4 position;
uniform mat4 uProjectionMatrix;
 
void main(void)
{
    
    gl_Position = uProjectionMatrix * position;
    gl_PointSize = 16.0;
}
 
);