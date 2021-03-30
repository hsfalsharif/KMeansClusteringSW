from sklearn.datasets import make_blobs

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
            self.data = []
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
            self.data = []

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

    def initilize_clusters(self):
        for i in range(self.k):
            c = self.cluster()
            val = i*(255//self.k)
            c.center = [val,val,val]
            self.clusters.append(c)

    def square_dist(self,c,p):
        return (c.center[0]-p[0])**2 + (c.center[1]-p[1])**2 + (c.center[2]-p[2])**2 
    
    def find_cluster(self,point):
        min_dist = 100000000
        closer = None
        for c in self.clusters:
            d = self.square_dist(c,point)
            if  d < min_dist :
                min_dist = d
                closer = c
            
        return closer




    def cluster_data(self):

        stable = True
        it = 1
        while stable:
            stable = False
            
            for x in self.data:
                c = self.find_cluster(x)
                print(f"point {x} to cluster [{self.clusters.index(c)}] {c.center}")
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
                print(f"[{self.clusters.index(c)}] cluster at {c.center} counter {c.counter} acc {c.acc}")

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






machine = general_kmean()

machine.k = 16
machine.n_samples = 100
machine.centers = 10
machine.n_features = 3
machine.center_box = (10,240)
machine.cluster_std = 10

machine.generate_data()
machine.initilize_clusters()
machine.cluster_data()
machine.data_to_hexfile("test.hex")





        