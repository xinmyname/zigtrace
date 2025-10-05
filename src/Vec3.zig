const Vec3 = @This();

e: [3]f64 = .{ 0.0, 0.0, 0.0 },

pub fn init(e0: f64, e1: f64, e2: f64) Vec3 {
    return Vec3{
        .e = .{ e0, e1, e2 },
    };
}

pub fn x(self: *Vec3) f64 {
    return self.e[0];
}

pub fn y(self: *Vec3) f64 {
    return self.e[1];
}

pub fn z(self: *Vec3) f64 {
    return self.e[2];
}

pub fn inverse(self: Vec3) Vec3 {
    return Vec3{
        .e = .{ -self.e[0], -self.e[1], -self.e[2] },
    };
}

pub fn addTo(self: *Vec3, other: Vec3) void {
    self.e[0] += other.e[0];
    self.e[1] += other.e[1];
    self.e[2] += other.e[2];
}

pub fn multiplyBy(self: *Vec3, t: f64) *Vec3 {
    self.e[0] *= t;
    self.e[1] *= t;
    self.e[2] *= t;

    return self;
}

pub fn divideBy(self: *Vec3, t: f64) *Vec3 {
    return self.multiplyBy(1.0 / t);
}

pub fn lengthSquared(self: Vec3) f64 {
    return self.e[0] * self.e[0] + self.e[1] * self.e[1] + self.e[2] * self.e[2];
}

pub fn length(self: Vec3) f64 {
    return @sqrt(self.lengthSquared());
}

pub fn add(u: Vec3, v: Vec3) Vec3 {
    return Vec3{
        .e = .{ u.e[0] + v.e[0], u.e[1] + v.e[1], u.e[2] + v.e[2] },
    };
}

pub fn subtract(u: Vec3, v: Vec3) Vec3 {
    return Vec3{
        .e = .{ u.e[0] - v.e[0], u.e[1] - v.e[1], u.e[2] - v.e[2] },
    };
}

pub fn multiply(u: Vec3, v: Vec3) Vec3 {
    return Vec3{
        .e = .{ u.e[0] * v.e[0], u.e[1] * v.e[1], u.e[2] * v.e[2] },
    };
}

pub fn scale(v: Vec3, t: f64) Vec3 {
    return Vec3{
        .e = .{ v.e[0] * t, v.e[1] * t, v.e[2] * t },
    };
}

// TODO: Possibly an inverted scale? Equivalent to vec3 operator/(const vec3& v, double t)

pub fn dot(u: Vec3, v: Vec3) f64 {
    return u.e[0] * v.e[0] + u.e[1] * v.e[1] + u.e[2] * v.e[2];
}

pub fn cross(u: Vec3, v: Vec3) Vec3 {
    return Vec3{
        .e = .{
            u.e[1] * v.e[2] - u.e[2] * v.e[1],
            u.e[2] * v.e[0] - u.e[0] * v.e[2],
            u.e[0] * v.e[1] - u.e[1] * v.e[0],
        },
    };
}

pub fn unitVector(v: Vec3) Vec3 {
    return scale(v, 1.0 / v.length());
}

test "xyz" {
    const std = @import("std");
    var v = Vec3.init(1.0, 2.0, 3.0);
    try std.testing.expectEqual(1.0, v.x());
    try std.testing.expectEqual(2.0, v.y());
    try std.testing.expectEqual(3.0, v.z());
    try std.testing.expectEqual(1.0, v.x());
    v.e[0] = 4.0;
    v.e[1] = 5.0;
    v.e[2] = 6.0;
    try std.testing.expectEqual(4.0, v.x());
    try std.testing.expectEqual(5.0, v.y());
    try std.testing.expectEqual(6.0, v.z());
}

test "inverse" {
    const std = @import("std");
    const v = Vec3.init(1.0, 2.0, 3.0);
    const inverted = v.inverse();
    try std.testing.expectEqual(-1.0, inverted.e[0]);
    try std.testing.expectEqual(-2.0, inverted.e[1]);
    try std.testing.expectEqual(-3.0, inverted.e[2]);
}

test "addTo" {
    const std = @import("std");
    var v1 = Vec3.init(1.0, 2.0, 3.0);
    const v2 = Vec3.init(4.5, 5.7, 6.9);
    v1.addTo(v2);
    try std.testing.expectEqual(5.5, v1.e[0]);
    try std.testing.expectEqual(7.7, v1.e[1]);
    try std.testing.expectEqual(9.9, v1.e[2]);
}

