# GLFZ

A friendly GLFW wrapper for Zig, based on the same approach as [zgl]: incrementally
developed, with an object-oriented API. Functions and types are added on-demand,
allowing better quality control and ensuring everything is properly tested.

[zgl]: https://github.com/ziglibs/zgl

## Vulkan support

GLFZ supports Vulkan, through [vulkan-zig]. To enable this support, you must expose
vulkan-zig's bindings to GLFZ as a package with the name `"vulkan"`.

[vulkan-zig]: https://github.com/Snektron/vulkan-zig
