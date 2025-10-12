const std = @import("std");
const JS = @import("JS.zig");
const Console = @import("Console.zig");
const Vec3 = @import("Vec3.zig");
const Point3 = Vec3;
const Color = Vec3;
const Ray = @import("Ray.zig");

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

    const line_bytes = @as(usize, image_width) * 4;

    var line_buf = allocator.alloc(u8, line_bytes) catch {
        Console.log("Allocation failed for {} bytes", .{line_bytes});
        return;
    };

    defer allocator.free(line_buf);

    // Camera
    const focal_length: f64 = 1.0;
    const viewport_height: f64 = 2.0;
    const viewport_width: f64 = viewport_height * (@as(f64, @floatFromInt(image_width)) / @as(f64, @floatFromInt(image_height))); // 3.55555..54 for 16:9
    const camera_center = Point3.init(0.0, 0.0, 0.0);

    // Calculate the vectors across the horizontal and down the vertical viewport edges.
    const viewport_u = Vec3.init(viewport_width, 0.0, 0.0);
    const viewport_v = Vec3.init(0.0, -viewport_height, 0.0);

    // Calculate the horizontal and vertical delta vectors from pixel to pixel.
    const pixel_delta_u = viewport_u.divideByScalar(@as(f64, @floatFromInt(image_width)));
    const pixel_delta_v = viewport_v.divideByScalar(@as(f64, @floatFromInt(image_height)));

    // Calculate the location of the upper left pixel.
    const viewport_upper_left = camera_center
        .subtractVector(Vec3.init(0.0, 0.0, focal_length))
        .subtractVector(viewport_u.divideByScalar(2.0))
        .subtractVector(viewport_v.divideByScalar(2.0));

    const pixel00_loc = viewport_upper_left
        .addVector(pixel_delta_u.addVector(pixel_delta_v).multiplyByScalar(0.5));

    for (0..image_height) |j| {
        const line_slice = line_buf[0..line_bytes];
        // Iterate per pixel (not per byte) to avoid incorrect gradient & compile error.
        for (0..image_width) |i| {
            const pixel_center = pixel00_loc
                .addVector(pixel_delta_u.multiplyByScalar(@floatFromInt(i)))
                .addVector(pixel_delta_v.multiplyByScalar(@floatFromInt(j)));

            const ray_direction = pixel_center.subtractVector(camera_center);
            const r = Ray.init(camera_center, ray_direction);
            const pixel_color = rayColor(r).rgbBytes();

            const offset = i * 4;
            line_slice[offset + 0] = pixel_color[0];
            line_slice[offset + 1] = pixel_color[1];
            line_slice[offset + 2] = pixel_color[2];
            line_slice[offset + 3] = 255;
        }
        JS.renderLine(j, line_slice.ptr, line_slice.len);
    }
}

fn hitSphere(center: Vec3, radius: f64, r: Ray) f64 {
    const oc = center.subtractVector(r.orig);
    const a = r.dir.lengthSquared();
    const h = Vec3.dot(r.dir, oc);
    const c = oc.lengthSquared() - radius * radius;
    const discriminant = h * h - a * c;

    if (discriminant < 0) {
        return -1.0;
    } else {
        return (h - std.math.sqrt(discriminant)) / a;
    }
}

fn rayColor(r: Ray) Color {
    const t = hitSphere(Point3.init(0.0, 0.0, -1.0), 0.5, r);
    if (t > 0.0) {
        const N = Vec3.unitVector(r.at(t).subtractVector(Vec3.init(0.0, 0.0, -1.0)));
        return Color.init(N.x() + 1.0, N.y() + 1.0, N.z() + 1.0).multiplyByScalar(0.5);
    }

    const unit_direction = Vec3.unitVector(r.dir);
    const a = 0.5 * (unit_direction.y() + 1.0);
    return Color.init(1.0, 1.0, 1.0).multiplyByScalar(1.0 - a).addVector(Color.init(0.5, 0.7, 1.0).multiplyByScalar(a));
}
