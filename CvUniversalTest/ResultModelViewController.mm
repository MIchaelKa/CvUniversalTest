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
    -1.5f, -0.5f, -1.0f,
    0.5f, -0.5f, -1.0f
};

#define NUM_PARTICLES 360

typedef struct Particle
{
    float       theta;
}
Particle;

typedef struct Emitter
{
    Particle    particles[NUM_PARTICLES];
    int         k;
}
Emitter;

Emitter emitter = {0.0f};

@interface ResultModelViewController()

@property (strong, nonatomic) EAGLContext *context;

// Program Handle
@property (readwrite) GLint program;

// Attribute Handles
@property (readwrite) GLint aTheta;

// Uniform Handles
@property (readwrite) GLint uProjectionMatrix;
@property (readwrite) GLint uK;

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
    for(int i=0; i<NUM_PARTICLES; i++)
    {
        // Assign each particle its theta value (in radians)
        emitter.particles[i].theta = GLKMathDegreesToRadians(i);
    }
    emitter.k = 4.0f;
    
    // Create Vertex Buffer Object (VBO)
    GLuint particleBuffer = 0;
    glGenBuffers(1, &particleBuffer);                   // Generate particle buffer
    glBindBuffer(GL_ARRAY_BUFFER, particleBuffer);      // Bind particle buffer
    glBufferData(                                       // Fill bound buffer with particles
                 GL_ARRAY_BUFFER,                       // Buffer type (vertices/particles)
                 sizeof(emitter.particles),                // Buffer data size
                 emitter.particles,                        // Buffer data pointer
                 GL_STATIC_DRAW);                       // Data never changes
}

- (void)loadShader
{
    ShaderProcessor *shaderProcessor = [ShaderProcessor new];
    self.program = [shaderProcessor buildProgram:SimplePointVS with:SimplePointFS];
    
    // Attributes
    self.aTheta = glGetAttribLocation(self.program, "aTheta");
    
    // Uniforms
    self.uProjectionMatrix = glGetUniformLocation(self.program, "uProjectionMatrix");
    self.uK = glGetUniformLocation(self.program, "uK");
    
    glUseProgram(self.program);
}


- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClear(GL_COLOR_BUFFER_BIT);
    
    // 1
    // Create Projection Matrix
    float aspectRatio = view.frame.size.width / view.frame.size.height;
    GLKMatrix4 projectionMatrix = GLKMatrix4MakeScale(1.0f, aspectRatio, 1.0f);
    
    // 2
    // Uniforms
    glUniformMatrix4fv(self.uProjectionMatrix, 1, 0, projectionMatrix.m);
    glUniform1f(self.uK, emitter.k);
    
    // 3
    // Attributes
    glEnableVertexAttribArray(self.aTheta);
    glVertexAttribPointer(self.aTheta,                // Set pointer
                          1,                                        // One component per particle
                          GL_FLOAT,                                 // Data is floating point type
                          GL_FALSE,                                 // No fixed point scaling
                          sizeof(Particle),                         // No gaps in data
                          (void*)(offsetof(Particle, theta)));      // Start from "theta" offset within bound
    
    // 4
    // Draw particles
    glDrawArrays(GL_POINTS, 0, NUM_PARTICLES);
    glDisableVertexAttribArray(self.aTheta);
}

@end
