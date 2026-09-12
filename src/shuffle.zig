const std = @import("std");

pub fn ShuffleFile(
    io : std.Io,
    allocator : std.mem.Allocator,
    file_name : []const u8,
) !void {
    const mid_shuffle_file_name = try std.fmt.allocPrint(
        allocator,
        "{s}.ms",
        .{ file_name },
    );
    defer allocator.free(mid_shuffle_file_name);
    const shuffle_step_ref_file_name = try std.fmt.allocPrint(
        allocator,
        "{s}.ref",
        .{ mid_shuffle_file_name },
    );
    defer allocator.free(shuffle_step_ref_file_name);

    std.log.debug("Safe file name: {s}", .{ mid_shuffle_file_name });
    std.log.debug("Safe file name: {s}", .{ shuffle_step_ref_file_name });

    try ensure_sure_byte_count(
        io,
        file_name,
        mid_shuffle_file_name,
        shuffle_step_ref_file_name
    );

    try first_step(
        io, 
        mid_shuffle_file_name,
        shuffle_step_ref_file_name,
    );
}


fn ensure_sure_byte_count(
    io : std.Io,
    original_file_name : []const u8,
    shuffle_step_file_name : []const u8,
    ref_file_name : []const u8,
) !void {
    std.log.debug("Original file name: {s}", .{ original_file_name });
    std.log.debug("Safe file name: {s}", .{ shuffle_step_file_name });
    std.log.debug("Ref file name: {s}", .{ ref_file_name });
    var shuffled_file = try std.Io.Dir.createFile(
        .cwd(),
        io,
        shuffle_step_file_name,
        .{
            .exclusive = true,
            .lock = .exclusive,
        },
    );
    defer shuffled_file.close(io);

    try std.Io.Dir.copyFile(
        .cwd(),
        original_file_name,
        .cwd(),
        ref_file_name,
        io,
        .{
            .replace = false,
        },
    );

    var ref_file = try std.Io.Dir.openFile(
        .cwd(),
        io,
        ref_file_name,
        .{
            .mode = .read_write,
            .allow_directory = false,
            .lock = .exclusive,
            .follow_symlinks = false,
        },
    );
    defer ref_file.close(io);

    defer std.Io.Dir.deleteFile(.cwd(), io, ref_file_name) catch {};

    var backing_buffer_shuffle_file_writer : [512]u8 = undefined;
    var shuffle_file_writer_full = shuffled_file.writer(
        io,
        &backing_buffer_shuffle_file_writer,
    );
    defer shuffle_file_writer_full.end() catch {};

    const file_size : u64 = (try ref_file.stat(io)).size;
    var file_size_as_array : [8]u8 = std.mem.zeroes([8]u8);
    std.mem.writeInt(u64, &file_size_as_array, file_size, .little);
    _ = try shuffle_file_writer_full.interface.write(&file_size_as_array);

    var backing_buffer_ref_file_reader : [512]u8 = undefined;
    var ref_file_reader_full = ref_file.reader(io, &backing_buffer_ref_file_reader);

    const temp = try shuffle_file_writer_full.interface.sendFileAll(&ref_file_reader_full, .unlimited);

    std.log.debug("Wrote {d} bytes from ref file", .{ temp });

    var dynamic_file_size = file_size + 8;
    while (0 != (dynamic_file_size % 4)) : (dynamic_file_size += 1) {
        std.log.debug("Padding a byte", .{});
        try shuffle_file_writer_full.interface.writeByte('0');
    }
}


fn first_step(
    io : std.Io,
    shuffle_file_name : []const u8,
    ref_file_name : []const u8,
) !void {
    try std.Io.Dir.copyFile(
        .cwd(),
        shuffle_file_name,
        .cwd(),
        ref_file_name,
        io,
        .{
            .replace = false,
        }
    );

    var ref_file = try std.Io.Dir.openFile(
        .cwd(),
        io,
        ref_file_name,
        .{
            .mode = .read_write,
            .allow_directory = false,
            .lock = .exclusive,
            .lock_nonblocking = true,
            .follow_symlinks = false,
        }
    );
    defer ref_file.close(io);

    var shuffle_file = try std.Io.Dir.openFile(
        .cwd(),
        io,
        shuffle_file_name,
        .{
            .mode = .read_write,
            .allow_directory = false,
            .lock = .exclusive,
            .lock_nonblocking = true,
            .follow_symlinks = false,
        }
    );
    defer shuffle_file.close(io);

    const file_size = try ref_file.stat(io).size;
    const quadrant_size = file_size / 4;
    const pivot_point = file_size - quadrant_size;


}
