# Gravity Engine
[Gravity Engine](https://gwillow3d.itch.io/gravity-engine) is a Godot-based physics simulator for desktop and web.

![Screenshot with UI](https://github.com/gwillow3d/gravityengine/blob/master/examples/2026-08-28T18%3A41%3A50.png)  

## How does it work?
Gravity Engine uses the basic approach of calculating the force every particle exerts on every other particle.
This is typically extremely computationally expensive, however these calculations are run on the GPU using a compute shader to achieve reasonable speeds.

You can read a detailed writeup on the development and optimisation of Gravity Engine [here](https://gwillow3d.itch.io/gravity-engine/devlog/1651221/making-a-gravity-engine).

## Performance

> "Particle limit" denotes the greatest particle count which can reasonably be processed consistently at 60FPS. This is benchmarked from a laptop with a GTX 1050 Mobile and Intel© Core™ i5-8300H on the desktop version. Actual performance depends on your hardware and the web version generally runs slower.

| Mode | Desktop? | Web? | Particle Limit | Description |
| - | - | - | - | - |
| CPU | ✔️ | ✔️ | ~250 | Simple but low performance GDScript implementation. Maintained for compatibility but not recommended. |
| GPU (GDShader) | 🚧 | 🚧 | TBD | Implementation of O(n^2) using GDShaders. Slower than using compute shaders but supports Web browsers. |
| GPU (GLSL) | ✔️ | ✖️ | ~5,000 | Variant of the GPU method which uses `.glsl` compute shaders to attain absolutely maximum performance. Does not support web browsers due to Godot limitations. |

## Gallery
| ![Solar System](https://github.com/gwillow3d/gravityengine/blob/master/examples/2026-08-26T23%3A39%3A45.png) | ![Black Hole](https://github.com/gwillow3d/gravityengine/blob/master/examples/2026-08-27T23%3A41%3A39.png) |
| - | - |
| ![Protoplanetary Disk](https://github.com/gwillow3d/gravityengine/blob/master/examples/2026-08-26T20%3A24%3A42.png) | ![Nebula](https://github.com/gwillow3d/gravityengine/blob/master/examples/2026-08-27T14%3A29%3A37.png) |
