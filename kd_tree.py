import random
import math


class node:
    val = None
    left = None
    right = None
    axis = None
    cube = None

    def __init__(self, val=None, axis=None, cube=None):
        self.val = val
        self.axis = axis
        self.cube = cube

    def print(self):
        if self.right is not None:
            self.right.printTree(True, "")

        print([self.val, self.axis, self.cube])
        if self.left is not None:
            self.left.printTree(False, "")

    def printTree(self, isRight, indent):
        if self.right is not None:
            if isRight:
                self.right.printTree(True, indent + "        ")
            else:
                self.right.printTree(True, indent + " |      ")

        print(indent, end="")
        if isRight:
            print(" /", end="")
        else:
            print(" \\", end="")

        print("----- ", end="")
        print([self.val, self.axis, self.cube])
        if self.left is not None:
            if isRight:
                self.left.printTree(False, indent + " |      ")
            else:
                self.left.printTree(False, indent + "        ")

    # def traverse(self, point):
    #     if self.left is None and self.right is None:
    #         return self.cube
    #     if point[self.axis] <= self.val[self.axis]:
    #         next_node = self.left
    #         opposite_node = self.right
    #     else:
    #         next_node = self.right
    #         opposite_node = self.left
    #     best = closer_distance(point, next_node.traverse(point), self.val)
    #     if manhattan(point, best) > manhattan(point, self.val):
    #         best = closer_distance(point, opposite_node.traverse(point), self.val)
    #     #     print("Change branch")
    #     # print("Next Node:", next_node.val, "Opposite Node:", opposite_node.val, "Best Node", best, "Root Node",
    #     #       self.val)
    #     return best


# def build_kd_tree(means, depth=0, dim=3):
#     size = len(means)
#     print(size, depth)
#     axis = depth % dim
#     if size == 1:
#         return node(means[0], axis, means[0])
#     middle = [means[len(means) // 2]]
#     avg_x = middle[0][0]
#     avg_y = middle[0][1]
#     avg_z = middle[0][2]
#     center = node(val=[avg_x, avg_y, avg_z], axis=axis)
#     center.left = build_kd_tree(means[0:size // 2], depth=depth + 1, dim=dim)
#     center.right = build_kd_tree(means[size // 2:], depth=depth + 1, dim=dim)
#     return center

def build_kd_tree(means, dim=3, depth=0):
    if len(means) > 1:
        means.sort(key=lambda x: x[depth])
        depth = (depth + 1) % dim
        half = len(means) >> 1
        return [
            build_kd_tree(means[:half], dim, depth),
            build_kd_tree(means[half + 1:], dim, depth),
            means[half]
        ]
    elif len(means) == 1:
        return [None, None, means[0]]


def traverse(kd_node, point, dim, dist_func, return_distances=False, depth=0, best=None):
    if kd_node is not None:
        dist = dist_func(point, kd_node[2])
        dx = kd_node[2][depth] - point[depth]
        if not best:
            best = [dist, kd_node[2]]
        elif dist < best[0]:
            best[0], best[1] = dist, kd_node[2]
        depth = (depth + 1) % dim
        for b in [dx < 0] + [dx >= 0] * (dx < best[0]):
            traverse(kd_node[b], point, dim, dist_func, return_distances, depth, best)
    return best if return_distances else best[1]


def euclidean(cube, point):
    return math.sqrt((cube[0] - point[0]) ** 2 + (cube[1] - point[1]) ** 2 +
                     (cube[2] - point[2]) ** 2)


def manhattan(p1, p2):
    return abs(p1[0] - p2[0]) + abs(p1[1] - p2[1]) + abs(p1[2] - p2[2])

def dist_sq(a, b, dim):
    return sum((a[i] - b[i]) ** 2 for i in range(dim))

def dist_sq_dim(a, b):
    return dist_sq(a, b, 3)

def closer_distance(point, p1, p2):
    if p1 is None:
        return p2

    if p2 is None:
        return p1

    d1 = manhattan(point, p1)
    d2 = manhattan(point, p2)

    if d1 < d2:
        return p1
    else:
        return p2


def real_closest(point, cubes):
    mn = 1000000
    nearest = None
    for c in cubes:
        d = manhattan(c, point)
        # print(f"D is {d}")
        if mn > d:
            nearest = c
            mn = d
            # print(f"nearest is {nearest.center}")
    return nearest


# test_means = [[38, 29, 12], [73, 69, 55], [93, 103, 167], [138, 256, 324], [184, 271, 331], [225, 329, 353],
#               [249, 350, 369], [253, 352, 371], [262, 375, 383], [345, 378, 395], [429, 489, 417], [496, 497, 450]]
test_x = []
test_y = []
test_z = []
test_means = []
for i in range(12):
    test_x.append(random.randint(1, 256))
    test_y.append(random.randint(1, 256))
    test_z.append(random.randint(1, 256))

test_x.sort()
test_y.sort()
test_z.sort()

for i in range(len(test_x)):
    test_means.append([test_x[i], test_y[i], test_z[i]])

test_tree = build_kd_tree(test_means)
# test_tree.print()
percent_error = 0
percent_error_t = 0
point = [511, 485, 442]
tree_nearest = traverse(test_tree, point, 3, manhattan)
real_nearest = real_closest(point, test_means)
count = 0
misclassified = 0
while count < 10000:
    point = [random.randint(1, 256), random.randint(1, 256), random.randint(1, 256)]
    # point = [351, 227, 13]
    tree_nearest = traverse(test_tree, point, 3, manhattan)
    real_nearest = real_closest(point, test_means)
    if tree_nearest != real_nearest:
        misclassified = misclassified + 1
    count = count + 1
print(misclassified)
print((misclassified / count) * 100)

# while 1:
#     point = [random.randint(1, 512), random.randint(1, 512), random.randint(1, 512)]
#     # point = test_means[random.randint(0, len(test_means) - 1)]
#     tree_nearest = traverse(test_tree, point, 3, euclidean)
#     real_nearest = real_closest(point, test_means)
#     print(point)
#     print(
#         f"the tree distance is {euclidean(tree_nearest[1], point)},{tree_nearest[1]} the actual nearest "
#         f"distance {euclidean(real_nearest, point)}{real_nearest}")
#     if euclidean(real_nearest, point) != 0:
#         percent_error_t = abs(euclidean(tree_nearest[1], point) - euclidean(real_nearest, point)) / euclidean(real_nearest,
#                                                                                                            point) \
#                           * 100
#     if percent_error < percent_error_t:
#         percent_error = percent_error_t
#         print("Euclidean:", euclidean(real_nearest, point), "Tree:", euclidean(tree_nearest[1], point), "Current Max "
#                                                                                                      "Error:",
#               percent_error)
#         print("Point:", point, "Real Nearest:", real_nearest, "Tree Nearest:", tree_nearest[1])
#         # print(test_means)
#     input()
