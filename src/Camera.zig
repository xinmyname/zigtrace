const std = @import("std");

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

const Camera = @This();

image_width: u32, // Rendered image width
image_height: u32, // Rendered image height

center: Point3, // Camera center
pixel_delta_u: Vec3, // Offset to pixel to the right
pixel_delta_v: Vec3, // Offset to pixel below
pixel00_loc: Point3, // Location of pixel 0, 0

pub fn init(image_width: u32, image_height: u32) Camera {
    const center = Point3.init(0.0, 0.0, 0.0);

    // Determine viewport dimensions.
    const focal_length: f64 = 1.0;
    const viewport_height: f64 = 2.0;
    const viewport_width: f64 = viewport_height * (@as(f64, @floatFromInt(image_width)) / @as(f64, @floatFromInt(image_height)));

    // Calculate the vectors across the horizontal and down the vertical viewport edges.
    const viewport_u = Vec3.init(viewport_width, 0.0, 0.0);
    const viewport_v = Vec3.init(0.0, -viewport_height, 0.0);

    // Calculate the horizontal and vertical delta vectors from pixel to pixel.
    const pixel_delta_u = viewport_u.divideByScalar(@as(f64, @floatFromInt(image_width)));
    const pixel_delta_v = viewport_v.divideByScalar(@as(f64, @floatFromInt(image_height)));

    // Calculate the location of the upper left pixel.
    const viewport_upper_left = center
        .subtractVector(Vec3.init(0.0, 0.0, focal_length))
        .subtractVector(viewport_u.divideByScalar(2.0))
        .subtractVector(viewport_v.divideByScalar(2.0));

    return Camera{
        .image_width = image_width,
        .image_height = image_height,
        .center = center,
        .pixel_delta_u = pixel_delta_u,
        .pixel_delta_v = pixel_delta_v,
        .pixel00_loc = viewport_upper_left.addVector(pixel_delta_u.addVector(pixel_delta_v).multiplyByScalar(0.5)),
    };
}

pub fn render(self: Camera, allocator: std.mem.Allocator, world: *const ObjectList) void {
    const line_bytes = @as(usize, self.image_width) * 4;

    var line_buf = allocator.alloc(u8, line_bytes) catch {
        Console.log("Allocation failed for {} bytes", .{line_bytes});
        return;
    };

    defer allocator.free(line_buf);

    for (0..self.image_height) |j| {
        const line_slice = line_buf[0..line_bytes];
        // Iterate per pixel (not per byte) to avoid incorrect gradient & compile error.
        for (0..self.image_width) |i| {
            const pixel_center = self.pixel00_loc
                .addVector(self.pixel_delta_u.multiplyByScalar(@floatFromInt(i)))
                .addVector(self.pixel_delta_v.multiplyByScalar(@floatFromInt(j)));

            const ray_direction = pixel_center.subtractVector(self.center);
            const r = Ray.init(self.center, ray_direction);
            const pixel_color = rayColor(r, world).rgbBytes();

            const offset = i * 4;
            line_slice[offset + 0] = pixel_color[0];
            line_slice[offset + 1] = pixel_color[1];
            line_slice[offset + 2] = pixel_color[2];
            line_slice[offset + 3] = 255;
        }
        JS.renderLine(j, line_slice.ptr, line_slice.len);
    }
}

fn rayColor(r: Ray, world: *const ObjectList) Color {
    var rec: HitRecord = undefined;

    if (world.hit(r, Interval.init(0, std.math.inf(f64)), &rec)) {
        return rec.normal.addVector(Color.init(1, 1, 1)).multiplyByScalar(0.5);
    }

    const unit_direction = Vec3.unitVector(r.dir);
    const a = 0.5 * (unit_direction.y() + 1.0);
    return Color.init(1.0, 1.0, 1.0).multiplyByScalar(1.0 - a).addVector(Color.init(0.5, 0.7, 1.0).multiplyByScalar(a));
}
