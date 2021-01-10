class ComparatorTree:
    class Node:
        left = None
        right = None
        D = 0
        indices = []

        def __init__(self, D, indices):
            self.left = None
            self.right = None
            self.D = D
            self.indices = indices

        def to_string(self):
            return "D: {0}, Indices: {1}".format(self.D, self.indices)

    root = None

    def __init__(self, D_points, indices):
        root = self.build(D_points, indices)

    def build(self, D_points, indices):
        size = len(D_points)
        if size == 1:
            return self.Node(D_points[0], indices[0])
        left = self.build(D_points[0:size / 2], indices[0:size / 2])
        right = self.build(D_points[size / 2 + 1:size], indices[size / 2 + 1:size])
        center = self.Node(D_points[size / 2], indices)
        center.left = left
        center.right = right
        return center

    def traverse(self, current, point):
        if current.left is None and current.right is None:
            return current
        if point < current.D:
            return self.traverse(current.left, point)
        else:
            return self.traverse(current.right, point)

    def to_string(self):
        return self.concatenate(self.root)

    def concatenate(self, node):
        if node is None:
            return ""
        left_string = self.concatenate(node.left)
        right_string = self.concatenate(node.right)
        return "\t{1}\t\n{0}\t\t{2}".format(left_string, node.to_string(), right_string)
