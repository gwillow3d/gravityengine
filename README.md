# Gravity Engine
[Gravity Engine](https://gwillow3d.itch.io/gravity-engine) is a Godot-based physics simulator for desktop and web.

![Screenshot with UI](https://github.com/gwillow3d/gravityengine/blob/master/examples/2026-08-28T18%3A41%3A50.png)

> **Note!**  
> Whilst Gravity Engine can run on the web, Godot does not support the GPU-acceleration it usually uses. As such, Gravity Engine must render on the CPU, which is much slower and will limit you to smaller simulations.  

## How does it work?
Gravity Engine uses the basic approach of calculating the force every particle exerts on every other particle.
This is typically extremely computationally expensive, however these calculations are run on the GPU using a compute shader to achieve reasonable speeds.

Gravity Engine currently contains 3 simulation modes, which have varying performance and varied support depending on the platform. A fourth, much faster simulation is in the works, but requires a complex rewrite of the currently CPU-bound rendering engine.

| Mode | Desktop | Web? | Particle Limit | Description |
| - | - | - | - | - |
| CPU | ✔️ | ✔️ | ~100 | Slow and basic GDScript implementation. Will be maintained for compatibility, but is not recommended, |
| FastCPU | ✔️ | 🚧 | ~500 | Faster rewrite of the CPU simulation in rust. Web support is work in progress but planned |
| GPU | ✔️ | ✖️ | ~5,000 | Implementation of the n-body algorithm as a compute shader, able to run extremely fast, but does not support the web. |
| FastGPU | 🚧 | ✖️ | At least 12,000 | Improved GPU algorithm which passes particle data directly to the renderer, thus bypassing the GPU. Currently a work-in-progress. |

> Particle limit describes the maximum particle count which can be processed within less than 1000 / 60 = 16.667ms. This is benchmarked from a laptop with a GTX 1050 Mobile and Intel© Core™ i5-8300H. Actual performance depends on your hardware.

> CPU and FastCPU will both be maintained for compatibility with new hardware, however FastGPU will completely replace the standard GPU mode when complete. 

## Gallery
| ![Solar System](https://github.com/gwillow3d/gravityengine/blob/master/examples/2026-08-26T23%3A39%3A45.png) | ![Black Hole](https://github.com/gwillow3d/gravityengine/blob/master/examples/2026-08-27T23%3A41%3A39.png) |
| - | - |
| ![Protoplanetary Disk](https://github.com/gwillow3d/gravityengine/blob/master/examples/2026-08-26T20%3A24%3A42.png) | ![Nebula](https://github.com/gwillow3d/gravityengine/blob/master/examples/2026-08-27T14%3A29%3A37.png) |
