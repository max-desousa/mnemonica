const std = @import("std");

pub fn PrintHelp(io : std.Io) void {
    _ = &io;
    std.debug.print("This is the help message\n", .{});
}
