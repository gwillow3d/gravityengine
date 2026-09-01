# Gravity Engine
[Gravity Engine](https://gwillow3d.itch.io/gravity-engine) is a Godot-based physics simulator for desktop and web.

![Screenshot with UI](https://github.com/gwillow3d/gravityengine/blob/master/examples/2026-08-28T18%3A41%3A50.png)  

## How does it work?
Gravity Engine uses the basic approach of calculating the force every particle exerts on every other particle.
This is typically extremely computationally expensive, however these calculations are run on the GPU using a compute shader to achieve reasonable speeds.

Gravity Engine currently contains 3 simulation modes, which have varying performance and varied support depending on the platform. A fourth, much faster simulation is in the works, but requires a complex rewrite of the currently CPU-bound rendering engine.

## Performance

> Particle limit describes the maximum particle count which can be processed within less than 1000 / 60 = 16.667ms. This is benchmarked from a laptop with a GTX 1050 Mobile and Intel© Core™ i5-8300H on the desktop version. Actual performance depends on your hardware. The web version generally runs much slower.

| Mode | Desktop? | Web? | Particle Limit | Description |
| - | - | - | - | - |
| CPU | ✔️ | ✔️ | ~100 | Slow and basic GDScript implementation. Will be maintained for compatibility, but is not recommended, |
| FastCPU | ✔️ | 🚧 | ~500 | Faster rewrite of the CPU simulation in rust. Web support is work in progress but planned |
| GPU | ✔️ | ✖️ | ~5,000 | Implementation of the n-body algorithm as a compute shader, able to run extremely fast, but does not support the web. |
| FastGPU | 🚧 | ✖️ | TBD | Improved GPU algorithm which passes particle data directly to the renderer, thus bypassing the CPU. Currently a work-in-progress. |
| Barnes-Hut | 🚧 | 🚧 | TBD | A rust implementation of the extremely efficient Barnes-Hut simulation. Likely able to handle tens, if not hundreds of thousands of particles. Planned for release after FastCPU and FastGPU are fully implemented. |

## Gallery
| ![Solar System](https://github.com/gwillow3d/gravityengine/blob/master/examples/2026-08-26T23%3A39%3A45.png) | ![Black Hole](https://github.com/gwillow3d/gravityengine/blob/master/examples/2026-08-27T23%3A41%3A39.png) |
| - | - |
| ![Protoplanetary Disk](https://github.com/gwillow3d/gravityengine/blob/master/examples/2026-08-26T20%3A24%3A42.png) | ![Nebula](https://github.com/gwillow3d/gravityengine/blob/master/examples/2026-08-27T14%3A29%3A37.png) |

## Building and Exporting
Both the web and desktop versions can be exported using `Project > Export` in Godot with Gravity Engine's export presets. You may need to install the correct export templates however.
This will only include the CPU and GPU modes however, not fast CPU.

### FastCPU
As FastCPU is written in rust, it requires a more complicated process to install.

#### Desktop
If you have rust installed, you can simply run the following command in the /rust/ directory.
```sh
cargo build gravityengine
```
Then, if you export the Godot project for desktop, it will automatically include FastCPU.

#### Web  
The process for compiling FastCPU as wasm is much more complicated.

Follow the instructions from [the godot-rust book](https://godot-rust.github.io/book/toolchain/export-web.html) to install necessary tools, and emscripten. You do not need to modify `cargo.toml` or `config.toml`, this has been done already.
Make sure you have Godot added to your PATH, and then run the following command.

```sh
cargo +nightly build -Zbuild-std --target wasm32-unknown-emscripten
```

If everything goes well, this will produce a .wasm file which will allow Godot to include FastCPU in the web build. Make sure to select the "threaded" preset when exporting FastCPU, as this is required.
