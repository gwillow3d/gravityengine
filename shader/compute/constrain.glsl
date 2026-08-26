#[compute]
#version 450

layout(local_size_x = 256, local_size_y = 1, local_size_z = 1) in;

const int BORDER_NONE = 0;
const int BORDER_STOP = 1;
const int BORDER_BOUNCE = 2;
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
layout(push_constant) uniform NBodyParameters {
    float gravity;
    float softening;
    float delta;
    uint n_bodies;
} params;

void main() {
    uint i = gl_GlobalInvocationID.x;
    if (i >= params.n_bodies || geo_buf.border_type == BORDER_NONE) { return; }
    float w = geo_buf.world_size.x;
    float h = geo_buf.world_size.y;
    vec2 pos = buf.bodies[i].position;

    switch(geo_buf.border_type) {
        case BORDER_STOP:
            buf.bodies[i].position.x = clamp(pos.x, 0, w);
            buf.bodies[i].position.y = clamp(pos.y, 0, h);
            if(buf.bodies[i].position.x != pos.x) { buf.bodies[i].position.x = 0.0; }
            if(buf.bodies[i].position.y != pos.y) { buf.bodies[i].position.y = 0.0; }
            break;
        case BORDER_BOUNCE:
				if(pos.x < 0 || pos.x > w) {
                    float offset = pos.x < 0.0 ? -pos.x : w - pos.x;
                    offset *= 2.0;
                    buf.bodies[i].position.x += offset;
                    buf.bodies[i].velocity.x *= -1.0;
                }
				if(pos.y < 0 || pos.y > h) {
					float offset = pos.y < 0.0 ? -pos.y : h - pos.y;
                    offset *= 2.0;
					buf.bodies[i].position.y += offset;
                    buf.bodies[i].velocity.y *= -1.0;
                }
            break;
        case BORDER_WRAPAROUND:
            buf.bodies[i].position.x = mod(mod(pos.x, w) + w, w);
            buf.bodies[i].position.y = mod(mod(pos.y, h) + h, h);
    }   
}