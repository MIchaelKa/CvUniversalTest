//
//  ShaderProcessor.h
//  CvUniversalTest
//
//  Created by Michael Kalinin on 28/04/16.
//  Copyright © 2016 Michael. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface ShaderProcessor : NSObject

- (GLuint)buildProgram:(const char*)vertexShaderSource with:(const char*)fragmentShaderSource;

@end
