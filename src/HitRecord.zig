const Vec3 = @import("Vec3.zig");
const Point3 = Vec3;
const Ray = @import("Ray.zig");

const HitRecord = @This();

p: Point3 = undefined,
normal: Vec3 = undefined,
t: f64 = undefined,
front_face: bool = undefined,

pub fn init(p: Point3, normal: Vec3, t: f64) HitRecord {
    return HitRecord{
        .p = p,
        .normal = normal,
        .t = t,
    };
}

pub fn setFaceNormal(self: *HitRecord, r: Ray, outward_normal: Vec3) void {
    self.front_face = Vec3.dot(r.dir, outward_normal) < 0;
    self.normal = if (self.front_face) outward_normal else outward_normal.multiplyByScalar(-1.0);
}
