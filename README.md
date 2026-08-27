# Gravity Engine
Gravity Engine is a gravity simulator written in Godot.

## How does it work?
Gravity Engine uses the basic approach of calculating the force every particle exerts on every other particle.
This is typically extremely computationally expensive, however these calculations are run on the GPU using a compute shader to achieve reasonable speeds.

A web version is not currently possible as Godot's compute shaders cannot be run on the web, but I plan to implement the Barnes-Hut algorithm to run the engine on the CPU, and it may outperform the current GPU system as well.

## Gallery
| ![Solar System](https://github.com/gwillow3d/gravityengine/blob/master/examples/2026-08-26T23%3A39%3A45.png) | ![Black Hole](https://github.com/gwillow3d/gravityengine/blob/master/examples/2026-08-26T20%3A22%3A35.png) |
| - | - |
| ![Protoplanetary Disk](https://github.com/gwillow3d/gravityengine/blob/master/examples/2026-08-26T20%3A24%3A42.png) | ![Nebula](https://github.com/gwillow3d/gravityengine/blob/master/examples/2026-08-27T14%3A29%3A37.png) |
