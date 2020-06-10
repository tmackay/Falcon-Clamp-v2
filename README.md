# Falcon-Clamp-v2

https://www.thingiverse.com/thing:4436194

Falcon Clamp V2 - not so much an improvement but an alternate version using gear cutting techniques from: [Parkinbot](https://www.thingiverse.com/Parkinbot)

Using Rudolf Huttary's gear cutting technique opens up some new gear combinations with support for profile shift and single toothed gears. The tooth profile for a gear cut by another gear is also noticeably different from that cut by a straight rack.

This technique saves quite a bit of mathematical legwork but has some disadvantages. Compilation time and memory usage dramatically increases and it is prone to crashing. To work around this, generate gears individually (using the g parameter) and combine using MeshLab (Flatten Visible Layers). The produced meshes also have excessively high number of small triangles and discretization artifacts, apply simplification (Quadratic Edge Collapse Decimation) while you're at it.

If there's one thing on my OpenSCAD wish list it is a 2D simplification function (or even access to generated point arrays). The effect could be achieved by exporting 2D intermediate 2D geometry, simplifying with eg. InkScape and re-importing for extrusion. While this is a highly manual process, I think all these steps could be scripted.

This example is about as small as I can get it for demonstration purposes. I think the next thing to try is a vertically elongated version with alternating layers like a door hinge. At constant clamping pressure the force will increase linearly with height along the full length of the clamp. This way something like a sheet metal bender/seamer/hem tool could be made.
