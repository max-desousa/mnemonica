const std = @import("std");
const config = @import("config");
const messaging = @import("messaging");
const shuffle = @import("shuffle");

pub fn main(init: std.process.Init) !void {
    //Getting args from cmd line
    const arena: std.mem.Allocator = init.arena.allocator();
    const args = try init.minimal.args.toSlice(arena);
    const allocator = init.gpa;

    //getting io instance
    const io = init.io;

    //creating writer to write to stdout
    var buffer_stdout : [512]u8 = undefined;
    var stdout_file_writer : std.Io.File.Writer = .init(.stdout(), io, &buffer_stdout);
    defer stdout_file_writer.end() catch {};
    const stdout_writer = &stdout_file_writer.interface;

    //Reading inputs from command line to determine what needs to be done.
    var cfg : config = .Default();
    config.ParseFromArgs(&cfg, args) catch |err| {
        if (error.HelpMessageRequested == err) {
            try messaging.PrintHelp(stdout_writer);
        }
        else {
            std.log.err("Error code: {any}", .{ err });
        }
        return;
    };

    std.log.debug("Input file is: \"{s}\"", .{ cfg.file_input });

    try shuffle.ShuffleFile(io, allocator, cfg.file_input);
}
