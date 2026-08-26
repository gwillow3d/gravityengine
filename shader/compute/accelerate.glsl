#[compute]
#version 450

layout(local_size_x = 256, local_size_y = 1, local_size_z = 1) in;

const int BORDER_WRAPAROUND = 3;

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
layout(set = 0, binding = 1, std430) restrict buffer WorldGeometryBuffer {
    vec2 world_size;
    int border_type;
} geo_buf;
layout(set = 0, binding = 2, std430) restrict buffer PotentialEnergyBuffer {
    float potentials[];
} gpe_buf;
layout(push_constant) uniform NBodyParameters {
    float gravity;
    float softening;
    float delta;
    uint n_bodies;
} params;

void main() {
    uint i = gl_GlobalInvocationID.x;
    if (i >= params.n_bodies) { return; }
    
    gpe_buf.potentials[i] = 0.0;

    vec2 half_size = geo_buf.world_size / 2.0;
    vec2 i_pos = buf.bodies[i].position;
    float i_mass = buf.bodies[i].mass;
    vec2 i_vel = buf.bodies[i].velocity;
    vec2 acc = vec2(0.0, 0.0);
    float gpe = 0.0;

    for(uint j = 0; j < params.n_bodies; j++) {
        if(j == i) { continue; }
        vec2 j_pos = buf.bodies[j].position;
        float j_mass = buf.bodies[j].mass;

        vec2 d = j_pos - i_pos;
        if(geo_buf.border_type == BORDER_WRAPAROUND) {
            if(d.x > half_size.x) { d.x -= geo_buf.world_size.x; }
            if(d.x < -half_size.x) { d.x += geo_buf.world_size.x; }
            if(d.y > half_size.y) { d.y -= geo_buf.world_size.y; }
            if(d.y < -half_size.y) { d.y += geo_buf.world_size.y; }
        }

        float r = sqrt(dot(d,d) + params.softening * params.softening);
        acc += params.gravity / (r*r*r) * d * j_mass;
        gpe += -params.gravity * i_mass * j_mass / r;
    }

    buf.bodies[i].acceleration = acc;
    gpe_buf.potentials[i] += gpe * 0.5;
}