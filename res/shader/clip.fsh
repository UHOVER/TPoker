#ifdef GL_ES
precision mediump float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;

uniform vec2 resolution;
uniform vec2 center;
//uniform float radius;
uniform float blurRadius;

void main(void)
{
    vec4 c = texture2D(CC_Texture0, v_texCoord);
    gl_FragColor = c;
    
    vec2 _pCenter = vec2(0.5,0.5);
    //    vec2 _pCenter = center;
    float dis = distance(v_texCoord*resolution, _pCenter*resolution);
    if(dis > 100.0){
        //    if(dis > blurRadius){
        gl_FragColor = vec4(0.0,0.0,0.0,0.0);
    }
    if(dis<100.0 && dis>96.0)
    {
        gl_FragColor = vec4(0.3,0.3,0.3,0.3);
    }
}