# Gravity Engine
[Gravity Engine](https://gwillow3d.itch.io/gravity-engine) is a Godot-based physics simulator for desktop and web.

![Screenshot with UI](https://github.com/gwillow3d/gravityengine/blob/master/examples/2026-08-28T18%3A41%3A50.png)

> **Note!**  
> Whilst Gravity Engine can run on the web, Godot does not support the GPU-acceleration it usually uses. As such, Gravity Engine must render on the CPU, which is extremely slow, and will limit you to very small simulations.  
> A faster CPU simulator will be implemented eventually to improve the web version.

## How does it work?
Gravity Engine uses the basic approach of calculating the force every particle exerts on every other particle.
This is typically extremely computationally expensive, however these calculations are run on the GPU using a compute shader to achieve reasonable speeds.

## Gallery
| ![Solar System](https://github.com/gwillow3d/gravityengine/blob/master/examples/2026-08-26T23%3A39%3A45.png) | ![Black Hole](https://github.com/gwillow3d/gravityengine/blob/master/examples/2026-08-27T23%3A41%3A39.png) |
| - | - |
| ![Protoplanetary Disk](https://github.com/gwillow3d/gravityengine/blob/master/examples/2026-08-26T20%3A24%3A42.png) | ![Nebula](https://github.com/gwillow3d/gravityengine/blob/master/examples/2026-08-27T14%3A29%3A37.png) |
