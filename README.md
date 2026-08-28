# Gravity Engine
Gravity Engine is a gravity simulator written in Godot.

<img src="https://github.com/gwillow3d/gravityengine/blob/master/examples/2026-08-28T01%3A20%3A59.png" width="720">

## How does it work?
Gravity Engine uses the basic approach of calculating the force every particle exerts on every other particle.
This is typically extremely computationally expensive, however these calculations are run on the GPU using a compute shader to achieve reasonable speeds.

Both desktop and the web are currently supported, however the web version does not currently support GPU acceleration. This makes it much slower and limits it to a small number of particles, but an GDShader implementation is in the works to bring GPU simulation to the web.

## Gallery
| ![Solar System](https://github.com/gwillow3d/gravityengine/blob/master/examples/2026-08-26T23%3A39%3A45.png) | ![Black Hole](https://github.com/gwillow3d/gravityengine/blob/master/examples/2026-08-27T23%3A41%3A39.png) |
| - | - |
| ![Protoplanetary Disk](https://github.com/gwillow3d/gravityengine/blob/master/examples/2026-08-26T20%3A24%3A42.png) | ![Nebula](https://github.com/gwillow3d/gravityengine/blob/master/examples/2026-08-27T14%3A29%3A37.png) |
