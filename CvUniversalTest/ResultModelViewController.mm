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
    -0.1f, -0.1f, 0.0f,
    0.1f, -0.1f, 0.0f,
    0.1f,  0.1f, 0.0f,
    -0.1f, 0.1f,  0.0f
};

@interface ResultModelViewController()
{
    float *finalResultPointArray;
}

@property (strong, nonatomic) EAGLContext *context;

// Program Handle
@property (readwrite) GLint program;

// Uniform Handles
@property (readwrite) GLint uProjectionMatrix;
@property (readwrite) GLint uRotationMatrix;

@property (nonatomic) GLKMatrix4 savedModelViewMatrix;

@property (nonatomic) CGPoint startPanningPoint;

@property (nonatomic) float rotationValueAxisX;
@property (nonatomic) float rotationValueAxisY;
@property (nonatomic) float rotationValueAxisZ;


@end

@implementation ResultModelViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self preparePoints];
    
    [self setupGL];
    
    [self loadParticles];
    [self loadShader];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self.view addGestureRecognizer:panGesture];
    
    self.rotationValueAxisX = 0.0;
    self.rotationValueAxisY = 0.0;
    self.rotationValueAxisZ = 0.0;
    
    self.savedModelViewMatrix = GLKMatrix4MakeScale(1.0, 1.0, 1.0);
}

- (void)preparePoints
{
    if (self.points)
    {
        float max = 0.0;
        
        for (NSNumber *num in self.points)
        {
            float current = std::abs([num floatValue]);
            if (current > max) {
                max = current;
            }
        }
        
        NSLog(@"Max : %f", max);
        
        finalResultPointArray = new float [[self.points count]];
        for (NSInteger i = 0; i < [self.points count]; i++)
        {
            finalResultPointArray[i] = [self.points[i] floatValue];
        }
    }
    
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
                 sizeof(finalResultPointArray),                // Buffer data size
                 finalResultPointArray,                        // Buffer data pointer
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
    self.uRotationMatrix = glGetUniformLocation(self.program, "uRotationMatrix");
    
    
    glUseProgram(self.program);
}

- (void)makeRotation
{
    bool isInvertible;
    
    // x
    GLKVector3 xAxis = GLKMatrix4MultiplyVector3(GLKMatrix4Invert(self.savedModelViewMatrix, &isInvertible),
                                                 GLKVector3Make(1, 0, 0));
    self.savedModelViewMatrix = GLKMatrix4Rotate(
                                                 self.savedModelViewMatrix,
                                                 GLKMathDegreesToRadians(self.rotationValueAxisX),
                                                 xAxis.x, xAxis.y, xAxis.z);
    
    // y
    GLKVector3 yAxis = GLKMatrix4MultiplyVector3(GLKMatrix4Invert(self.savedModelViewMatrix, &isInvertible),
                                                 GLKVector3Make(0, 1, 0));
    self.savedModelViewMatrix = GLKMatrix4Rotate(
                                                 self.savedModelViewMatrix,
                                                 GLKMathDegreesToRadians(self.rotationValueAxisY),
                                                 yAxis.x, yAxis.y, yAxis.z);
}

- (void)pan:(UIPanGestureRecognizer *)sender
{
    CGPoint gesturePoint = [sender locationInView: self.view];
    
    switch (sender.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            self.startPanningPoint = gesturePoint;
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            [self setUserRotation: gesturePoint];
            [self makeRotation];

            break;
        }
        case UIGestureRecognizerStateEnded:
        {
            [self setUserRotation: gesturePoint];
            [self makeRotation];
            
            self.rotationValueAxisX = 0.0;
            self.rotationValueAxisY = 0.0;
            self.rotationValueAxisZ = 0.0;
            break;
        }
        default:
        {
            break;
        }
    }
}

- (void) setUserRotation: (CGPoint)endPanningPoint
{
    self.rotationValueAxisX = -(endPanningPoint.y - self.startPanningPoint.y) / 4.0;
    self.rotationValueAxisY = -(endPanningPoint.x - self.startPanningPoint.x) / 4.0;
}


- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClear(GL_COLOR_BUFFER_BIT);

    // Create Projection Matrix
    float aspectRatio = view.frame.size.width / view.frame.size.height;
    GLKMatrix4 projectionMatrix = GLKMatrix4MakeScale(1.0f, aspectRatio, 1.0f);
    
    // Create Rotation Matrix
    GLKMatrix4 rotationMatrix = self.savedModelViewMatrix;

    // Uniforms
    glUniformMatrix4fv(self.uProjectionMatrix, 1, 0, projectionMatrix.m);
    glUniformMatrix4fv(self.uRotationMatrix, 1, 0, rotationMatrix.m);

    // Draw particles
    glDrawArrays(GL_POINTS, 0, 300);
}

@end
