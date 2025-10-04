const std = @import("std");

const Imports = struct {
    extern fn consoleLog(ptr: [*]const u8, len: usize) void;
    extern fn renderLine(line: u32, ptr: [*]const u8, len: usize) void;
};

pub const Console = struct {
    pub fn log(comptime format: []const u8, args: anytype) void {
        var buf: [512]u8 = undefined; // adjust size if needed
        const msg = std.fmt.bufPrint(&buf, format, args) catch return;
        Imports.consoleLog(msg.ptr, msg.len);
    }
};

export fn render(width: u32, height: u32) void {
    Console.log("Rendering {} x {} ...", .{ width, height });

    // TODO: This needs to be dynamically allocated
    var line_buf: [400 * 4]u8 = undefined;

    for (0..height) |line| {
        const line_slice = line_buf[0 .. width * 4]; // assuming RGBA

        // Iterate per pixel (not per byte) to avoid incorrect gradient & compile error.
        for (0..width) |x| {
            const offset = x * 4;
            const r: u8 = @intCast(if (width > 1) (x * 255) / (width - 1) else 0);
            const g: u8 = @intCast(if (height > 1) (line * 255) / (height - 1) else 0);
            const b: u8 = 128;
            line_slice[offset + 0] = r;
            line_slice[offset + 1] = g;
            line_slice[offset + 2] = b;
            line_slice[offset + 3] = 255; // alpha
        }

        Imports.renderLine(line, line_slice.ptr, line_slice.len);
    }
}
