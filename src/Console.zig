const std = @import("std");
const JS = @import("JS.zig");

pub fn log(comptime format: []const u8, args: anytype) void {
    var buf: [512]u8 = undefined; // adjust size if needed
    const msg = std.fmt.bufPrint(&buf, format, args) catch return;
    JS.consoleLog(msg.ptr, msg.len);
}
