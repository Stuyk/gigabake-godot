# GigaBake for Godot 4.3+

Bake your 3D CSG Scenes in a single click, and build occluders.

[![GigaBake Video](https://img.youtube.com/vi/YgN4bHHGhKA/0.jpg)](https://www.youtube.com/watch?v=YgN4bHHGhKA)

## Install

Places the folders in `addons` folder into your `addons` folder in your project.

Enable the plugin through your Project Settings.

## Usage

Open any 3D scene, and look for the `GigaBake` button.

Your game scene should be setup as follows:

```sh
Node3D
- OccluderInstance3D
- CSGCombiner3D
--- Everything Else CSG Related
```