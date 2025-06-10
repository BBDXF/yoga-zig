const std = @import("std");

const yoga = @import("yoga_zig");

fn dumpNode(allocator: std.mem.Allocator, node: *yoga.YGNode, indent: usize) void {
    var list = std.ArrayList(u8).init(allocator);
    defer list.deinit();
    list.appendNTimes(' ', indent) catch unreachable;
    const indent_str = list.toOwnedSlice() catch unreachable;

    std.debug.print("{s}out-box: x: {d} y: {d} w: {d} h: {d}\n", .{
        indent_str,
        yoga.YGNodeLayoutGetLeft(node),
        yoga.YGNodeLayoutGetTop(node),
        yoga.YGNodeLayoutGetWidth(node),
        yoga.YGNodeLayoutGetHeight(node),
    });
    std.debug.print("{s}margin: left: {d} top: {d} right: {d} bottom: {d}\n", .{
        indent_str,
        yoga.YGNodeLayoutGetMargin(node, yoga.YGEdgeLeft),
        yoga.YGNodeLayoutGetMargin(node, yoga.YGEdgeTop),
        yoga.YGNodeLayoutGetMargin(node, yoga.YGEdgeRight),
        yoga.YGNodeLayoutGetMargin(node, yoga.YGEdgeBottom),
    });
    std.debug.print("{s}padding: left: {d} top: {d} right: {d} bottom: {d}\n", .{
        indent_str,
        yoga.YGNodeLayoutGetPadding(node, yoga.YGEdgeLeft),
        yoga.YGNodeLayoutGetPadding(node, yoga.YGEdgeTop),
        yoga.YGNodeLayoutGetPadding(node, yoga.YGEdgeRight),
        yoga.YGNodeLayoutGetPadding(node, yoga.YGEdgeBottom),
    });
    std.debug.print("{s}border: left: {d} top: {d} right: {d} bottom: {d}\n", .{
        indent_str,
        yoga.YGNodeLayoutGetBorder(node, yoga.YGEdgeLeft),
        yoga.YGNodeLayoutGetBorder(node, yoga.YGEdgeTop),
        yoga.YGNodeLayoutGetBorder(node, yoga.YGEdgeRight),
        yoga.YGNodeLayoutGetBorder(node, yoga.YGEdgeBottom),
    });
    std.debug.print("{s}direction: {d}\n", .{
        indent_str,
        yoga.YGNodeLayoutGetDirection(node),
    });
    std.debug.print("{s}node-type: {d}\n", .{
        indent_str,
        yoga.YGNodeGetNodeType(node),
    });
    std.debug.print("{s}----------------------\n", .{indent_str});

    for (0..yoga.YGNodeGetChildCount(node)) |i| {
        const child = yoga.YGNodeGetChild(node, i) orelse continue;
        dumpNode(allocator, child, indent + 2);
    }
}
pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const node = yoga.YGNodeNew() orelse {
        std.debug.print("node new error\n", .{});
        return;
    };
    defer yoga.YGNodeFree(node);
    yoga.YGNodeStyleSetWidth(node, 300);
    yoga.YGNodeStyleSetHeight(node, 100);
    yoga.YGNodeStyleSetFlexDirection(node, yoga.YGFlexDirectionRow);
    yoga.YGNodeStyleSetJustifyContent(node, yoga.YGJustifyCenter);
    yoga.YGNodeStyleSetAlignItems(node, yoga.YGAlignCenter);
    yoga.YGNodeStyleSetPadding(node, yoga.YGEdgeAll, 10);

    const child1 = yoga.YGNodeNew() orelse {
        std.debug.print("child new error\n", .{});
        return;
    };
    defer yoga.YGNodeFree(child1);
    yoga.YGNodeStyleSetWidthPercent(child1, 20);
    yoga.YGNodeStyleSetHeight(child1, 50);
    yoga.YGNodeInsertChild(node, child1, 0);
    const child2 = yoga.YGNodeNew() orelse {
        std.debug.print("child new error\n", .{});
        return;
    };
    defer yoga.YGNodeFree(child2);
    yoga.YGNodeStyleSetFlexGrow(child2, 1);
    yoga.YGNodeStyleSetHeight(child2, 80);
    yoga.YGNodeInsertChild(node, child2, 1);
    yoga.YGNodeStyleSetMargin(child2, yoga.YGEdgeAll, 4);
    yoga.YGNodeStyleSetMarginAuto(child2, yoga.YGEdgeRight);
    yoga.YGNodeStyleSetMarginAuto(child2, yoga.YGEdgeLeft);

    yoga.YGNodeCalculateLayout(node, yoga.YGUndefined, yoga.YGUndefined, yoga.YGDirectionLTR);

    // print all nodes position
    std.debug.print("layout show:\n", .{});
    dumpNode(allocator, node, 2);

    // change child1
    std.debug.print("\nchange child1 width and height...\n", .{});
    yoga.YGNodeStyleSetWidth(child1, 100);
    yoga.YGNodeStyleSetHeightPercent(child1, 100);
    yoga.YGNodeSetHasNewLayout(child1, true); // mark child1 as dirty

    // calculate layout again
    if (yoga.YGNodeGetHasNewLayout(node)) {
        yoga.YGNodeCalculateLayout(node, yoga.YGUndefined, yoga.YGUndefined, yoga.YGDirectionLTR);
    }

    // print all nodes position
    std.debug.print("layout show:\n", .{});
    dumpNode(allocator, node, 2);
}
