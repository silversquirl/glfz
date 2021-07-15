const std = @import("std");

// We define extern fns for most stuff, but cimport is useful for enums etc
const c = @cImport({
    @cInclude("GLFW/glfw3.h");
});

//// Misc ////

pub fn init() !void {
    // This is a backcompat thing and we're a new library, so disable it unconditionally
    glfwInitHint(c.GLFW_JOYSTICK_HAT_BUTTONS, c.GLFW_FALSE);
    checkError();

    if (glfwInit() == 0) {
        return requireError(error{GlfwPlatformError});
    }
}
extern fn glfwInitHint(c_int, c_int) void;
extern fn glfwInit() c_int;

pub fn swapInterval(interval: u31) void {
    glfwSwapInterval(interval);
    checkError();
}
extern fn glfwSwapInterval(c_int) void;

//// Window ////

pub const Window = opaque {
    pub const InitError = error{
        OutOfMemory,
        ApiUnavailable,
        VersionUnavailable,
        FormatUnavailable,
        GlfwPlatformError,
    };

    pub fn init(width: u16, height: u16, title: [:0]const u8, config: Config) InitError!*Window {
        glfwDefaultWindowHints();

        // Skip the first two 'cause they're monitor and share
        @setEvalBranchQuota(2000);
        inline for (std.meta.fields(Config)[2..]) |hint| {
            // Check if the value is different from the default
            const value = @field(config, hint.name);
            if (!std.meta.eql(value, hint.default_value.?)) {
                // Get the hint id
                const hint_name = comptime blk: {
                    var hint_name = ("GLFW_" ++ hint.name).*;
                    break :blk std.ascii.upperString(&hint_name, &hint_name);
                };
                const hinti = @field(c, hint_name);

                // Convert the value to an i32
                const valuei: i32 = switch (@typeInfo(hint.field_type)) {
                    .Bool => @boolToInt(value),
                    .Enum => @enumToInt(value),
                    .Optional => value orelse c.GLFW_DONT_CARE,
                    .Int => value,
                    else => unreachable,
                };

                // Set the hint
                glfwWindowHint(hinti, valuei);
            }
        }

        return glfwCreateWindow(width, height, title.ptr, config.monitor, config.share) orelse requireError(InitError);
    }
    extern fn glfwDefaultWindowHints() void;
    extern fn glfwWindowHint(c_int, c_int) void;
    extern fn glfwCreateWindow(c_int, c_int, [*:0]const u8, ?*Monitor, ?*Window) ?*Window;

    pub const Config = struct {
        monitor: ?*Monitor = null,
        share: ?*Window = null,

        resizable: bool = true,
        visible: bool = true,
        decorated: bool = true,
        focused: bool = true,
        auto_iconify: bool = true,
        floating: bool = false,
        maximized: bool = false,
        center_cursor: bool = true,
        transparent_framebuffer: bool = false,
        focus_on_show: bool = true,
        scale_to_monitor: bool = false,

        red_bits: ?u31 = 8,
        green_bits: ?u31 = 8,
        blue_bits: ?u31 = 8,
        alpha_bits: ?u31 = 8,
        depth_bits: ?u31 = 24,
        stencil_bits: ?u31 = 8,

        client_api: ClientApi = .opengl,
        context_creation_api: ContextCreationApi = .native,
        context_version_major: u8 = 1,
        context_version_minor: u8 = 0,

        opengl_forward_compat: bool = false,
        opengl_debug_context: bool = false,
        opengl_profile: OpenglProfile = .any,
    };

    pub const deinit = glfwDestroyWindow;
    extern fn glfwDestroyWindow(*Window) void;

    pub fn windowSize(self: *Window) [2]u31 {
        var x: c_int = undefined;
        var y: c_int = undefined;
        glfwGetWindowSize(self, &x, &y);
        checkError();
        return .{ @intCast(u31, x), @intCast(u31, y) };
    }
    extern fn glfwGetWindowSize(*Window, ?*c_int, ?*c_int) void;

    pub fn framebufferSize(self: *Window) [2]u31 {
        var x: c_int = undefined;
        var y: c_int = undefined;
        glfwGetFramebufferSize(self, &x, &y);
        checkError();
        return .{ @intCast(u31, x), @intCast(u31, y) };
    }
    extern fn glfwGetFramebufferSize(*Window, ?*c_int, ?*c_int) void;

    pub fn makeContextCurrent(self: *Window) void {
        glfwMakeContextCurrent(self);
        checkError();
    }
    extern fn glfwMakeContextCurrent(*Window) void;

    pub fn shouldClose(self: *Window) bool {
        const res = glfwWindowShouldClose(self);
        checkError();
        return res != 0;
    }
    extern fn glfwWindowShouldClose(*Window) c_int;

    pub fn swapBuffers(self: *Window) void {
        glfwSwapBuffers(self);
        checkError();
    }
    extern fn glfwSwapBuffers(*Window) void;

    pub fn setUserPointer(self: *Window, ptr: anytype) void {
        glfwSetWindowUserPointer(self, @ptrCast(*c_void, ptr));
    }
    pub fn getUserPointer(self: *Window, comptime T: type) T {
        const ptr = glfwGetWindowUserPointer(self);
        return @ptrCast(T, @alignCast(std.meta.alignment(T), ptr));
    }
    extern fn glfwSetWindowUserPointer(*Window, *c_void) void;
    extern fn glfwGetWindowUserPointer(*Window) *c_void;

    //// Callbacks ////
    pub const setWindowSizeCallback = glfwSetWindowSizeCallback;
    extern fn glfwSetWindowSizeCallback(self: *Window, callback: WindowSizeFn) WindowSizeFn;
    pub const WindowSizeFn = fn (*Window, c_int, c_int) callconv(.C) void;

    pub const setFramebufferSizeCallback = glfwSetFramebufferSizeCallback;
    extern fn glfwSetFramebufferSizeCallback(self: *Window, callback: FramebufferSizeFn) FramebufferSizeFn;
    pub const FramebufferSizeFn = fn (*Window, c_int, c_int) callconv(.C) void;
};

