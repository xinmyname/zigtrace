const std = @import("std");
const Vec3 = @import("Vec3.zig");
const Point3 = Vec3;
const Ray = @import("Ray.zig");
const HitRecord = @import("HitRecord.zig");
const Interval = @import("Interval.zig");

pub const Sphere = struct {
    center: Point3 = undefined,
    radius: f64 = undefined,

    pub fn init(center: Point3, radius: f64) Sphere {
        return Sphere{
            .center = center,
            .radius = @max(0.0, radius),
        };
    }

    pub fn hit(self: Sphere, r: Ray, ray_t: Interval, rec: *HitRecord) bool {
        const oc = self.center.subtractVector(r.orig);
        const a = r.dir.lengthSquared();
        const h = Vec3.dot(r.dir, oc);
        const c = oc.lengthSquared() - self.radius * self.radius;
        const discriminant = h * h - a * c;

        if (discriminant < 0)
            return false;

        const sqrt_d = std.math.sqrt(discriminant);
        var root = (h - sqrt_d) / a;

        if (!ray_t.surrounds(root)) {
            root = (h + sqrt_d) / a;
            if (!ray_t.surrounds(root))
                return false;
        }

        rec.t = root;
        rec.p = r.at(rec.t);
        const outward_normal = rec.p.subtractVector(self.center).divideByScalar(self.radius);
        rec.setFaceNormal(r, outward_normal);

        return true;
    }
};

pub const ObjectList = struct {
    objects: std.ArrayList(Object) = .empty,

    pub fn deinit(self: *ObjectList, allocator: std.mem.Allocator) void {
        self.objects.deinit(allocator);
    }

    pub fn append(self: *ObjectList, allocator: std.mem.Allocator, object: Object) !void {
        try self.objects.append(allocator, object);
    }

    pub fn hit(self: ObjectList, r: Ray, ray_t: Interval, rec: *HitRecord) bool {
        var temp_rec: HitRecord = undefined;
        var hit_anything = false;
        var closest_so_far = ray_t.max;

        for (self.objects.items) |obj| {
            if (obj.hit(r, Interval.init(ray_t.min, closest_so_far), &temp_rec)) {
                hit_anything = true;
                closest_so_far = temp_rec.t;
                rec.* = temp_rec;
            }
        }

        return hit_anything;
    }
};

pub const Object = union(enum) {
    Sphere: Sphere,
    ObjectList: ObjectList,

    pub fn sphere(center: Point3, radius: f64) Object {
        return Object{ .Sphere = Sphere.init(center, radius) };
    }

    pub fn objectList() Object {
        return Object{ .ObjectList = ObjectList{} };
    }

    pub fn hit(self: Object, r: Ray, ray_t: Interval, rec: *HitRecord) bool {
        return switch (self) {
            .Sphere => self.Sphere.hit(r, ray_t, rec),
            .ObjectList => self.ObjectList.hit(r, ray_t, rec),
        };
    }
};

test "ray hits sphere" {
    const s = Sphere.init(Point3.init(0.0, 0.0, -1.0), 0.5);
    const r = Ray.init(Point3.init(0.0, 0.0, 0.0), Vec3.init(0.0, 0.0, -1.0));
    var rec: HitRecord = undefined;

    const did_hit = s.hit(r, Interval.init(0.0, 100.0), &rec);
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

    const did_hit = s.hit(r, Interval.init(0.0, 100.0), &rec);
    try std.testing.expect(!did_hit);
}

test "ray inside sphere" {
    const s = Sphere.init(Point3.init(0.0, 0.0, 0.0), 0.5);
    const r = Ray.init(Point3.init(0.0, 0.0, 0.0), Vec3.init(0.0, 0.0, -1.0));
    var rec: HitRecord = undefined;

    const did_hit = s.hit(r, Interval.init(0.0, 100.0), &rec);
    try std.testing.expect(did_hit);
    try std.testing.expect(rec.t == 0.5); // The ray has travelled 0.5 units to hit the sphere.
    try std.testing.expect(rec.p.e[0] == 0.0);
    try std.testing.expect(rec.p.e[1] == 0.0);
    try std.testing.expect(rec.p.e[2] == -0.5); // The hit point is at z=-0.5
    try std.testing.expect(rec.normal.e[0] == 0.0);
    try std.testing.expect(rec.normal.e[1] == 0.0);
    try std.testing.expect(rec.normal.e[2] == 1.0); // The normal is reflected back toward the ray origin.
}

test "arraylist" {
    const a = std.testing.allocator;
    var list: std.ArrayList(Object) = .empty;
    defer list.deinit(a);

    const sphere = Object.sphere(Point3.init(0.0, 0.0, -1.0), 0.5);
    try list.append(a, sphere);
}

test "two spheres in hittable list" {
    var list = ObjectList{};
    defer list.deinit(std.testing.allocator);

    const sphere1 = Object.sphere(Point3.init(0.0, 0.0, -1.0), 0.5);
    const sphere2 = Object.sphere(Point3.init(0.0, -100.5, -1.0), 100.0);

    try list.append(std.testing.allocator, sphere1);
    try list.append(std.testing.allocator, sphere2);

    const r = Ray.init(Point3.init(0.0, 0.0, 0.0), Vec3.init(0.0, 0.0, -1.0));
    var rec: HitRecord = undefined;

    const did_hit = list.hit(r, Interval.init(0.0, 100.0), &rec);
    try std.testing.expect(did_hit);
    try std.testing.expect(rec.t == 0.5); // The ray hits the smaller sphere first.
}
