const std = @import("std");
const c = @import("c.zig");

const GlfwError = error{
    OutOfMemory,
    ApiUnavailable,
    VersionUnavailable,
    GlfwPlatformError,
    FormatUnavailable,
};

pub fn check() void {
    if (std.debug.runtime_safety) {
        get(GlfwError) catch unreachable;
    }
}
pub fn require(comptime ErrorType: type) ErrorType {
    try get(ErrorType);
    unreachable;
}

pub fn get(comptime ErrorType: type) ErrorType!void {
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
