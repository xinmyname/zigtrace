const Vec3 = @import("Vec3.zig");
const Point3 = @import("Vec3.zig");

const Ray = @This();

orig: Point3 = undefined,
dir: Vec3 = undefined,

pub fn init(origin: Point3, direction: Vec3) Ray {
    return Ray{
        .orig = origin,
        .dir = direction,
    };
}

pub fn at(self: Ray, t: f64) Point3 {
    return self.orig.addVector(self.dir.multiplyByScalar(t));
}

test "at" {
    const std = @import("std");
    var r = Ray.init(
        Point3.init(2.0, 3.0, 4.0),
        Vec3.init(1.0, 0.0, 0.0),
    );
    const p = r.at(2.5);
    try std.testing.expect(p.e[0] == 4.5);
    try std.testing.expect(p.e[1] == 3.0);
    try std.testing.expect(p.e[2] == 4.0);
}
