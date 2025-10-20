const std = @import("std");

const Camera = @import("Camera.zig");
const Console = @import("Console.zig");
const HitRecord = @import("HitRecord.zig");
const Interval = @import("Interval.zig");
const JS = @import("JS.zig");
const Objects = @import("Objects.zig");
const Ray = @import("Ray.zig");
const Vec3 = @import("Vec3.zig");

const Color = Vec3;
const Object = Objects.Object;
const ObjectList = Objects.ObjectList;
const Point3 = Vec3;

pub const allocator = std.heap.wasm_allocator;

extern var __heap_base: u8;

pub export fn wasm_debug_info() void {
    const heap_base = @intFromPtr(&__heap_base);
    const pages = @wasmMemorySize(0); // current imported pages
    const total = pages * 65536;
    const free_bytes = if (total > heap_base) total - heap_base else 0;
    Console.log("pages={} total={} heap_base={} free={}", .{ pages, total, heap_base, free_bytes });
}

export fn render(image_width: u32, image_height: u32) void {
    Console.log("Rendering {} x {}", .{ image_width, image_height });

    // World
    var world = ObjectList{};
    defer world.deinit(allocator);

    const sphere1 = Object.sphere(Point3.init(0.0, 0.0, -1.0), 0.5);
    const sphere2 = Object.sphere(Point3.init(0.0, -100.5, -1.0), 100.0);

    world.append(allocator, sphere1) catch |err| {
        Console.log("Failed to append sphere1: {}", .{err});
        return;
    };

    world.append(allocator, sphere2) catch |err| {
        Console.log("Failed to append sphere2: {}", .{err});
        return;
    };

    var cam = Camera.init(image_width, image_height);
    cam.render(allocator, &world);
}
