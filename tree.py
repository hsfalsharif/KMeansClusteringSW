class Tree:
    class node:
        D = None
        left = None
        right = None
    class cube:
        center = [] # blue,green,red position
        relative_center = [] # blue,green,red index
        mean = []
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
    red_limits = [] # 0 min 1 max
    blue_limits = []
    green_limits = []
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
        pass
    def cubes_on_axis(self,axis):
        pass
