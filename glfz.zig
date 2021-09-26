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

pub const Key = enum(c_int) {
    unknown = c.GLFW_KEY_UNKNOWN,
    space = c.GLFW_KEY_SPACE,
    apostrophe = c.GLFW_KEY_APOSTROPHE,
    comma = c.GLFW_KEY_COMMA,
    minus = c.GLFW_KEY_MINUS,
    period = c.GLFW_KEY_PERIOD,
    slash = c.GLFW_KEY_SLASH,
    @"0" = c.GLFW_KEY_0,
    @"1" = c.GLFW_KEY_1,
    @"2" = c.GLFW_KEY_2,
    @"3" = c.GLFW_KEY_3,
    @"4" = c.GLFW_KEY_4,
    @"5" = c.GLFW_KEY_5,
    @"6" = c.GLFW_KEY_6,
    @"7" = c.GLFW_KEY_7,
    @"8" = c.GLFW_KEY_8,
    @"9" = c.GLFW_KEY_9,
    semicolon = c.GLFW_KEY_SEMICOLON,
    equal = c.GLFW_KEY_EQUAL,
    a = c.GLFW_KEY_A,
    b = c.GLFW_KEY_B,
    c = c.GLFW_KEY_C,
    d = c.GLFW_KEY_D,
    e = c.GLFW_KEY_E,
    f = c.GLFW_KEY_F,
    g = c.GLFW_KEY_G,
    h = c.GLFW_KEY_H,
    i = c.GLFW_KEY_I,
    j = c.GLFW_KEY_J,
    k = c.GLFW_KEY_K,
    l = c.GLFW_KEY_L,
    m = c.GLFW_KEY_M,
    n = c.GLFW_KEY_N,
    o = c.GLFW_KEY_O,
    p = c.GLFW_KEY_P,
    q = c.GLFW_KEY_Q,
    r = c.GLFW_KEY_R,
    s = c.GLFW_KEY_S,
    t = c.GLFW_KEY_T,
    u = c.GLFW_KEY_U,
    v = c.GLFW_KEY_V,
    w = c.GLFW_KEY_W,
    x = c.GLFW_KEY_X,
    y = c.GLFW_KEY_Y,
    z = c.GLFW_KEY_Z,
    left_bracket = c.GLFW_KEY_LEFT_BRACKET,
    backslash = c.GLFW_KEY_BACKSLASH,
    right_bracket = c.GLFW_KEY_RIGHT_BRACKET,
    grave_accent = c.GLFW_KEY_GRAVE_ACCENT,
    world_1 = c.GLFW_KEY_WORLD_1,
    world_2 = c.GLFW_KEY_WORLD_2,
    escape = c.GLFW_KEY_ESCAPE,
    enter = c.GLFW_KEY_ENTER,
    tab = c.GLFW_KEY_TAB,
    backspace = c.GLFW_KEY_BACKSPACE,
    insert = c.GLFW_KEY_INSERT,
    delete = c.GLFW_KEY_DELETE,
    right = c.GLFW_KEY_RIGHT,
    left = c.GLFW_KEY_LEFT,
    down = c.GLFW_KEY_DOWN,
    up = c.GLFW_KEY_UP,
    page_up = c.GLFW_KEY_PAGE_UP,
    page_down = c.GLFW_KEY_PAGE_DOWN,
    home = c.GLFW_KEY_HOME,
    end = c.GLFW_KEY_END,
    caps_lock = c.GLFW_KEY_CAPS_LOCK,
    scroll_lock = c.GLFW_KEY_SCROLL_LOCK,
    num_lock = c.GLFW_KEY_NUM_LOCK,
    print_screen = c.GLFW_KEY_PRINT_SCREEN,
    pause = c.GLFW_KEY_PAUSE,
    f1 = c.GLFW_KEY_F1,
    f2 = c.GLFW_KEY_F2,
    f3 = c.GLFW_KEY_F3,
    f4 = c.GLFW_KEY_F4,
    f5 = c.GLFW_KEY_F5,
    f6 = c.GLFW_KEY_F6,
    f7 = c.GLFW_KEY_F7,
    f8 = c.GLFW_KEY_F8,
    f9 = c.GLFW_KEY_F9,
    f10 = c.GLFW_KEY_F10,
    f11 = c.GLFW_KEY_F11,
    f12 = c.GLFW_KEY_F12,
    f13 = c.GLFW_KEY_F13,
    f14 = c.GLFW_KEY_F14,
    f15 = c.GLFW_KEY_F15,
    f16 = c.GLFW_KEY_F16,
    f17 = c.GLFW_KEY_F17,
    f18 = c.GLFW_KEY_F18,
    f19 = c.GLFW_KEY_F19,
    f20 = c.GLFW_KEY_F20,
    f21 = c.GLFW_KEY_F21,
    f22 = c.GLFW_KEY_F22,
    f23 = c.GLFW_KEY_F23,
    f24 = c.GLFW_KEY_F24,
    f25 = c.GLFW_KEY_F25,
    kp_0 = c.GLFW_KEY_KP_0,
    kp_1 = c.GLFW_KEY_KP_1,
    kp_2 = c.GLFW_KEY_KP_2,
    kp_3 = c.GLFW_KEY_KP_3,
    kp_4 = c.GLFW_KEY_KP_4,
    kp_5 = c.GLFW_KEY_KP_5,
    kp_6 = c.GLFW_KEY_KP_6,
    kp_7 = c.GLFW_KEY_KP_7,
    kp_8 = c.GLFW_KEY_KP_8,
    kp_9 = c.GLFW_KEY_KP_9,
    kp_decimal = c.GLFW_KEY_KP_DECIMAL,
    kp_divide = c.GLFW_KEY_KP_DIVIDE,
    kp_multiply = c.GLFW_KEY_KP_MULTIPLY,
    kp_subtract = c.GLFW_KEY_KP_SUBTRACT,
    kp_add = c.GLFW_KEY_KP_ADD,
    kp_enter = c.GLFW_KEY_KP_ENTER,
    kp_equal = c.GLFW_KEY_KP_EQUAL,
    left_shift = c.GLFW_KEY_LEFT_SHIFT,
    left_control = c.GLFW_KEY_LEFT_CONTROL,
    left_alt = c.GLFW_KEY_LEFT_ALT,
    left_super = c.GLFW_KEY_LEFT_SUPER,
    right_shift = c.GLFW_KEY_RIGHT_SHIFT,
    right_control = c.GLFW_KEY_RIGHT_CONTROL,
    right_alt = c.GLFW_KEY_RIGHT_ALT,
    right_super = c.GLFW_KEY_RIGHT_SUPER,
    menu = c.GLFW_KEY_MENU,
};
pub const KeyAction = enum(c_int) {
    press = c.GLFW_PRESS,
    release = c.GLFW_RELEASE,
    repeat = c.GLFW_REPEAT,
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

//// Native access ////

pub fn getX11Display(comptime DisplayType: type) ?*DisplayType {
    return @ptrCast(?*DisplayType, glfwGetX11Display());
}
extern fn glfwGetX11Display() ?*opaque {};

pub fn getWaylandDisplay(comptime DisplayType: type) ?*DisplayType {
    return @ptrCast(?*DisplayType, glfwGetWaylandDisplay());
}
extern fn glfwGetWaylandDisplay() ?*opaque {};
