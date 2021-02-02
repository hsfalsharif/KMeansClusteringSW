#%%
from sklearn.datasets import make_blobs
#from matplotlib import pyplot
#import matplotlib.pyplot as plt
import mock
import plotly.graph_objects as go






# option 1 : axis dividers are always the same but the mean inside them change postion within the cube
# option 2 : the axis dividers are the middle point between each mean BUT this mean that the means are not aligned in one axis therefore the tree will not work
# option 3 : the tree will hold data information not postion it will just filter the posiblilty to sub-means

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
    red_segments   = 4
    blue_segments  = 4
    green_segments = 4

    red_cut_points = []
    green_cut_points = []
    blue_cut_points = []

    red_limits = [255,0] # 0 min 1 max
    blue_limits = [255,0]
    green_limits = [255,0]

    real_means = []
    real_means_int = []

    cubic_means = []
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
        #fig = plt.figure()
        #ax = plt.axes(projection='3d')
        # Not efficent but if it is stupid and work then it is not stupid
        r_data = [r for r,g,b in self.data]
        g_data = [g for r,g,b in self.data]
        b_data = [b for r,g,b in self.data]
        # Note use INTEGER MEANS
        r_mean_exact = [r for r,g,b in self.real_means_int]
        g_mean_exact = [g for r,g,b in self.real_means_int]
        b_mean_exact = [b for r,g,b in self.real_means_int]


        r_cubic_means = [r for r,g,b in self.cubic_means]
        g_cubic_means = [g for r,g,b in self.cubic_means]
        b_cubic_means = [b for r,g,b in self.cubic_means]

        #ax.scatter3D(r_data, g_data, b_data)
        #ax.scatter3D(r_mean_exact,g_mean_exact,b_mean_exact)
        m = 1
        red_dividers = [go.Mesh3d(
                            # 8 vertices of a cube
                            x=[i-m,i-m,i+m,i+m,i-m,i+m,i-m,i-m],
                            y=[self.data_options.center_box[0],self.data_options.center_box[1],self.data_options.center_box[1],self.data_options.center_box[0],self.data_options.center_box[0],self.data_options.center_box[1],self.data_options.center_box[1],self.data_options.center_box[0]],
                            z=[self.data_options.center_box[0],self.data_options.center_box[0],self.data_options.center_box[1],self.data_options.center_box[1],self.data_options.center_box[0],self.data_options.center_box[0],self.data_options.center_box[1],self.data_options.center_box[1]],
                            colorbar_title='z',
                            colorscale=[[0, 'red'],[1, 'red']],
                            intensity = [1],
                            intensitymode='cell',
                            name='red divider',
                            showscale=False,
                            opacity=0.09
                         ) for i in self.red_cut_points]
 
        green_dividers = [go.Mesh3d(
                            # 8 vertices of a cube
                            y=[i-m,i-m,i+m,i+m,i-m,i+m,i-m,i-m],
                            x=[self.data_options.center_box[0],self.data_options.center_box[1],self.data_options.center_box[1],self.data_options.center_box[0],self.data_options.center_box[0],self.data_options.center_box[1],self.data_options.center_box[1],self.data_options.center_box[0]],
                            z=[self.data_options.center_box[0],self.data_options.center_box[0],self.data_options.center_box[1],self.data_options.center_box[1],self.data_options.center_box[0],self.data_options.center_box[0],self.data_options.center_box[1],self.data_options.center_box[1]],
                            colorbar_title='z',
                            colorscale=[[0, 'green'],[1, 'green']],
                            intensity = [1],
                            intensitymode='cell',
                            name='green divider',
                            showscale=False,
                            opacity=0.09
                         ) for i in self.green_cut_points]

        blue_dividers = [go.Mesh3d(
                            # 8 vertices of a cube
                            z=[i-m,i-m,i+m,i+m,i-m,i+m,i-m,i-m],
                            y=[self.data_options.center_box[0],self.data_options.center_box[1],self.data_options.center_box[1],self.data_options.center_box[0],self.data_options.center_box[0],self.data_options.center_box[1],self.data_options.center_box[1],self.data_options.center_box[0]],
                            x=[self.data_options.center_box[0],self.data_options.center_box[0],self.data_options.center_box[1],self.data_options.center_box[1],self.data_options.center_box[0],self.data_options.center_box[0],self.data_options.center_box[1],self.data_options.center_box[1]],
                            colorbar_title='z',
                            colorscale=[[0, 'blue'],[1, 'blue']],
                            intensity = [1],
                            intensitymode='cell',
                            name='blue divider',
                            showscale=False,
                            opacity=0.09
                        )  for i in self.blue_cut_points]
        
        data=[
                go.Scatter3d(x=r_data,y=g_data,z=b_data,mode='markers',marker=dict(size=3,)),
                go.Scatter3d(x=r_mean_exact,y=g_mean_exact,z=b_mean_exact,mode='markers',marker=dict(size=3,color='red')),                
                go.Scatter3d(x=r_cubic_means,y=g_cubic_means,z=b_cubic_means,mode='markers',marker=dict(size=3,color='gold')),

            ]
        data = data + red_dividers + green_dividers + blue_dividers
        pl = go.Figure(data)

        #pl = px.scatter_3d(x=r_data, y=g_data, z=b_data)
        pl.update_layout(margin=dict(l=0, r=0, b=0, t=0))

        pl.show()



    def clear_dataset(self):
        self.data = []
    def build_tree_breadthfirst(self,arr):
        pass
    def build_tree_average(self):
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
        r_cuts = [self.red_limits[0]] + self.red_cut_points + [self.red_limits[1]]
        g_cuts = [self.green_limits[0]] + self.green_cut_points + [self.green_limits[1]]
        b_cuts = [self.blue_limits[0]] + self.blue_cut_points + [self.blue_limits[1]]

        r = [(r_cuts[i + 1] + r_cuts[i]) // 2 for i in range(self.red_segments)]
        g = [(g_cuts[i + 1] + g_cuts[i]) // 2 for i in range(self.green_segments)]
        b = [(b_cuts[i + 1] + b_cuts[i]) // 2 for i in range(self.blue_segments)]
        print(r,g,b)
        for i in r:
            for j in g:
                for k in b:
                    self.cubic_means.append([i,j,k])
        
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

        # force the point to be in the first quadrant, 
        # we cant control the position of the generated data from sklearn library
        if r < 0: r = 0
        if g < 0: g = 0
        if b < 0: b = 0

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
    def calculate_data_average(self,data=None):
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

        return [r_avg,g_avg,b_avg]

    def divide_space_equally(self,r=4,g=4,b=4):

        self.red_segments   = r
        self.green_segments = g
        self.blue_segments  = b

        
        start = self.red_limits[0]
        step = (self.red_limits[1]-self.red_limits[0]) // self.red_segments
        self.red_cut_points = [start+(i+1)*step for i in range(self.red_segments -1)]

        start = self.green_limits[0]
        step = (self.green_limits[1]-self.green_limits[0]) // self.green_segments
        self.green_cut_points = [start+(i+1)*step for i in range(self.green_segments -1)]

        start = self.blue_limits[0]
        step = (self.blue_limits[1]-self.blue_limits[0]) // self.blue_segments
        self.blue_cut_points = [start+(i+1)*step for i in range(self.blue_segments -1)]

        print("red limits :",self.red_limits,"green limits :",self.green_limits,"blue limits :",self.blue_limits)
        print("red cut :",self.red_cut_points ,"green cut :",self.green_cut_points ,"blue cut :",self.blue_cut_points)

        self.initilze_cubes()


    def cubes_on_axis(self,axis='red'):
        if asix == 'red':
            cuts = [self.red_limits[0]] + self.red_cut_points + [self.red_limits[1]]
            return []

        g_cuts = [self.green_limits[0]] + self.green_cut_points + [self.green_limits[1]]
        b_cuts = [self.blue_limits[0]] + self.blue_cut_points + [self.blue_limits[1]]
        return []
        
    def printTree(self):
        self.root.print()
    
###########################################################################################
x = Tree()
x.set_data_options(n_samples=10000,centers=64,dim=3,min_max=(0,1000),data_center_divations=10)
x.generate_data()
x.divide_space_equally(2,3,4)
x.plot_data()
###########################################################################################
# %%
