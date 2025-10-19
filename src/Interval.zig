const std = @import("std");

const Interval = @This();

min: f64,
max: f64,

pub const empty = Interval{
    .min = std.math.inf(f64),
    .max = -std.math.inf(f64),
};

pub const universe = Interval{
    .min = -std.math.inf(f64),
    .max = std.math.inf(f64),
};

pub fn initEmpty() Interval {
    return .{ .min = std.math.inf(f64), .max = -std.math.inf(f64) };
}

pub fn init(min: f64, max: f64) Interval {
    return .{ .min = min, .max = max };
}

pub fn size(self: Interval) f64 {
    return self.max - self.min;
}

pub fn contains(self: Interval, x: f64) bool {
    return self.min <= x and x <= self.max;
}

pub fn surrounds(self: Interval, x: f64) bool {
    return self.min < x and x < self.max;
}

test "Interval init and size" {
    const interval = Interval.init(2.0, 5.0);
    try std.testing.expect(interval.size() == 3.0);
}

test "Interval contains" {
    const interval = Interval.init(2.0, 5.0);
    try std.testing.expect(interval.contains(2.0));
    try std.testing.expect(interval.contains(3.5));
    try std.testing.expect(interval.contains(5.0));
    try std.testing.expect(!interval.contains(1.9));
    try std.testing.expect(!interval.contains(5.1));
}

test "Interval surrounds" {
    const interval = Interval.init(2.0, 5.0);
    try std.testing.expect(!interval.surrounds(2.0));
    try std.testing.expect(interval.surrounds(3.5));
    try std.testing.expect(!interval.surrounds(5.0));
    try std.testing.expect(!interval.surrounds(1.9));
    try std.testing.expect(!interval.surrounds(5.1));
}

test "empty interval" {
    const interval = Interval.initEmpty();
    const emptyInterval = Interval.empty;

    try std.testing.expect(interval.min == emptyInterval.min);
    try std.testing.expect(interval.max == emptyInterval.max);

    try std.testing.expect(interval.size() < 0);
    try std.testing.expect(!interval.contains(0.0));
    try std.testing.expect(!interval.surrounds(0.0));
}
