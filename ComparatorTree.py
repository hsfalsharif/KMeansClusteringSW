class ComparatorTree:
    class Node:
        left = None
        right = None
        D = 0

        def __init__(self, D=None):
            self.left = None
            self.right = None
            self.D = D

        def to_string(self):
            return "D: {0}".format(self.D)

    root = None

    def __init__(self, means=None):
        if means is None:
            means = [0]
        self.root = self.build(means)

    def build(self, a):
        size = len(a)
        if size == 2:
            x = self.Node((a[0] + a[1]) // 2)
            x.left = self.Node(a[0])
            x.right = self.Node(a[1])
            return x
        if size == 1:
            return self.Node(a[0])
        middle = a[len(a) // 2 - 1:len(a) // 2 + 1]
        avg = (middle[0] + middle[1]) // 2
        center = self.Node(avg)
        center.left = self.build(a[0:size // 2])
        center.right = self.build(a[size // 2:])

        return center

    def traverse(self, current, point):
        if current.left is None and current.right is None:
            return current.D
        if point <= current.D:
            return self.traverse(current.left, point)
        else:
            return self.traverse(current.right, point)

    # def to_string(self):  # this has an error so don't use it
    #     return self.concatenate(self.root)

    # def concatenate(self, node, level=0):
    #     if node is None:
    #         return ""
    #     left = self.concatenate(node.left, level + 1)
    #     right = self.concatenate(node.right, level + 1)
    #     s = left
    #     s += "{0} -> {1} {2}".format(' ' * 4 * (len(self.root.means) - level), node.D, node.means)
    #     s += right
    #     return s
