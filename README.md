# Gravity Engine
[Gravity Engine](https://gwillow3d.itch.io/gravity-engine) is a Godot-based physics simulator for desktop and web.

![Screenshot with UI](https://github.com/gwillow3d/gravityengine/blob/master/examples/2026-08-28T18%3A41%3A50.png)  

## How does it work?
Gravity Engine computes the attraction between every pair of particles using the naive approach of comparing every single pair directly. This is generally inefficient because each doubling of particles quadruples the necessary work, resulting in a [time complexity of O(n²)](https://en.wikipedia.org/wiki/Big_O_notation]).  
  
In order to make this viable, the calculations are done on the GPU as opposed to the CPU, which allows for many concurrent calculations as opposed to many consecutive calculations. 

You can read a detailed writeup on the development and optimisation of Gravity Engine [here](https://gwillow3d.itch.io/gravity-engine/devlog/1651221/making-a-gravity-engine).
> *Note: For very large particle counts (100,000+) a faster approach known as [Barnes-Hut](https://en.wikipedia.org/wiki/Barnes%E2%80%93Hut_simulation) is often used. Gravity Engine does not use this as it is challenging to implement and would likely demand a rust implementation to effectively surpass the GPU system, which would make cross-platform support difficult.*

## Performance

Every doubling of the particle count quadruples the amount of interactions. Each tier of the benchmark doubles the time budget, which should increase max particles by about 1.41x. Exact figures will deviate from this due to fixed overhead costs however.

#### Benchmark 1 
> **CPU: i5-8300H  
> GPU: GTX 1050 Mobile (4GB)**

| Mode | 1ms | 2ms | 4ms | 8ms | 16.67ms<sup>1</sup> | 32ms |
| - | - | - | - | - | - | - |
| CPU | 25 | 35 | 60 | 110 | 170 | 270 |
| GPU (GLSL) | 125 | 500 | 1,300 | 3,500 | 11,000 | TBD<sup>2</sup>|

> <sup>1</sup> 16.67ms is the frame budget for 60 FPS.  
> <sup>2</sup> Cannot be reliably measured due to CPU interference. 

## Gallery
| ![Solar System](https://github.com/gwillow3d/gravityengine/blob/master/examples/2026-08-26T23%3A39%3A45.png) | ![Black Hole](https://github.com/gwillow3d/gravityengine/blob/master/examples/2026-08-27T23%3A41%3A39.png) |
| - | - |
| ![Protoplanetary Disk](https://github.com/gwillow3d/gravityengine/blob/master/examples/2026-08-26T20%3A24%3A42.png) | ![Nebula](https://github.com/gwillow3d/gravityengine/blob/master/examples/2026-08-27T14%3A29%3A37.png) |
