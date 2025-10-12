const std = @import("std");
const Vec3 = @import("Vec3.zig");
const Point3 = Vec3;
const Ray = @import("Ray.zig");
const HitRecord = @import("HitRecord.zig");

const Sphere = @This();

center: Point3 = undefined,
radius: f64 = undefined,

pub fn init(center: Point3, radius: f64) Sphere {
    return Sphere{
        .center = center,
        .radius = @max(0.0, radius),
    };
}

pub fn hit(self: Sphere, r: Ray, ray_tmin: f64, ray_tmax: f64, rec: *HitRecord) bool {
    const oc = self.center.subtractVector(r.orig);
    const a = r.dir.lengthSquared();
    const h = Vec3.dot(r.dir, oc);
    const c = oc.lengthSquared() - self.radius * self.radius;
    const discriminant = h * h - a * c;

    if (discriminant < 0)
        return false;

    const sqrt_d = std.math.sqrt(discriminant);
    var root = (h - sqrt_d) / a;

    if (root <= ray_tmin or ray_tmax <= root) {
        root = (h + sqrt_d) / a;
        if (root <= ray_tmin or ray_tmax <= root)
            return false;
    }

    rec.t = root;
    rec.p = r.at(rec.t);
    rec.normal = (rec.p.subtractVector(self.center)).divideByScalar(self.radius);
    return true;
}

test "ray hits sphere" {
    const s = Sphere.init(Point3.init(0.0, 0.0, -1.0), 0.5);
    const r = Ray.init(Point3.init(0.0, 0.0, 0.0), Vec3.init(0.0, 0.0, -1.0));
    var rec: HitRecord = undefined;

    const did_hit = s.hit(r, 0.0, 100.0, &rec);
    try std.testing.expect(did_hit);
    try std.testing.expect(rec.t == 0.5); // The ray has travelled 0.5 units to hit the sphere.
    try std.testing.expect(rec.p.e[0] == 0.0);
    try std.testing.expect(rec.p.e[1] == 0.0);
    try std.testing.expect(rec.p.e[2] == -0.5); // The hit point is at z=-0.5
    try std.testing.expect(rec.normal.e[0] == 0.0);
    try std.testing.expect(rec.normal.e[1] == 0.0);
    try std.testing.expect(rec.normal.e[2] == 1.0); // The normal is reflected back toward the ray origin.
}

test "ray misses sphere" {
    const s = Sphere.init(Point3.init(0.0, 0.0, -1.0), 0.5);
    const r = Ray.init(Point3.init(0.0, 0.0, 0.0), Vec3.init(0.0, 0.0, 1.0));
    var rec: HitRecord = undefined;

    const did_hit = s.hit(r, 0.0, 100.0, &rec);
    try std.testing.expect(!did_hit);
}
