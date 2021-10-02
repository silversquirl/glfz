const std = @import("std");
const vk = @import("vulkan");
const c = @import("c.zig");
const err = @import("err.zig");
const glfw = @import("glfz.zig");

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

        return glfwCreateWindow(width, height, title.ptr, config.monitor, config.share) orelse err.require(InitError);
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
        accum_red_bits: ?u31 = 0,
        accum_green_bits: ?u31 = 0,
        accum_blue_bits: ?u31 = 0,

        aux_buffers: ?u31 = 0,
        samples: ?u31 = 0,
        refresh_rate: ?u31 = null,
        stereo: bool = false,
        srgb_capable: bool = false,
        doublebuffer: bool = true,

        client_api: glfw.ClientApi = .opengl,
        context_creation_api: glfw.ContextCreationApi = .native,
        context_version_major: u8 = 1,
        context_version_minor: u8 = 0,

        opengl_forward_compat: bool = false,
        opengl_debug_context: bool = false,
        opengl_profile: glfw.OpenglProfile = .any,
    };

    pub const deinit = glfwDestroyWindow;
    extern fn glfwDestroyWindow(*Window) void;

    pub fn windowSize(self: *Window) [2]u31 {
        var x: c_int = undefined;
        var y: c_int = undefined;
        glfwGetWindowSize(self, &x, &y);
        err.check();
        return .{ @intCast(u31, x), @intCast(u31, y) };
    }
    extern fn glfwGetWindowSize(*Window, ?*c_int, ?*c_int) void;

    pub fn framebufferSize(self: *Window) [2]u31 {
        var x: c_int = undefined;
        var y: c_int = undefined;
        glfwGetFramebufferSize(self, &x, &y);
        err.check();
        return .{ @intCast(u31, x), @intCast(u31, y) };
    }
    extern fn glfwGetFramebufferSize(*Window, ?*c_int, ?*c_int) void;

    pub fn makeContextCurrent(self: *Window) void {
        glfwMakeContextCurrent(self);
        err.check();
    }
    extern fn glfwMakeContextCurrent(*Window) void;

    pub fn shouldClose(self: *Window) bool {
        const res = glfwWindowShouldClose(self);
        err.check();
        return res != 0;
    }
    extern fn glfwWindowShouldClose(*Window) c_int;

    pub fn setShouldClose(self: *Window, value: bool) void {
        glfwSetWindowShouldClose(self, @boolToInt(value));
        err.check();
    }
    extern fn glfwSetWindowShouldClose(*Window, c_int) void;

    pub fn swapBuffers(self: *Window) void {
        glfwSwapBuffers(self);
        err.check();
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

    //// Input ////
    pub fn getKey(self: *Window, key: glfw.Key) bool {
        const state = glfwGetKey(self, key);
        err.check();
        return state == .press;
    }
    extern fn glfwGetKey(*Window, glfw.Key) glfw.KeyAction;

    //// Callbacks ////
    pub const setWindowSizeCallback = glfwSetWindowSizeCallback;
    extern fn glfwSetWindowSizeCallback(self: *Window, callback: WindowSizeFn) WindowSizeFn;
    pub const WindowSizeFn = fn (*Window, c_int, c_int) callconv(.C) void;

    pub const setFramebufferSizeCallback = glfwSetFramebufferSizeCallback;
    extern fn glfwSetFramebufferSizeCallback(self: *Window, callback: FramebufferSizeFn) FramebufferSizeFn;
    pub const FramebufferSizeFn = fn (*Window, c_int, c_int) callconv(.C) void;

    //// Vulkan ////
    /// Vulkan must be supported.
    /// The instance must have the required extensions enabled.
    /// The window must have been created with client_api = .none.
    pub fn createSurface(self: *Window, instance: vk.Instance, allocator: *const vk.AllocationCallbacks) vk.SurfaceKHR {
        var surface: vk.SurfaceKHR = undefined;
        switch (glfwCreateWindowSurface(instance, self, allocator, &surface)) {
            .success => {},
            .error_initialization_failed => unreachable, // Vulkan is not supported
            .error_extension_not_present => unreachable, // Instance did not have required extensions
            .error_native_window_in_use_khr => unreachable, // Window created with client_api != .none
            else => unreachable,
        }
        return surface;
    }
    extern fn glfwCreateWindowSurface(vk.Instance, *Window, *const vk.AllocationCallbacks, *vk.SurfaceKHR) vk.Result;

    //// Native access ////
    pub const getX11Window = glfwGetX11Window;
    extern fn glfwGetX11Window(*Window) u32;

    pub fn getWaylandWindow(self: *Window, comptime WindowType: type) ?*WindowType {
        return @ptrCast(?*WindowType, glfwGetWaylandWindow(self));
    }
    extern fn glfwGetWaylandWindow(*Window) ?*opaque {};
};

pub const Monitor = opaque {
    // TODO
};
