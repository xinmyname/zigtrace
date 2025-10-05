const std = @import("std");
const JS = @import("JS.zig");
const Console = @import("Console.zig");
const Vec3 = @import("Vec3.zig");

pub const allocator = std.heap.wasm_allocator;

extern var __heap_base: u8;

pub export fn wasm_debug_info() void {
    const heap_base = @intFromPtr(&__heap_base);
    const pages = @wasmMemorySize(0); // current imported pages
    const total = pages * 65536;
    const free_bytes = if (total > heap_base) total - heap_base else 0;
    Console.log("pages={} total={} heap_base={} free={}", .{ pages, total, heap_base, free_bytes });
}

export fn render(width: u32, height: u32) void {
    Console.log("Rendering {} x {} ...", .{ width, height });

    const line_bytes = @as(usize, width) * 4;

    var line_buf = allocator.alloc(u8, line_bytes) catch {
        Console.log("Allocation failed for {} bytes", .{line_bytes});
        return;
    };

    defer allocator.free(line_buf);

    for (0..height) |line| {
        const line_slice = line_buf[0..line_bytes];
        // Iterate per pixel (not per byte) to avoid incorrect gradient & compile error.
        for (0..width) |x| {
            const offset = x * 4;
            const r: u8 = @intCast(if (width > 1) (x * 255) / (width - 1) else 0);
            const g: u8 = @intCast(if (height > 1) (line * 255) / (height - 1) else 0);
            const b: u8 = 128;
            line_slice[offset + 0] = r;
            line_slice[offset + 1] = g;
            line_slice[offset + 2] = b;
            line_slice[offset + 3] = 255;
        }
        JS.renderLine(line, line_slice.ptr, line_slice.len);
    }
}
