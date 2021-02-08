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

        def __init__(self, D):
            self.D = D

        def print(self):
            if self.right is not None:
                self.right.printTree(True, "")

            print(self.D)
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
            print(self.D)
            if self.left is not None:
                if isRight:
                    self.left.printTree(False, indent + " |      ")
                else:
                    self.left.printTree(False, indent + "        ")

        def traverse(self, point):
            if self.left is None and self.right is None:
                return self.D
            if point <= self.D:
                return self.left.traverse(point)
            else:
                return self.right.traverse(point)

    class cube:
        def __init__(self):
            self.center = []  # blue,green,red position
            self.relative_center = []  # blue,green,red index
            self.acc = [0, 0, 0]
            self.counter = 0
            self.data = []
            self.color = "#{:06x}".format(random.randint(0, 0xFFFFFF))

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
    data_accumolator = 0
    data_options = mock.Mock()

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
                             cluster_std=self.data_options.cluster_std, return_centers=True)
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
        m = 1
        r_cuts, g_cuts, b_cuts = self.cuts_on_axis()
        red_dividers = [go.Mesh3d(
            # 8 vertices of a cube
            x=[i - m, i - m, i + m, i + m, i - m, i + m, i - m, i - m],
            y=[self.data_options.center_box[0], self.data_options.center_box[1], self.data_options.center_box[1],
               self.data_options.center_box[0], self.data_options.center_box[0], self.data_options.center_box[1],
               self.data_options.center_box[1], self.data_options.center_box[0]],
            z=[self.data_options.center_box[0], self.data_options.center_box[0], self.data_options.center_box[1],
               self.data_options.center_box[1], self.data_options.center_box[0], self.data_options.center_box[0],
               self.data_options.center_box[1], self.data_options.center_box[1]],
            colorbar_title='z',
            colorscale=[[0, 'red'], [1, 'red']],
            intensity=[1],
            intensitymode='cell',
            name='red divider',
            showscale=False,
            opacity=0.09
        ) for i in r_cuts]

        green_dividers = [go.Mesh3d(
            # 8 vertices of a cube
            y=[i - m, i - m, i + m, i + m, i - m, i + m, i - m, i - m],
            x=[self.data_options.center_box[0], self.data_options.center_box[1], self.data_options.center_box[1],
               self.data_options.center_box[0], self.data_options.center_box[0], self.data_options.center_box[1],
               self.data_options.center_box[1], self.data_options.center_box[0]],
            z=[self.data_options.center_box[0], self.data_options.center_box[0], self.data_options.center_box[1],
               self.data_options.center_box[1], self.data_options.center_box[0], self.data_options.center_box[0],
               self.data_options.center_box[1], self.data_options.center_box[1]],
            colorbar_title='z',
            colorscale=[[0, 'green'], [1, 'green']],
            intensity=[1],
            intensitymode='cell',
            name='green divider',
            showscale=False,
            opacity=0.09
        ) for i in g_cuts]

        blue_dividers = [go.Mesh3d(
            # 8 vertices of a cube
            z=[i - m, i - m, i + m, i + m, i - m, i + m, i - m, i - m],
            y=[self.data_options.center_box[0], self.data_options.center_box[1], self.data_options.center_box[1],
               self.data_options.center_box[0], self.data_options.center_box[0], self.data_options.center_box[1],
               self.data_options.center_box[1], self.data_options.center_box[0]],
            x=[self.data_options.center_box[0], self.data_options.center_box[0], self.data_options.center_box[1],
               self.data_options.center_box[1], self.data_options.center_box[0], self.data_options.center_box[0],
               self.data_options.center_box[1], self.data_options.center_box[1]],
            colorbar_title='z',
            colorscale=[[0, 'blue'], [1, 'blue']],
            intensity=[1],
            intensitymode='cell',
            name='blue divider',
            showscale=False,
            opacity=0.09
        ) for i in b_cuts]

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
            go.Scatter3d(x=cube_centers_x, y=cube_centers_y, z=cube_centers_z, mode='markers',
                         marker=dict(size=3, color='gold'))
        )

        data = data + red_dividers + green_dividers + blue_dividers
        pl = go.Figure(data)

        pl.update_layout(margin=dict(l=0, r=0, b=0, t=0))

        pl.show()

    def clear_dataset(self):
        self.data = []

    def build_tree_midpoint(self, a):
        size = len(a)
        if size == 2:
            x = self.node((a[0] + a[1]) // 2)
            x.left = self.node(a[0])
            x.right = self.node(a[1])
            return x
        if size == 1:
            return self.node(a[0])
        middle = a[len(a) // 2 - 1:len(a) // 2 + 1]
        avg = (middle[0] + middle[1]) // 2
        center = self.node(avg)
        center.left = self.build_tree_midpoint(a[0:size // 2])
        center.right = self.build_tree_midpoint(a[size // 2:])

        return center

    def find_rows_by_centers(self,centers):
        r = set([i.center for i in self.r_rows])
        g = set([i.center for i in self.g_rows])
        b = set([i.center for i in self.b_rows])
        c = set(centers)

        if len(r) == len(r.intersection(c)): return self.r_rows
        if len(g) == len(g.intersection(c)): return self.g_rows
        if len(r) == len(b.intersection(c)): return self.b_rows

        print("ERROR: find_rows_by_centers  cant find the corrsponding row !!!")
        print(f"DEBUG: centers : {centers} r : {r} g : {g} b : {b}")
        exit(1)
        


    def build_tree_average(self, centers):
        rows = self.find_rows_by_centers(centers)
        return self.build_tree_average_main(rows)

    def build_tree_average_main(self, rows):
        size = len(rows)
        if size == 2:
            x = self.node((rows[0].acc + rows[1].acc) // (rows[0].counter + rows[1].counter))
            x.left = self.node(rows[0].center)
            x.right = self.node(rows[1].center)
            return x

        if size == 1:
            return self.node(rows[0].center)
        middle = rows[len(rows) // 2 - 1:len(rows) // 2 + 1]
        avg = (middle[0].acc + middle[1].acc) // (middle[0].counter + middle[1].counter)
        center = self.node(avg)
        center.left = self.build_tree_average_main(rows[0:size // 2])
        center.right = self.build_tree_average_main(rows[size // 2:])
        return center

    def center_to_cube(self, center):
        for c in self.cubes:
            if c.center == center:
                return c

        print("Cant find cube with center : ", center, " in cubes :", [cube.center for cube in self.cubes])
        exit(1)

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
        ## we cant use the row average becuase all rows are empty!!!
        # fall back to mid average in the initialization 
        #self.trees.append(self.build_tree_average(r))
        #self.trees.append(self.build_tree_average(g))
        #self.trees.append(self.build_tree_average(b))
        self.trees.append(self.build_tree_midpoint(r))
        self.trees.append(self.build_tree_midpoint(g))
        self.trees.append(self.build_tree_midpoint(b))
        
        
        self.trees[0].print()
        self.trees[1].print()
        self.trees[2].print()

    # main algorithm
    def cluster_data(self):

        # binning
        itr = 1
        stable = False
        while not stable:
            stable = True
            red_tree = self.trees[0]
            green_tree = self.trees[1]
            blue_tree = self.trees[2]

            for x in self.data:
                r_center = red_tree.traverse(x[0])
                g_center = green_tree.traverse(x[1])
                b_center = blue_tree.traverse(x[2])
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
            print("Iteration: {0}".format(itr))
            self.trees[0].print()
            self.trees[1].print()
            self.trees[2].print()
            print("#####################################")

            itr += 1
        # after the algorithm done , translate the rows into cubes to plot them  
        self.rows_to_cubes()
        true_cubes = []
        for i in range(len(self.cubes)):
            if len(self.cubes[i].data) != 0:
                true_cubes.append(self.cubes[i])

        self.cubes = true_cubes

    #
    # cube = self.center_to_cube([r_center,g_center,b_center])
    # cube.data.append(x)
    # cube.acc[0] += x[0]
    # cube.acc[1] += x[1]
    # cube.acc[2] += x[2]
    # cube.counter += 1

    # Check if zero cluster
    # update the space dividers
    #

    def rows_to_cubes(self):
        for r in self.r_rows:
            for g in self.g_rows:
                for b in self.b_rows:
                    c = self.cube()
                    c.center = [r.center, g.center, b.center]
                    self.cubes.append(c)

        for x in self.data:
            r_center = self.trees[0].traverse(x[0])
            g_center = self.trees[1].traverse(x[1])
            b_center = self.trees[2].traverse(x[2])
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

        self.initialize_cubes()

    def next_closest_mean_index(self, r, g, b, centre_r, centre_g, centre_b):
        next_means_r = [r.center for r in self.r_rows]
        next_means_g = [g.center for g in self.g_rows]
        next_means_b = [b.center for b in self.b_rows]
        del next_means_r[next_means_r.index(centre_r)]
        del next_means_g[next_means_g.index(centre_g)]
        del next_means_b[next_means_b.index(centre_b)]
        next_means_r_tree = self.build_tree_midpoint(next_means_r)
        next_means_g_tree = self.build_tree_midpoint(next_means_g)
        next_means_b_tree = self.build_tree_midpoint(next_means_b)
        red_mean = next_means_r_tree.traverse(r)
        green_mean = next_means_g_tree.traverse(g)
        blue_mean = next_means_b_tree.traverse(b)
        return red_mean, green_mean, blue_mean

    def silhouette_coefficient(self):
        sil_accum = 0
        sil_cofs = []
        for cube in self.cubes:
            for point in cube.data:
                next_r, next_g, next_b = self.next_closest_mean_index(point[0], point[1], point[2], cube.center[0],
                                                                      cube.center[1], cube.center[2])
                a_i = math.sqrt((cube.center[0] - point[0]) ** 2 + (cube.center[1] - point[1]) ** 2 +
                                (cube.center[2] - point[2]) ** 2)
                b_i = math.sqrt((next_r - point[0]) ** 2 + (next_g - point[1]) ** 2 +
                                (next_b - point[2]) ** 2)
                sil_coefficient = (b_i - a_i) / max(a_i, b_i)
                sil_cofs.append(sil_coefficient)
                if sil_coefficient < 0:
                    print(sil_coefficient)
                sil_accum += sil_coefficient
        plt.hist(sil_cofs, bins=60)
        plt.title('Histogram of Silhouette Coefficients for an image')
        plt.xlabel("Silhouette Coefficients")
        plt.ylabel("Frequency")
        plt.show()
        print("Average Silhouette Coefficient = ", sil_accum / len(sil_cofs))

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
x = Tree()
x.set_data_options(n_samples=10000, centers=64, dim=3, min_max=(0, 255), data_center_deviations=100)
x.generate_data()
# x.get_data_from_image(filename='testImage.rgb')
x.divide_space_equally(2, 3, 2)
x.cluster_data()
x.plot_data()
x.silhouette_coefficient()
###########################################################################################
# %%
