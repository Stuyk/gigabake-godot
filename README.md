# GigaBake for Godot 4.3+

Bake your 3D CSG Scenes in a single click, and build occluders.

[![GigaBake Video](https://img.youtube.com/vi/YgN4bHHGhKA/0.jpg)](https://www.youtube.com/watch?v=YgN4bHHGhKA)

_The above is a video demo if you're confused by what this does._

## Install

Place `gigabake.gd` and `plugin.cfg` in your `addons/gigabake` folder of your game.

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

## Changelog

```
1.0.1

- Modified the Occluder creation to not require the node to be present
- Occluder is now saved and loaded from disk
```
