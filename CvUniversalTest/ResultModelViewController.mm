//
//  ResultModelViewController.m
//  CvUniversalTest
//
//  Created by Michael Kalinin on 28/04/16.
//  Copyright © 2016 Michael. All rights reserved.
//

#import "ResultModelViewController.h"

#import "ShaderProcessor.h"
// Shaders
#define STRINGIFY(A) #A
#include "Shaders/SimplePoint.vsh"
#include "Shaders/SimplePoint.fsh"


static const GLfloat squareVertices[] = {
    -0.5f, -0.5f, -1.0f,
    0.5f, -0.5f, -1.0f,
    0.5f,  0.5f, -1.0f,
    -0.5f, 0.5f,  -1.0f
};

@interface ResultModelViewController()

@property (strong, nonatomic) EAGLContext *context;

// Program Handle
@property (readwrite) GLint program;

// Uniform Handles
@property (readwrite) GLint uProjectionMatrix;


@end

@implementation ResultModelViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupGL];
    
    [self loadParticles];
    [self loadShader];
}

- (void)setupGL
{
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext: self.context];
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    
    glClearColor(210.0/255.0, 219.0/255.0, 242.0/255.0, 1.0);
}

- (void)loadParticles
{
    // Create Vertex Buffer Object (VBO)
    GLuint particleBuffer = 0;
    glGenBuffers(1, &particleBuffer);                   // Generate particle buffer
    glBindBuffer(GL_ARRAY_BUFFER, particleBuffer);      // Bind particle buffer
    glBufferData(                                       // Fill bound buffer with particles
                 GL_ARRAY_BUFFER,                       // Buffer type (vertices/particles)
                 sizeof(squareVertices),                // Buffer data size
                 squareVertices,                        // Buffer data pointer
                 GL_STATIC_DRAW);                       // Data never changes
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition,
                          3,
                          GL_FLOAT,
                          GL_FALSE,
                          0,
                          0);
}

- (void)loadShader
{
    ShaderProcessor *shaderProcessor = [ShaderProcessor new];
    self.program = [shaderProcessor buildProgram:SimplePointVS with:SimplePointFS];
    
    // Uniforms
    self.uProjectionMatrix = glGetUniformLocation(self.program, "uProjectionMatrix");
    
    glUseProgram(self.program);
}


- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClear(GL_COLOR_BUFFER_BIT);

    // Create Projection Matrix
    float aspectRatio = view.frame.size.width / view.frame.size.height;
    GLKMatrix4 projectionMatrix = GLKMatrix4MakeScale(1.0f, aspectRatio, 1.0f);

    // Uniforms
    glUniformMatrix4fv(self.uProjectionMatrix, 1, 0, projectionMatrix.m);

    // Draw particles
    glDrawArrays(GL_POINTS, 0, 4);
}

@end
