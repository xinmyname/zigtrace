const Vec3 = @import("Vec3.zig");
const Point3 = Vec3;
const Ray = @import("Ray.zig");
const HitRecord = @import("HitRecord.zig");

pub fn hit(hittable: anytype, r: Ray, ray_tmin: f64, ray_tmax: f64, rec: *HitRecord) bool {
    return hittable.hit(r, ray_tmin, ray_tmax, rec);
}

test "didHit" {
    const std = @import("std");

    const AlwaysHits = struct {
        pub fn hit(_: @This(), _: Ray, _: f64, _: f64, rec: *HitRecord) bool {
            rec.* = HitRecord.init(Point3.init(0, 0, 1), Vec3.init(0, 0, -1), 1.0);
            return true;
        }
    };

    const always_hits = AlwaysHits{};
    var rec: HitRecord = undefined;
    const r = Ray{ .orig = Point3.init(0, 0, 0), .dir = Vec3.init(0, 0, 1) };

    const did_hit = hit(always_hits, r, 0.0, 1.0, &rec);
    try std.testing.expect(did_hit);
}

test "didNotHit" {
    const std = @import("std");

    const AlwaysMisses = struct {
        pub fn hit(_: @This(), _: Ray, _: f64, _: f64, _: *HitRecord) bool {
            return false;
        }
    };

    const always_misses = AlwaysMisses{};
    var rec: HitRecord = undefined;
    const r = Ray{ .orig = Point3.init(0, 0, 0), .dir = Vec3.init(0, 0, 1) };

    const did_hit = hit(always_misses, r, 0.0, 1.0, &rec);
    try std.testing.expect(!did_hit);
}
