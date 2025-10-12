const Vec3 = @This();

e: @Vector(3, f64) = .{ 0.0, 0.0, 0.0 },

pub fn init(xr: f64, yg: f64, zb: f64) Vec3 {
    return Vec3{
        .e = .{ xr, yg, zb },
    };
}

pub fn x(self: Vec3) f64 {
    return self.e[0];
}

pub fn y(self: Vec3) f64 {
    return self.e[1];
}

pub fn z(self: Vec3) f64 {
    return self.e[2];
}

pub fn r(self: Vec3) f64 {
    return self.e[0];
}

pub fn g(self: Vec3) f64 {
    return self.e[1];
}

pub fn b(self: Vec3) f64 {
    return self.e[2];
}

pub fn rByte(self: Vec3) u8 {
    return @intFromFloat(@min(@max(self.e[0], 0.0), 1.0) * 255.0);
}

pub fn gByte(self: Vec3) u8 {
    return @intFromFloat(@min(@max(self.e[1], 0.0), 1.0) * 255.0);
}

pub fn bByte(self: Vec3) u8 {
    return @intFromFloat(@min(@max(self.e[2], 0.0), 1.0) * 255.0);
}

pub fn rgbBytes(self: Vec3) [3]u8 {
    const zeros: @Vector(3, f64) = .{ 0.0, 0.0, 0.0 };
    const ones: @Vector(3, f64) = .{ 1.0, 1.0, 1.0 };
    const scale: @Vector(3, f64) = .{ 255.0, 255.0, 255.0 };

    const clamped = @max(zeros, @min(ones, self.e));
    const scaled = clamped * scale;

    return .{
        @intFromFloat(scaled[0]),
        @intFromFloat(scaled[1]),
        @intFromFloat(scaled[2]),
    };
}

pub fn inverse(self: Vec3) Vec3 {
    return Vec3{
        .e = .{ -self.e[0], -self.e[1], -self.e[2] },
    };
}

pub fn multiplyByScalar(self: Vec3, t: f64) Vec3 {
    return Vec3{
        .e = .{ self.e[0] * t, self.e[1] * t, self.e[2] * t },
    };
}

pub fn divideByScalar(self: Vec3, t: f64) Vec3 {
    return self.multiplyByScalar(1.0 / t);
}

pub fn addVector(self: Vec3, v: Vec3) Vec3 {
    return Vec3{
        .e = .{ self.e[0] + v.e[0], self.e[1] + v.e[1], self.e[2] + v.e[2] },
    };
}

pub fn subtractVector(self: Vec3, v: Vec3) Vec3 {
    return Vec3{
        .e = .{ self.e[0] - v.e[0], self.e[1] - v.e[1], self.e[2] - v.e[2] },
    };
}

pub fn lengthSquared(self: Vec3) f64 {
    return self.e[0] * self.e[0] + self.e[1] * self.e[1] + self.e[2] * self.e[2];
}

pub fn length(self: Vec3) f64 {
    return @sqrt(self.lengthSquared());
}

pub fn dot(u: Vec3, v: Vec3) f64 {
    return u.e[0] * v.e[0] + u.e[1] * v.e[1] + u.e[2] * v.e[2];
}

pub fn unitVector(v: Vec3) Vec3 {
    return v.divideByScalar(v.length());
}

test "xyz" {
    const std = @import("std");
    var v = Vec3.init(1.0, 2.0, 3.0);
    try std.testing.expectEqual(1.0, v.x());
    try std.testing.expectEqual(2.0, v.y());
    try std.testing.expectEqual(3.0, v.z());
    v.e[0] = 4.0;
    v.e[1] = 5.0;
    v.e[2] = 6.0;
    try std.testing.expectEqual(4.0, v.x());
    try std.testing.expectEqual(5.0, v.y());
    try std.testing.expectEqual(6.0, v.z());
}

test "rgb" {
    const std = @import("std");
    var v = Vec3.init(0.75, 0.15, 1.0);
    try std.testing.expectEqual(0.75, v.r());
    try std.testing.expectEqual(0.15, v.g());
    try std.testing.expectEqual(1.0, v.b());
    v.e[0] = 1.0;
    v.e[1] = 0.75;
    v.e[2] = 0.25;
    try std.testing.expectEqual(1.0, v.r());
    try std.testing.expectEqual(0.75, v.g());
    try std.testing.expectEqual(0.25, v.b());
}

