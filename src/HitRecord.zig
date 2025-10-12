const Vec3 = @import("Vec3.zig");
const Point3 = Vec3;

const HitRecord = @This();

p: Point3 = undefined,
normal: Vec3 = undefined,
t: f64 = undefined,

pub fn init(p: Point3, normal: Vec3, t: f64) HitRecord {
    return HitRecord{
        .p = p,
        .normal = normal,
        .t = t,
    };
}
