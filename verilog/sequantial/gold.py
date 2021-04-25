from sklearn.datasets import make_blobs
from math import sqrt
import mock
import plotly.graph_objects as go
import matplotlib.pyplot as plt
import random

class general_kmean:
    class cluster:
        def __init__(self):
            self.center = []  # blue,green,red position
            self.relative_center = []  # blue,green,red index
            self.acc = [0, 0, 0]
            self.counter = 0
            self.data = []
            self.threshold = 2
            self.stable = False
        def update(self):
            self.stable = False
            #self.data = []
            if self.counter != 0:
                new_center = [self.acc[0] // self.counter, self.acc[1] // self.counter, self.acc[2]
                              // self.counter]
            else:
                new_center = self.center
            if abs(new_center[0] - self.center[0]) < self.threshold and abs(new_center[1] - self.center[1]) < \
                    self.threshold and abs(new_center[2] - self.center[2]) < self.threshold:
                self.stable = True
            print(self.center, new_center)
            self.center = new_center

            self.counter = 0
            self.acc = [0,0,0]
            #self.data = []

    data = []
    real_means = []
    real_means_int = []
    clusters = []
    k = 200
    n_samples = 0
    centers = 0
    n_features = 0
    center_box = (0,0)
    cluster_std = 0

    def generate_data(self):
        X, y, m = make_blobs(n_samples=self.n_samples, centers=self.centers,
                             n_features=self.n_features, center_box=self.center_box,
                             cluster_std=self.cluster_std, return_centers=True)
        self.real_means = [[r, g, b] for r, g, b in m]
        self.real_means_int = [[int(round(r, 0)), int(round(g, 0)), int(round(b, 0))] for r, g, b in m]

        for r, g, b in X:
            self.data.append([min(max(int(round(r, 0)),0),255), min(max(int(round(b, 0)),0),255), min(max(int(round(g, 0)),0),255)])

    def initilize_clusters(self,m):
        
        if m is None:
            for i in range(self.k):
                c = self.cluster()
                val = i*(255//self.k)
                c.center = [val,val,val]
                self.clusters.append(c)
        else:
            for i in m:
                c = self.cluster()
                c.center = i
                self.clusters.append(c)


    def square_dist(self,c,p):
        return (c.center[0]-p[0])**2 + (c.center[1]-p[1])**2 + (c.center[2]-p[2])**2 
    
    def man(self,c,p):
        return abs(c.center[0]-p[0]) + abs(c.center[1]-p[1]) + abs(c.center[2]-p[2]) 
    def find_cluster(self,point):
        min_dist = 100000000
        closer = None
        for c in self.clusters:
            d = self.man(c,point)
            if  d <= min_dist :
                min_dist = d
                closer = c
            
        return closer




    def cluster_data(self):

        stable = True
        it = 1
        while stable:
            stable = False
            
            for i in self.clusters:
                i.data = []
            for x in self.data:
                c = self.find_cluster(x)
                #print(f"point {[hex(i) for i in x]} to cluster [{self.clusters.index(c)}] {[hex(i) for i in c.center]}")
                c.acc[0] += x[0]
                c.acc[1] += x[1]
                c.acc[2] += x[2]
                c.counter += 1
                c.data.append(x)
                for i in x:
                    if i > 0xff:
                        print(f"ERRRRRROR {x}")
                        exit()
            print(f"########### {it} ###########")
            for c in self.clusters:
                print(f"[{self.clusters.index(c)}] cluster at {[hex(i) for i in c.center]} counter {c.counter} acc {[hex(i) for i in c.acc]}")

            print(f"###########      ###########")
            for c in self.clusters:
                c.update()
                if c.stable == False:
                    stable = True
            it += 1            
    def data_to_hexfile(self,filename):
        o = open(filename,"w")
        for r,g,b in self.data :
            o.write(f"{r:02x}")
            o.write(f"{g:02x}")
            o.write(f"{b:02x}")
            o.write(" ")
    def data_to_binary_file(self,filename):
        o = open(filename,"wb")
        for x in self.data :
            c = self.find_cluster(x)
            o.write(bytes(c.center))   
            print(f"writing {x} as {c.center} {bytes(c.center)}")
        o.close()
    def means_from_file(self,filename):
        f = open(filename,"r")
        lines = list(f)
        means = []
        for m in lines:
            means.append(self.hex_string_to_arr(m))
        self.initilize_clusters(means)
    
    
    def assign_points_to_clusters_from_file(self,filename):
        f = open(filename,"r")
        lines = list(f)
        for l in lines:
            point,cluster = l.split(" ==> ")
            point   = self.hex_string_to_arr(point)
            cluster = self.hex_string_to_arr(cluster)
            self.accomulate(point,cluster)
            self.data.append(point)

    def hex_string_to_arr(self,m):
        return [int(m[0:2],16),int(m[2:4],16),int(m[4:6],16)]

    def accomulate(self,x,cluster):
        for c in self.clusters:
            if c.center == cluster :
                c.acc[0] += x[0]
                c.acc[1] += x[1]
                c.acc[2] += x[2]
                c.counter += 1
                c.data.append(x)
                return
        
        print(f"ERROR CANT FIND CLUSTER : {cluster}")
        return
        
    def silhouette_coefficient(self):
        sil_accum = 0
        sil_cofs = []
        misclassified = []
        for cube in self.clusters:
            print(len(cube.data))
            for point in cube.data:
                second_nearest = self.real_second_closest(point, cube)
                next_r = second_nearest.center[0]
                next_g = second_nearest.center[1]
                next_b = second_nearest.center[2]
                a_i = self.euclidean(cube, point)
                b_i = self.euclidean(second_nearest, point)
                sil_coefficient = (b_i - a_i) / max(a_i, b_i)
                sil_cofs.append(sil_coefficient)
                if sil_coefficient < 0:
                    print(f"{[hex(i) for i in second_nearest.center]} is closer to {[hex(i) for i in point]} than {[hex(i) for i in cube.center]} distance {[(i-j) for i,j in zip(point,second_nearest.center)]} {self.man(second_nearest,point)} : {[(i-j) for i,j in zip(point,cube.center)]}{self.man(cube,point)}")
                    misclassified.append(sil_coefficient)
                sil_accum += sil_coefficient
        plt.hist(sil_cofs, bins=60)
        plt.title('Histogram of Silhouette Coefficients for an image')
        plt.xlabel("Silhouette Coefficients")
        plt.ylabel("Frequency")
        plt.show()
        print("Average Silhouette Coefficient = ", sil_accum / len(sil_cofs))
        print("Percentage of misclassified points = ", len(misclassified) / len(sil_cofs) * 100)
        print("K = ", len(self.clusters))

    def real_second_closest(self, point, exclude):
        mn = 1000000
        nearest = None
        for c in self.clusters:
            if c.center == exclude.center:
                continue
            d = self.euclidean(c, point)
            # print(f"D is {d}")
            if mn > d:
                nearest = c
                mn = d
                # print(f"nearest is {nearest.center}")
        return nearest
    def euclidean(self, cube, point):
        return sqrt((cube.center[0] - point[0]) ** 2 + (cube.center[1] - point[1]) ** 2 +
                      (cube.center[2] - point[2]) ** 2)
    def data_from_file(self,filename):
        f = open(filename,"r")
        lines = list(f)
        for l in lines:
            point = l
            point = self.hex_string_to_arr(point)
            self.data.append(point)
    def get_data_from_image(self, filename='testImage.rgb'):
        f = open(filename, "rb")
        red = f.read(1)
        green = f.read(1)
        blue = f.read(1)
        while red:
            r_int = int.from_bytes(red, 'little')
            g_int = int.from_bytes(green, 'little')
            b_int = int.from_bytes(blue, 'little')
            self.data.append([r_int, g_int, b_int])
            red = f.read(1)
            green = f.read(1)
            blue = f.read(1)





machine = general_kmean()

machine.k = 14
machine.n_samples = 100
machine.centers = 10
machine.n_features = 3
machine.center_box = (10,240)
machine.cluster_std = 10
#c = [[0x80,0x1e,0x2c],[0x80,0x1e,0xd3],[0x80,0x1e,0x7f],[0x80,0x80,0x2c],[0x80,0x4f,0xd3],[0x80,0x4f,0x7f],[0x80,0x4f,0x2c],[0x80,0xb1,0x2c],[0x80,0x80,0xd3],[0x80,0xb1,0x7f],[0x80,0xe4,0x2c],[0x80,0xe4,0xd3], [0x80,0xe4,0x7f],[0x80,0xb1,0xd3],[0x80,0x80,0x7f],]

#machine.generate_data()
#machine.initilize_clusters(c)
#machine.data_to_hexfile("test.hex")
machine.means_from_file("kd_tree/output/14_mean_out.txt")
machine.assign_points_to_clusters_from_file("kd_tree/output/14_point_to_mean.txt")

#machine.data_from_file("kd_tree/output/14_point_to_mean.txt")
#machine.cluster_data()
machine.data_to_binary_file("kd_out.rgb")
machine.silhouette_coefficient()

#x = [i.center for i in machine.clusters]
#z = [[hex(r),hex(g),hex(b)] for r,g,b in x]
#print(z)
