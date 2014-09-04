//
//  Shader.vsh
//  Trans Ball
//
//  Created by Egor Vilkin on 7/30/14.
//  Copyright (c) 2014 EVil corp. All rights reserved.
//

attribute vec4 position;
attribute vec3 normal;
attribute vec4 color;
attribute vec2 texCoord;

varying lowp vec4 colorVarying;
varying lowp vec2 texCoordFrag;

uniform mat4 modelViewProjectionMatrix;
uniform mat3 normalMatrix;
uniform sampler2D texture0;

void main()
{
    vec3 eyeNormal = normalize(normalMatrix * normal);
    vec3 lightPosition = vec3(4.0, 1.0, 2.0);
    
    float nDotVP = max(0.0, dot(eyeNormal, normalize(lightPosition)));
                 
    colorVarying = color;
    texCoordFrag = texCoord;
    
    gl_Position = modelViewProjectionMatrix * position;
}
