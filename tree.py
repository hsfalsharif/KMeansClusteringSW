#%%
from sklearn.datasets import make_blobs
from matplotlib import pyplot
#import matplotlib.pyplot as plt
import mock
import plotly.graph_objects as go

class Tree:
    class node:
        D = None
        left = None
        right = None
        def print(self):
            if self.right != None :
                self.right.printTree(True, "")
            
            print(self.D)
            if self.left != None: 
                self.left.printTree(False, "")
        
        def printTree(self, isRight, indent):
            if self.right != None:
                if isRight:
                    self.right.printTree(True, indent + "        " )
                else :
                    self.right.printTree(True, indent + " |      ")

            
            print(indent,end="")
            if isRight: 
                print(" /",end="")
            else :
                print(" \\",end="")
            
            print("----- ",end="")
            print(self.D)
            if self.left != None:
                if isRight:
                    self.left.printTree(False, indent + " |      " )
                else :
                    self.left.printTree(False, indent + "        ")
    class cube:
        center = [] # blue,green,red position
        relative_center = [] # blue,green,red index
        acc = None
        counter = None
        data = []

    root = None
    data = []
    means = []
    cubes = []
    # number of dimention splits
    red_segments = 0
    blue_segemnts = 0
    green_segments = 0
    red_limits = [255,0] # 0 min 1 max
    blue_limits = [255,0]
    green_limits = [255,0]
    real_means = []
    real_means_int = []
    data_accumolator = 0
    data_options = mock.Mock()
    def set_data_options(self,n_samples=100, centers=10, dim=3, min_max=(0,255),data_center_divations=10):
        self.data_options.n_samples = n_samples
        self.data_options.centers = centers
        self.data_options.n_features = dim
        self.data_options.center_box = min_max
        self.data_options.cluster_std = data_center_divations

    def generate_data(self):
        self.clear_dataset()
        X, y,m = make_blobs(n_samples=self.data_options.n_samples,centers= self.data_options.centers,n_features= self.data_options.n_features,center_box= self.data_options.center_box,cluster_std= self.data_options.cluster_std,return_centers=True)
        self.real_means = [[r,g,b] for r,g,b in m]
        self.real_means_int = [[int(round(r,0)),int(round(g,0)),int(round(b,0))] for r,g,b in m]

        for r,g,b in X:
            self.append_point([int(round(r,0)),int(round(g,0)),int(round(b,0))])

    def plot_data(self,data=None):
        if data is None:
            data = self.data
        fig = plt.figure()
        ax = plt.axes(projection='3d')
        # Not efficent but if it is stupid and work then it is not stupid
        r_data = [r for r,g,b in self.data]
        g_data = [g for r,g,b in self.data]
        b_data = [b for r,g,b in self.data]
        # Note use INTEGER MEANS
        r_mean_exact = [r for r,g,b in self.real_means_int]
        g_mean_exact = [g for r,g,b in self.real_means_int]
        b_mean_exact = [b for r,g,b in self.real_means_int]

        ax.scatter3D(r_data, g_data, b_data)
        ax.scatter3D(r_mean_exact,g_mean_exact,b_mean_exact)

        pl = go.Figure(
            data=[
                go.Scatter3d(x=r_data,y=g_data,z=b_data,mode='markers',marker=dict(size=3,)),
                go.Scatter3d(x=r_mean_exact,y=g_mean_exact,z=b_mean_exact,mode='markers',marker=dict(size=3,color='red')),

                ]
            )

        #pl = px.scatter_3d(x=r_data, y=g_data, z=b_data)
        pl.update_layout(margin=dict(l=0, r=0, b=0, t=0))

        pl.show()



    def clear_dataset(self):
        self.data = []
    def build_tree_breadthfirst(self,arr):
        pass
    def build_tree_average(self):
        pass
    def calculate_data_average(self):
        pass
    # give it a mean and it will return the cube that contains the mean 
    def mean_to_cube(self,mean):
        pass
    # give it any point in a cube it will return the mean inside that cube
    def cube_to_mean(self,point):
        pass
    # give it a data point it will accumlate it's containing cube 
    def accumolate(self,point):
        pass
    def initilze_cubes(self):
        pass
    # main algorithem
    def cluster_data(self):
        pass
    # loop over the cubes array and update the means
    def update_means(self):
        pass
    # used for debugging it will show how the point went to its cluster
    def investigate(self,point):
        pass
    # append point to data array
    def append_point(self,point):
        r = point[0]
        g = point[1]
        b = point[2]

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


    def cubes_on_axis(self,axis):
        pass
    def printTree(self):
        self.root.print()
    
##########################################################################################
x = Tree()
x.set_data_options(n_samples=1000,centers=20,dim=3,min_max=(0,255),data_center_divations=10)
x.generate_data()
x.plot_data()
##########################################################################################
# %%
