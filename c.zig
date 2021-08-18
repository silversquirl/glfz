// We define extern fns for most stuff, but cimport is useful for enums etc
pub usingnamespace @cImport({
    @cInclude("GLFW/glfw3.h");
});
