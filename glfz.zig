const std = @import("std");
const vk = @import("vulkan");
const c = @import("c.zig");
const err = @import("err.zig");

pub usingnamespace @import("types.zig");

//// Misc ////

pub fn init() !void {
    // This is a backcompat thing and we're a new library, so disable it unconditionally
    glfwInitHint(c.GLFW_JOYSTICK_HAT_BUTTONS, c.GLFW_FALSE);
    err.check();

    if (glfwInit() == 0) {
        return err.require(error{GlfwPlatformError});
    }
}
extern fn glfwInitHint(c_int, c_int) void;
extern fn glfwInit() c_int;

pub const deinit = glfwTerminate;
extern fn glfwTerminate() void;

pub fn swapInterval(interval: u31) void {
    glfwSwapInterval(interval);
    err.check();
}
extern fn glfwSwapInterval(c_int) void;

//// Input ////

pub fn pollEvents() void {
    glfwPollEvents();
    err.check();
}
pub fn waitEvents() void {
    glfwWaitEvents();
    err.check();
}

extern fn glfwPollEvents() void;
extern fn glfwWaitEvents() void;

//// Enums ////

pub const ClientApi = enum(c_int) {
    opengl = c.GLFW_OPENGL_API,
    opengl_es = c.GLFW_OPENGL_ES_API,
    none = c.GLFW_NO_API,
};
pub const ContextCreationApi = enum(c_int) {
    native = c.GLFW_NATIVE_CONTEXT_API,
    egl = c.GLFW_EGL_CONTEXT_API,
    osmesa = c.GLFW_OSMESA_CONTEXT_API,
};
pub const OpenglProfile = enum(c_int) {
    any = c.GLFW_OPENGL_ANY_PROFILE,
    compat = c.GLFW_OPENGL_COMPAT_PROFILE,
    core = c.GLFW_OPENGL_CORE_PROFILE,
};

//// Vulkan ////

pub fn vulkanSupported() bool {
    return glfwVulkanSupported() != c.GLFW_FALSE;
}
extern fn glfwVulkanSupported() c_int;

/// Vulkan must be supported.
pub fn getRequiredInstanceExtensions() [][*:0]const u8 {
    var count: u32 = undefined;
    const result = glfwGetRequiredInstanceExtensions(&count) orelse unreachable;
    return result[0..count];
}
extern fn glfwGetRequiredInstanceExtensions(*u32) ?[*][*:0]const u8;

pub const getInstanceProcAddress = glfwGetInstanceProcAddress;
extern fn glfwGetInstanceProcAddress(instance: vk.Instance, proc_name: [*:0]const u8) vk.PfnVoidFunction;

/// Vulkan must be supported.
/// The instance must have the required extensions enabled.
pub fn getPhysicalDevicePresentationSupport(instance: vk.Instance, device: vk.PhysicalDevice, queue_family: u32) !bool {
    const result = glfwGetPhysicalDevicePresentationSupport(instance, device, queue_family) != 0;
    if (!result) try err.get(error{GlfwPlatformError});
    return result;
}
extern fn glfwGetPhysicalDevicePresentationSupport(vk.Instance, vk.PhysicalDevice, u32) c_int;
