//
//  Shader.fsh
//  Trans Ball
//
//  Created by Egor Vilkin on 7/30/14.
//  Copyright (c) 2014 EVil corp. All rights reserved.
//

varying lowp vec4 colorVarying;
varying lowp vec2 texCoordFrag;
uniform lowp int noTexture;
uniform sampler2D texture0;

void main()
{
    if(noTexture == 0)
        gl_FragColor = colorVarying;
    else
        gl_FragColor = colorVarying * texture2D(texture0, texCoordFrag);
}
