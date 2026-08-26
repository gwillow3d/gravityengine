#[compute]
#version 450

layout(local_size_x = 256, local_size_y = 1, local_size_z = 1) in;

struct Body {
    vec2 position;
    vec2 acceleration;
    vec2 velocity;
    float mass;
    float _pad;
};

layout(set = 0, binding = 0, std430) restrict buffer NBodyDataBuffer { 
    Body bodies[];
} buf;
layout(push_constant) uniform NBodyParameters {
    float gravity;
    float softening;
    float delta;
    uint n_bodies;
} params;

void main() {
    uint i = gl_GlobalInvocationID.x;
    if (i >= params.n_bodies) { return; }
    buf.bodies[i].velocity += buf.bodies[i].acceleration * (params.delta * 0.5);
}