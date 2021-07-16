// We define extern fns for most stuff, but cimport is useful for enums etc
pub usingnamespace @cImport({
    @cDefine("GLFW_INCLUDE_VULKAN", {});
    @cInclude("GLFW/glfw3.h");
});
