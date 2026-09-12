const std = @import("std");
const Self = @This();

deshuffle : bool,
alt_output : ?[]u8,
backing_buffer_file_input : [1028]u8 = undefined,
file_input : []u8,

pub fn ParseFromArgs(self : *Self, args : []const [:0]const u8) !void {
    if (args.len < 2) return error.TooFewArgs;

    for (1..args.len) |i| {
        if (std.mem.eql(u8, args[i], "-h") or std.mem.eql(u8, args[i], "--help")) {
            return error.HelpMessageRequested;
        }
    }

    @memcpy(self.backing_buffer_file_input[0..args[1].len], args[1]);
    self.file_input = self.backing_buffer_file_input[0..args[1].len];
}

pub fn Default() Self {
    return .{
        .deshuffle = false,
        .alt_output = null,
        .file_input = undefined,
    };
}