pub const Monitor = opaque {
    // TODO
};

//// Input ////

pub fn pollEvents() void {
    glfwPollEvents();
    checkError();
}
pub fn waitEvents() void {
    glfwWaitEvents();
    checkError();
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

//// Error handling ////

const GlfwError = error{
    OutOfMemory,
    ApiUnavailable,
    VersionUnavailable,
    GlfwPlatformError,
    FormatUnavailable,
};
fn checkError() void {
    if (std.debug.runtime_safety) {
        getError(GlfwError) catch unreachable;
    }
}
fn requireError(comptime ErrorType: type) ErrorType {
    try getError(ErrorType);
    unreachable;
}
fn getError(comptime ErrorType: type) ErrorType!void {
    const err: GlfwError = switch (glfwGetError(null)) {
        c.GLFW_NO_ERROR => return,

        c.GLFW_OUT_OF_MEMORY => error.OutOfMemory,
        c.GLFW_API_UNAVAILABLE => error.ApiUnavailable,
        c.GLFW_VERSION_UNAVAILABLE => error.VersionUnavailable,
        c.GLFW_PLATFORM_ERROR => error.GlfwPlatformError,
        c.GLFW_FORMAT_UNAVAILABLE => error.FormatUnavailable,

        // Programmer errors
        c.GLFW_NOT_INITIALIZED => unreachable,
        c.GLFW_NO_CURRENT_CONTEXT => unreachable,
        c.GLFW_INVALID_ENUM => unreachable,
        c.GLFW_INVALID_VALUE => unreachable,
        c.GLFW_NO_WINDOW_CONTEXT => unreachable,

        else => unreachable, // Unknown error code;
    };
    inline for (@typeInfo(ErrorType).ErrorSet.?) |serr| {
        if (@field(GlfwError, serr.name) == err) {
            return @field(ErrorType, serr.name);
        }
    }
    unreachable;
}
extern fn glfwGetError(?*[*:0]const u8) c_int;
