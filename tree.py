# %%
import math

from sklearn.datasets import make_blobs
import mock
import plotly.graph_objects as go
import matplotlib.pyplot as plt
import random


# option 1 : axis dividers are always the same but the mean inside them change position within the cube option 2 : the
# axis dividers are the middle point between each mean BUT this mean that the means are not aligned in one axis
# therefore the tree will not work option 3 : the tree will hold data information not position it will just filter the
# possibility to sub-means

class Tree:
    class node:
        D = None
        left = None
        right = None
        S = None
        N = None

        def __init__(self, S=None, N=None, D=None):
            self.D = D
            self.S = S
            self.N = N

        def print(self):
            if self.right is not None:
                self.right.printTree(True, "")

            #print(self.D.center)
            print([hex(i) for i in self.D.center])
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
            #print(self.D.center)
            print([hex(i) for i in self.D.center])
            if self.left is not None:
                if isRight:
                    self.left.printTree(False, indent + " |      ")
                else:
                    self.left.printTree(False, indent + "        ")

        def traverse_D(self, point):
            if self.left is None and self.right is None:
                return self.D
            if point <= self.D:
                return self.left.traverse_D(point)
            else:
                return self.right.traverse_D(point)

        def traverse_no_div(self, point):
            if self.left is None and self.right is None:
                return self.D
            if point * self.N <= self.S:
                return self.left.traverse_no_div(point)
            else:
                return self.right.traverse_no_div(point)

        def traverse(self, point, iteration):
            if iteration == 1:
                return self.traverse_D(point)
            return self.traverse_no_div(point)

    class cube:
        def __init__(self):
            self.center = []  # blue,green,red position
            self.relative_center = []  # blue,green,red index
            self.acc = [0, 0, 0]
            self.acc_new = [0, 0, 0]
            self.counter = 0
            self.counter_new = 0
            self.data = []
            self.color = "#{:06x}".format(random.randint(0, 0xFFFFFF))
            self.threshold = 2
            self.stable = False

        def update(self):
            if self.counter_new != 0:
                new_center = [self.acc_new[0] // self.counter_new, self.acc_new[1] // self.counter_new, self.acc_new[2]
                              // self.counter_new]
            else:
                new_center = self.center
            if abs(new_center[0] - self.center[0]) < self.threshold and abs(new_center[1] - self.center[1]) < \
                    self.threshold and abs(new_center[2] - self.center[2]) < self.threshold:
                self.stable = True
            self.center = new_center

        def clear(self):
            self.acc = self.acc_new
            self.counter = self.counter_new
            self.acc_new = [0, 0, 0]
            self.counter_new = 0
            self.data = []

    class row:
        def __init__(self):
            self.center = 0
            self.relative_center = []  # blue,green,red index
            self.acc = 0
            self.counter = 0
            self.data = []
            self.color = "#{:06x}".format(random.randint(0, 0xFFFFFF))
            self.stable = False
            self.threshold = 2

        def update(self):
            new_center = self.acc // self.counter
            if abs(new_center - self.center) < self.threshold:
                self.stable = True
            self.center = new_center

        def clear(self):
            self.acc = 0
            self.counter = 0
            self.data = []

    root = None
    data = []
    means = []
    cubes = []
    r_rows = []
    g_rows = []
    b_rows = []
    trees = []
    kd_tree = []
    # number of dimension splits
    red_segments = 2
    blue_segments = 2
    green_segments = 2

    red_cut_points = []
    green_cut_points = []
    blue_cut_points = []

    red_limits = [255, 0]  # 0 min 1 max
    blue_limits = [255, 0]
    green_limits = [255, 0]

    real_means = []
    real_means_int = []

    cubic_means = []
    data_accumulator = 0
    data_options = mock.Mock()
    iterations = 1
    fnc_calls = 0
    fnc_accumulated = 0
    fnc_counter = 0

    def set_data_options(self, n_samples=100, centers=10, dim=3, min_max=(0, 255), data_center_deviations=10):
        self.data_options.n_samples = n_samples
        self.data_options.centers = centers
        self.data_options.n_features = dim
        self.data_options.center_box = min_max
        self.data_options.cluster_std = data_center_deviations

    def generate_data(self):
        self.clear_dataset()
        X, y, m = make_blobs(n_samples=self.data_options.n_samples, centers=self.data_options.centers,
                             n_features=self.data_options.n_features, center_box=self.data_options.center_box,
                             cluster_std=self.data_options.cluster_std, return_centers=True, random_state=42)
        self.real_means = [[r, g, b] for r, g, b in m]
        self.real_means_int = [[int(round(r, 0)), int(round(g, 0)), int(round(b, 0))] for r, g, b in m]

        for r, g, b in X:
            self.append_point([int(round(r, 0)), int(round(g, 0)), int(round(b, 0))])

    def get_data_from_image(self, filename='testImage.rgb'):
        f = open(filename, "rb")
        red = f.read(1)
        green = f.read(1)
        blue = f.read(1)
        while red:
            r_int = int.from_bytes(red, 'little')
            g_int = int.from_bytes(green, 'little')
            b_int = int.from_bytes(blue, 'little')
            self.append_point([r_int, g_int, b_int])
            red = f.read(1)
            green = f.read(1)
            blue = f.read(1)

    def plot_data(self):
        data = []
        cube_centers_x = []
        cube_centers_y = []
        cube_centers_z = []

        for cube in self.cubes:
            cube_centers_x.append(cube.center[0])
            cube_centers_y.append(cube.center[1])
            cube_centers_z.append(cube.center[2])
            data_x = [r for r, g, b in cube.data]
            data_y = [g for r, g, b in cube.data]
            data_z = [b for r, g, b in cube.data]
            data.append(
                go.Scatter3d(x=data_x, y=data_y, z=data_z, mode='markers', marker=dict(size=3, color=cube.color))
            )

            data.append(
                go.Scatter3d(x=[cube.center[0]], y=[cube.center[1]], z=[cube.center[2]], mode='markers',
                             marker=dict(size=3, color='black'))
            )
        pl = go.Figure(data)

        pl.update_layout(margin=dict(l=0, r=0, b=0, t=0))

        pl.show()

    def clear_dataset(self):
        self.data = []

    def build_tree_midpoint(self, a):
        size = len(a)
        if size == 2:
            x = self.node(D=(a[0] + a[1]) // 2)
            x.left = self.node(D=a[0])
            x.right = self.node(D=a[1])
            return x
        if size == 1:
            return self.node(D=a[0])
        middle = a[len(a) // 2 - 1:len(a) // 2 + 1]
        avg = (middle[0] + middle[1]) // 2
        center = self.node(D=avg)
        center.left = self.build_tree_midpoint(a[0:size // 2])
        center.right = self.build_tree_midpoint(a[size // 2:])

        return center

    def find_rows_by_centers(self, centers, exclude=None):
        r = [i.center for i in self.r_rows]
        g = [i.center for i in self.g_rows]
        b = [i.center for i in self.b_rows]
        c = set(centers)

        if exclude is not None:
            del r[r.index(exclude[0])]
            del g[g.index(exclude[1])]
            del b[b.index(exclude[2])]
        r = set(r)
        g = set(g)
        b = set(b)

        if len(r) == len(r.intersection(c)):
            return self.r_rows
        if len(g) == len(g.intersection(c)):
            return self.g_rows
        if len(b) == len(b.intersection(c)):
            return self.b_rows

        print("ERROR: find_rows_by_centers  cant find the corresponding row !!!")
        print(f"DEBUG: centers : {centers} r : {r} g : {g} b : {b}")
        exit(1)

    def build_kd_tree(self, cubes, dim=3, depth=0):
        if len(cubes) > 1:
            cubes.sort(
                key=lambda x: x.center[depth])
            depth = (depth + 1) % dim
            half = len(cubes) >> 1
            x = self.node()
            x.left = self.build_kd_tree(cubes[:half], dim, depth)
            x.right = self.build_kd_tree(cubes[half + 1:], dim, depth)
            x.D = cubes[half]
            return x
        elif len(cubes) == 1:
            x = self.node()
            x.left = None
            x.right = None
            x.D = cubes[0]
            return x

    def traverse(self, kd_node, point, dim, dist_func, return_distances=False, depth=0, best=None):
        if kd_node is not None:
            self.fnc_calls += 1
            dist = dist_func(point, kd_node.D)
            dx = kd_node.D.acc[depth] - point[depth] * kd_node.D.counter
            if not best:
                best = [dist, kd_node.D]
            elif dist * best[1].counter < best[0] * kd_node.D.counter:
                best[0], best[1] = dist, kd_node.D
            depth = (depth + 1) % dim
            for b in [dx < 0] + [dx >= 0] * (dx + 34230432443242344233 < best[0]):
                if b:
                    self.traverse(kd_node.right, point, dim, dist_func, return_distances, depth, best)
                else:
                    self.traverse(kd_node.left, point, dim, dist_func, return_distances, depth, best)
        return best if return_distances else best[1]

    def build_tree_average(self, centers, exclude=None):
        rows = self.find_rows_by_centers(centers, exclude=exclude)
        return self.build_tree_average_no_div(rows)

    def build_tree_average_main(self, rows):
        size = len(rows)
        if size == 2:
            x = self.node(D=(rows[0].acc + rows[1].acc) // (rows[0].counter + rows[1].counter))
            x.left = self.node(D=rows[0].center)
            x.right = self.node(D=rows[1].center)
            return x

        if size == 1:
            return self.node(D=rows[0].center)
        middle = rows[len(rows) // 2 - 1:len(rows) // 2 + 1]
        avg = (middle[0].acc + middle[1].acc) // (middle[0].counter + middle[1].counter)
        center = self.node(D=avg)
        center.left = self.build_tree_average_main(rows[0:size // 2])
        center.right = self.build_tree_average_main(rows[size // 2:])
        return center

    def build_tree_average_no_div(self, rows):
        size = len(rows)
        if size == 2:
            x = self.node(S=(rows[0].acc + rows[1].acc), N=(rows[0].counter + rows[1].counter))
            x.left = self.node(D=rows[0].center)
            x.right = self.node(D=rows[1].center)
            return x

        if size == 1:
            return self.node(D=rows[0].center)
        middle = rows[len(rows) // 2 - 1:len(rows) // 2 + 1]
        S = (middle[0].acc + middle[1].acc)
        N = (middle[0].counter + middle[1].counter)
        center = self.node(S=S, N=N)
        center.left = self.build_tree_average_no_div(rows[0:size // 2])
        center.right = self.build_tree_average_no_div(rows[size // 2:])
        return center

    def center_to_cube(self, center):
        for c in self.cubes:
            if c.center == center:
                return c

        print("Cant find cube with center : ", center, " in cubes :", [cube.center for cube in self.cubes])
        exit(1)

    def initialize_kd_cubes(self):
        r_cuts = [self.red_limits[0]] + self.red_cut_points + [self.red_limits[1]]
        g_cuts = [self.green_limits[0]] + self.green_cut_points + [self.green_limits[1]]
        b_cuts = [self.blue_limits[0]] + self.blue_cut_points + [self.blue_limits[1]]

        r = [(r_cuts[i + 1] + r_cuts[i]) // 2 for i in range(self.red_segments)]
        g = [(g_cuts[i + 1] + g_cuts[i]) // 2 for i in range(self.green_segments)]
        b = [(b_cuts[i + 1] + b_cuts[i]) // 2 for i in range(self.blue_segments)]

        for i in r:
            for j in g:
                for k in b:
                    cube = self.cube()
                    cube.center = [i, j, k]
                    cube.acc[0] = i
                    cube.acc[1] = j
                    cube.acc[2] = k
                    cube.counter = 1
                    cube.acc_new[0] = i
                    cube.acc_new[1] = j
                    cube.acc_new[2] = k
                    cube.counter_new = 1
                    self.cubes.append(cube)

        self.kd_tree = self.build_kd_tree(self.cubes)

    def initialize_cubes(self):
        r_cuts = [self.red_limits[0]] + self.red_cut_points + [self.red_limits[1]]
        g_cuts = [self.green_limits[0]] + self.green_cut_points + [self.green_limits[1]]
        b_cuts = [self.blue_limits[0]] + self.blue_cut_points + [self.blue_limits[1]]

        r = [(r_cuts[i + 1] + r_cuts[i]) // 2 for i in range(self.red_segments)]
        g = [(g_cuts[i + 1] + g_cuts[i]) // 2 for i in range(self.green_segments)]
        b = [(b_cuts[i + 1] + b_cuts[i]) // 2 for i in range(self.blue_segments)]
        print(r, g, b)

        for i in r:
            r_row = self.row()
            r_row.center = i
            self.r_rows.append(r_row)

        for j in g:
            g_row = self.row()
            g_row.center = j
            self.g_rows.append(g_row)

        for k in b:
            b_row = self.row()
            b_row.center = k
            self.b_rows.append(b_row)

        self.trees.append(self.build_tree_midpoint(r))
        self.trees.append(self.build_tree_midpoint(g))
        self.trees.append(self.build_tree_midpoint(b))

        self.trees[0].print()
        self.trees[1].print()
        self.trees[2].print()

    # main algorithm
    def cluster_data(self):

        # binning
        stable = False
        while not stable:
            stable = True
            red_tree = self.trees[0]
            green_tree = self.trees[1]
            blue_tree = self.trees[2]

            for x in self.data:
                r_center = red_tree.traverse(x[0], self.iterations)
                g_center = green_tree.traverse(x[1], self.iterations)
                b_center = blue_tree.traverse(x[2], self.iterations)
                r_row, g_row, b_row = self.center_to_row([r_center, g_center, b_center])

                r_row.data.append(x)
                r_row.acc += x[0]
                r_row.counter += 1

                g_row.data.append(x)
                g_row.acc += x[1]
                g_row.counter += 1

                b_row.data.append(x)
                b_row.acc += x[2]
                b_row.counter += 1

            r = []
            g = []
            b = []
            # UPDATE THE TREES
            for i in self.r_rows:
                i.update()
                r.append(i.center)
                if not i.stable:
                    stable = False

            for i in self.g_rows:
                i.update()
                g.append(i.center)
                if not i.stable:
                    stable = False

            for i in self.b_rows:
                i.update()
                b.append(i.center)
                if not i.stable:
                    stable = False

            self.trees[0] = self.build_tree_average(r)
            self.trees[1] = self.build_tree_average(g)
            self.trees[2] = self.build_tree_average(b)

            for i in self.r_rows:
                i.clear()
            for i in self.g_rows:
                i.clear()
            for i in self.b_rows:
                i.clear()

            print("#####################################")
            print("Iteration: {0}".format(self.iterations))
            self.trees[0].print()
            self.trees[1].print()
            self.trees[2].print()
            print("#####################################")

            self.iterations += 1
        # after the algorithm done , translate the rows into cubes to plot them
        self.rows_to_cubes()
        true_cubes = []
        for i in range(len(self.cubes)):
            if len(self.cubes[i].data) != 0:
                true_cubes.append(self.cubes[i])

        self.cubes = true_cubes

    def centers_from_cubes(self):
        centers = []
        for cube in self.cubes:
            centers.append(cube.center)
        return centers

    def kd_cluster_data(self):
        # binning
        stable = False
        while not stable:
            self.kd_tree = self.build_kd_tree(self.cubes)
            stable = True
            for cube in self.cubes:
                if cube.counter_new != 0:
                    cube.clear()
            o = open('sample.hex', "w")
            for r, g, b in self.data:
                o.write(f"{r:02x}")
                o.write(f"{g:02x}")
                o.write(f"{b:02x}")
                o.write(" ")
            o.close()
            self.kd_tree.print()
            for x in self.data:
                self.fnc_calls = 0
                cube = self.traverse(self.kd_tree, x, 3, self.manhattan_no_div)
                # print("Point", "[", hex(x[0]), hex(x[1]), hex(x[2]), "]", "Nearest Center", "[", hex(cube.center[0]),
                #       hex(cube.center[1]), hex(cube.center[2]), "]")
                print(f"{x[0]:02x}{x[1]:02x}{x[2]:02x}", "==>", f"{cube.center[0]:02x}{cube.center[1]:02x}"
                                                                  f"{cube.center[2]:02x}")
                print(self.fnc_calls)
                self.fnc_accumulated += self.fnc_calls
                self.fnc_counter += 1
                self.fnc_calls = 0
                # cube = self.center_to_cube(center)
                cube.acc_new[0] += x[0]
                cube.acc_new[1] += x[1]
                cube.acc_new[2] += x[2]
                cube.counter_new += 1
                cube.data.append(x)
            # print(len(self.data))
            fnc_call_average = self.fnc_accumulated / self.fnc_counter
            print(fnc_call_average)
            # input()
            # UPDATE THE TREES
            for i in self.cubes:
                i.update()
                if not i.stable:
                    stable = False

            self.kd_tree = self.build_kd_tree(self.cubes)
            print("#####################################")
            print("Iteration: {0}".format(self.iterations))
            # self.kd_tree.print()
            print("#####################################")
            self.iterations += 1
        # after the algorithm done , translate the rows into cubes to plot them

    def rows_to_cubes(self):
        for r in self.r_rows:
            for g in self.g_rows:
                for b in self.b_rows:
                    c = self.cube()
                    c.center = [r.center, g.center, b.center]
                    self.cubes.append(c)

        for x in self.data:
            r_center = self.trees[0].traverse(x[0], 10)
            g_center = self.trees[1].traverse(x[1], 10)
            b_center = self.trees[2].traverse(x[2], 10)
            cube = self.center_to_cube([r_center, g_center, b_center])
            cube.data.append(x)
            cube.acc[0] += x[0]
            cube.acc[1] += x[1]
            cube.acc[2] += x[2]
            cube.counter += 1

    def center_to_row(self, centers):
        r_row = None
        g_row = None
        b_row = None
        for r in self.r_rows:
            if r.center == centers[0]:
                r_row = r

        for g in self.g_rows:
            if g.center == centers[1]:
                g_row = g

        for b in self.b_rows:
            if b.center == centers[2]:
                b_row = b

        if r_row is None or g_row is None or b_row is None:
            print("error : self.center_to_row  centers:", centers, "r_row :", r_row, "g_row :", g_row, "b_row :", b_row)
            exit(1)

        return r_row, g_row, b_row

    # used for debugging it will show how the point went to its cluster
    def investigate(self, point):
        pass

    # append point to data array
    def append_point(self, point):
        r = point[0]
        g = point[1]
        b = point[2]

        # force the point to be in the first quadrant,
        # we cant control the position of the generated data from sklearn library
        if r < 0:
            r = 0
        if g < 0:
            g = 0
        if b < 0:
            b = 0

        if r < self.red_limits[0]:
            self.red_limits[0] = r

        elif r > self.red_limits[1]:
            self.red_limits[1] = r

        if g < self.green_limits[0]:
            self.green_limits[0] = g

        elif g > self.green_limits[1]:
            self.green_limits[1] = g

        if b < self.blue_limits[0]:
            self.blue_limits[0] = b

        elif b > self.blue_limits[1]:
            self.blue_limits[1] = b

        self.data.append(point)

    def calculate_data_midpoint(self, data=None):
        if data is None:
            data = self.data
        r_acc = 0
        g_acc = 0
        b_acc = 0

        for x in data:
            r_acc += x[0]
            g_acc += x[1]
            b_acc += x[2]

        count = len(data)
        r_avg = r_acc / count
        g_avg = g_acc / count
        b_avg = b_acc / count

        return [r_avg, g_avg, b_avg]

    def divide_space_equally(self, r=4, g=4, b=4):

        self.red_segments = r
        self.green_segments = g
        self.blue_segments = b

        start = self.red_limits[0]
        step = (self.red_limits[1] - self.red_limits[0]) // self.red_segments
        self.red_cut_points = [start + (i + 1) * step for i in range(self.red_segments - 1)]

        start = self.green_limits[0]
        step = (self.green_limits[1] - self.green_limits[0]) // self.green_segments
        self.green_cut_points = [start + (i + 1) * step for i in range(self.green_segments - 1)]

        start = self.blue_limits[0]
        step = (self.blue_limits[1] - self.blue_limits[0]) // self.blue_segments
        self.blue_cut_points = [start + (i + 1) * step for i in range(self.blue_segments - 1)]

        print("red limits :", self.red_limits, "green limits :", self.green_limits, "blue limits :", self.blue_limits)
        print("red cut :", self.red_cut_points, "green cut :", self.green_cut_points, "blue cut :",
              self.blue_cut_points)

        # self.initialize_cubes()
        self.initialize_kd_cubes()

    def manhattan(self, p1, p2):
        return abs(p1[0] - p2[0]) + abs(p1[1] - p2[1]) + abs(p1[2] - p2[2])

    def manhattan_no_div(self, point, cube):
        return abs(cube.counter * point[0] - cube.acc[0]) + abs(cube.counter * point[1] - cube.acc[1]) + abs(
            cube.counter * point[2] - cube.acc[2])

    def euclidean(self, cube, point):
        return math.sqrt((cube.center[0] - point[0]) ** 2 + (cube.center[1] - point[1]) ** 2 +
                         (cube.center[2] - point[2]) ** 2)

    def real_second_closest(self, point, exclude):
        mn = 1000000

        nearest = None
        for c in self.cubes:
            if c.center == exclude.center:
                continue

            d = self.euclidean(c, point)
            # print(f"D is {d}")
            if mn > d:
                nearest = c
                mn = d
                # print(f"nearest is {nearest.center}")

        return nearest

    def write_segmented_image(self, outfile='testImageOut.rgb'):
        o = open(outfile, "wb")
        for x in self.data:
            cube = self.traverse(self.kd_tree, x, 3, self.manhattan_no_div)
            r_center = cube.center[0]
            g_center = cube.center[1]
            b_center = cube.center[2]
            o.write(r_center.to_bytes(1, 'little'))
            o.write(g_center.to_bytes(1, 'little'))
            o.write(b_center.to_bytes(1, 'little'))
        o.close()

    def silhouette_coefficient(self):
        sil_accum = 0
        sil_cofs = []
        misclassified = []
        for cube in self.cubes:
            for point in cube.data:
                second_nearest = self.real_second_closest(point, cube)
                next_r = second_nearest.center[0]
                next_g = second_nearest.center[1]
                next_b = second_nearest.center[2]
                a_i = self.manhattan(cube.center, point)
                b_i = self.manhattan([next_r, next_g, next_b], point)
                sil_coefficient = (b_i - a_i) / max(a_i, b_i)
                sil_cofs.append(sil_coefficient)
                if sil_coefficient < 0:
                    misclassified.append(sil_coefficient)
                sil_accum += sil_coefficient
        plt.hist(sil_cofs, bins=60)
        plt.title('Histogram of Silhouette Coefficients for an image')
        plt.xlabel("Silhouette Coefficients")
        plt.ylabel("Frequency")
        plt.show()
        print("Average Silhouette Coefficient = ", sil_accum / len(sil_cofs))
        print("Percentage of misclassified points = ", len(misclassified) / len(sil_cofs) * 100)
        print("K = ", len(self.cubes))

    def cuts_on_axis(self):
        r_mid = sorted(set([cube.center[0] for cube in self.cubes]))
        g_mid = sorted(set([cube.center[1] for cube in self.cubes]))
        b_mid = sorted(set([cube.center[2] for cube in self.cubes]))
        print(r_mid, g_mid, b_mid)

        r_cuts = [(i + j) // 2 for i, j in zip(r_mid, r_mid[1:])]
        g_cuts = [(i + j) // 2 for i, j in zip(g_mid, g_mid[1:])]
        b_cuts = [(i + j) // 2 for i, j in zip(b_mid, b_mid[1:])]
        print(r_cuts, g_cuts, b_cuts)
        return r_cuts, g_cuts, b_cuts

    def printTree(self):
        self.root.print()


###########################################################################################
r, g, b = 10, 10, 10
x = Tree()
x.set_data_options(n_samples=10000, centers=1000, dim=3, min_max=(10, 240), data_center_deviations=10)
x.generate_data()
# x.get_data_from_image(filename="testImage.rgb")
x.divide_space_equally(r, g, b)
# x.cluster_data()
x.kd_cluster_data()
# x.write_segmented_image()
# x.plot_data()
x.silhouette_coefficient()
print("Number of iterations: ", x.iterations)
print(x.centers_from_cubes())
print(r, g, b)
fnc_call_average = x.fnc_accumulated / x.fnc_counter
print(fnc_call_average)
###########################################################################################
# %%