test "multiplyBy" {
    const std = @import("std");
    var v = Vec3.init(1.0, 2.0, 3.0);
    const result = v.multiplyBy(2.0);
    try std.testing.expectEqual(2.0, v.e[0]);
    try std.testing.expectEqual(4.0, v.e[1]);
    try std.testing.expectEqual(6.0, v.e[2]);
    try std.testing.expectEqual(result.e[0], v.e[0]);
    try std.testing.expectEqual(result.e[1], v.e[1]);
    try std.testing.expectEqual(result.e[2], v.e[2]);
}

test "divideBy" {
    const std = @import("std");
    var v = Vec3.init(2.0, 4.0, 6.0);
    const result = v.divideBy(2.0);
    try std.testing.expectEqual(1.0, v.e[0]);
    try std.testing.expectEqual(2.0, v.e[1]);
    try std.testing.expectEqual(3.0, v.e[2]);
    try std.testing.expectEqual(result.e[0], v.e[0]);
    try std.testing.expectEqual(result.e[1], v.e[1]);
    try std.testing.expectEqual(result.e[2], v.e[2]);
}

test "lengthSquared" {
    const std = @import("std");
    const v = Vec3.init(1.0, 2.0, 3.0);
    try std.testing.expectEqual(14.0, v.lengthSquared());
}

test "length" {
    const std = @import("std");
    const v = Vec3.init(1.0, 2.0, 2.0);
    try std.testing.expectEqual(3.0, v.length());
}

test "add" {
    const std = @import("std");
    const u = Vec3.init(1.0, 2.0, 3.0);
    const v = Vec3.init(4.5, 5.7, 6.9);
    const result = Vec3.add(u, v);
    try std.testing.expectEqual(5.5, result.e[0]);
    try std.testing.expectEqual(7.7, result.e[1]);
    try std.testing.expectEqual(9.9, result.e[2]);
}

test "subtract" {
    const std = @import("std");
    const u = Vec3.init(4.0, 5.0, 6.0);
    const v = Vec3.init(1.0, 3.0, 5.0);
    const result = Vec3.subtract(u, v);
    try std.testing.expectEqual(3.0, result.e[0]);
    try std.testing.expectEqual(2.0, result.e[1]);
    try std.testing.expectEqual(1.0, result.e[2]);
}

test "multiply" {
    const std = @import("std");
    const u = Vec3.init(1.0, 2.0, 3.0);
    const v = Vec3.init(4.0, 5.0, 6.0);
    const result = Vec3.multiply(u, v);
    try std.testing.expectEqual(4.0, result.e[0]);
    try std.testing.expectEqual(10.0, result.e[1]);
    try std.testing.expectEqual(18.0, result.e[2]);
}

test "scale" {
    const std = @import("std");
    const v = Vec3.init(1.0, 2.0, 3.0);
    const scaled = Vec3.scale(v, 2.0);
    try std.testing.expectEqual(2.0, scaled.e[0]);
    try std.testing.expectEqual(4.0, scaled.e[1]);
    try std.testing.expectEqual(6.0, scaled.e[2]);
}

test "dot" {
    const std = @import("std");
    const u = Vec3.init(1.0, 2.0, 3.0);
    const v = Vec3.init(4.0, 5.0, 6.0);
    const result = Vec3.dot(u, v);
    try std.testing.expectEqual(32.0, result);
}

test "cross" {
    const std = @import("std");
    const u = Vec3.init(1.0, 2.0, 3.0);
    const v = Vec3.init(4.0, 5.0, 6.0);
    const result = Vec3.cross(u, v);
    try std.testing.expectEqual(-3.0, result.e[0]);
    try std.testing.expectEqual(6.0, result.e[1]);
    try std.testing.expectEqual(-3.0, result.e[2]);
}

test "unitVector" {
    const std = @import("std");
    const v = Vec3.init(1.0, 2.0, 2.0);
    const unit = Vec3.unitVector(v);
    try std.testing.expectEqual(1.0 / 3.0, unit.e[0]);
    try std.testing.expectEqual(2.0 / 3.0, unit.e[1]);
    try std.testing.expectEqual(2.0 / 3.0, unit.e[2]);
}
