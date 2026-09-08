const std = @import("std");
const Self = @This();

deshuffle : bool,
alt_output : ?[]u8,

pub fn ParseFromArgs(args : []const [:0]const u8) !Self {
    if (args.len < 2) return error.TooFewArgs;

    for (1..args.len) |i| {
        if (std.mem.eql(u8, args[i], "-h") or std.mem.eql(u8, args[i], "--help")) {
            return error.HelpMessageRequested;
        }
    }

    return Default();
}

pub fn Default() Self {
    return .{
        .deshuffle = false,
        .alt_output = null,
    };
}
