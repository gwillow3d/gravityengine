# Gravity Engine
Gravity Engine is a gravity simulator written in Godot.

## Samples
#### Cluster Orbits
![Solar System](https://github.com/gwillow3d/gravityengine/blob/master/examples/2026-08-26T23%3A39%3A45.png)
#### Black Hole
![Black Hole](https://github.com/gwillow3d/gravityengine/blob/master/examples/2026-08-26T20%3A22%3A35.png)
#### Protoplanetary Disk
![Protoplanetary Disk](https://github.com/gwillow3d/gravityengine/blob/master/examples/2026-08-26T20%3A24%3A42.png)

## How does it work?
Gravity Engine uses the basic approach of calculating the force every particle exerts on every other particle.
This is typically extremely computationally expensive, however these calculations are run on the GPU using a compute shader to achieve reasonable speeds.

A web version is not currently possible as Godot's compute shaders cannot be run on the web, but I plan to implement the Barnes-Hut algorithm to run the engine on the CPU, and it may outperform the current GPU system as well.