test "rgbBytes" {
    const std = @import("std");
    var v = Vec3.init(0.75, 0.15, 1.0);
    const bytes1 = v.rgbBytes();
    try std.testing.expectEqual(191, bytes1[0]);
    try std.testing.expectEqual(38, bytes1[1]);
    try std.testing.expectEqual(255, bytes1[2]);

    v.e[0] = 1.0;
    v.e[1] = 0.75;
    v.e[2] = 0.25;
    const bytes2 = v.rgbBytes();
    try std.testing.expectEqual(255, bytes2[0]);
    try std.testing.expectEqual(191, bytes2[1]);
    try std.testing.expectEqual(63, bytes2[2]);

    v.e[0] = 2.0;
    v.e[1] = 30.0;
    v.e[2] = 400.0;
    const bytes3 = v.rgbBytes();
    try std.testing.expectEqual(255, bytes3[0]);
    try std.testing.expectEqual(255, bytes3[1]);
    try std.testing.expectEqual(255, bytes3[2]);

    v.e[0] = -1.1;
    v.e[1] = -2.2;
    v.e[2] = -3.3;
    const bytes4 = v.rgbBytes();
    try std.testing.expectEqual(0, bytes4[0]);
    try std.testing.expectEqual(0, bytes4[1]);
    try std.testing.expectEqual(0, bytes4[2]);
}

test "allRGBBytes" {
    const std = @import("std");
    var v = Vec3.init(-1.5, 0.5, 1.5);
    const bytes = v.rgbBytes();
    try std.testing.expectEqual(0, bytes[0]);
    try std.testing.expectEqual(127, bytes[1]);
    try std.testing.expectEqual(255, bytes[2]);
}

test "inverse" {
    const std = @import("std");
    const v = Vec3.init(1.0, 2.0, 3.0);
    const inverted = v.inverse();
    try std.testing.expectEqual(-1.0, inverted.x());
    try std.testing.expectEqual(-2.0, inverted.y());
    try std.testing.expectEqual(-3.0, inverted.z());
}

test "multiplyByScalar" {
    const std = @import("std");
    const v = Vec3.init(1.0, 2.0, 3.0);
    const result = v.multiplyByScalar(2.0);
    try std.testing.expectEqual(2.0, result.x());
    try std.testing.expectEqual(4.0, result.y());
    try std.testing.expectEqual(6.0, result.z());
}

test "divideByScalar" {
    const std = @import("std");
    const v = Vec3.init(2.0, 4.0, 6.0);
    const result = v.divideByScalar(2.0);
    try std.testing.expectEqual(1.0, result.x());
    try std.testing.expectEqual(2.0, result.y());
    try std.testing.expectEqual(3.0, result.z());
}

test "addVector" {
    const std = @import("std");
    const v1 = Vec3.init(1.0, 2.0, 3.0);
    const v2 = Vec3.init(4.5, 5.7, 6.9);
    const result = v1.addVector(v2);
    try std.testing.expectEqual(5.5, result.x());
    try std.testing.expectEqual(7.7, result.y());
    try std.testing.expectEqual(9.9, result.z());
}

test "subtractVector" {
    const std = @import("std");
    const v1 = Vec3.init(7.0, 5.0, 3.0);
    const v2 = Vec3.init(4.0, 3.0, 2.0);
    const result = v1.subtractVector(v2);
    try std.testing.expectEqual(3.0, result.x());
    try std.testing.expectEqual(2.0, result.y());
    try std.testing.expectEqual(1.0, result.z());
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

test "dot" {
    const std = @import("std");
    const u = Vec3.init(1.0, 2.0, 3.0);
    const v = Vec3.init(4.0, 5.0, 6.0);
    const result = Vec3.dot(u, v);
    try std.testing.expectEqual(32.0, result);
}

test "unitVector" {
    const std = @import("std");
    const v = Vec3.init(1.0, 2.0, 2.0);
    const unit = Vec3.unitVector(v);
    try std.testing.expectEqual(1.0 / 3.0, unit.e[0]);
    try std.testing.expectEqual(2.0 / 3.0, unit.e[1]);
    try std.testing.expectEqual(2.0 / 3.0, unit.e[2]);
}
