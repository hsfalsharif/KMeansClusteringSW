import os
import random
from ComparatorTree import ComparatorTree

K = 32
old_means = []
old_means_r, old_means_g, old_means_b = [], [], []
means = []
means_r, means_g, means_b = [], [], []
pixel_accumulators = []
pixel_accumulators_r, pixel_accumulators_g, pixel_accumulators_b = [], [], []
pixel_counters = []
pixel_counters_r, pixel_counters_g, pixel_counters_b = [], [], []
r_split = 0
g_split = 0
b_split = 0
threshold = 1
stability_list = []  # might need to make stability lists for r, g, b
stability_list_r, stability_list_g, stability_list_b = [], [], []
filename = 'pictures/perfect.rgb'
red_tree = ComparatorTree()
green_tree = ComparatorTree()
blue_tree = ComparatorTree()


def get_data_source(option='read', filename='testImage.rgb', image_size=4000):
    if option == 'read':
        image_size = int(os.path.getsize(filename) / 3)
        f = open(filename, "rb")
        return f, image_size
    elif option == 'generate':
        gen_file = open("generatedImage.rgb", "wb")
        count = 0
        while count < image_size:
            r, g, b = random.randint(0, 255), random.randint(0, 255), random.randint(0, 255)
            gen_file.write(r.to_bytes(1, 'little'))
            gen_file.write(g.to_bytes(1, 'little'))
            gen_file.write(b.to_bytes(1, 'little'))
            count += 1
        return gen_file, image_size


def k_means(K=16, threshold=6, filename='testImage.rgb', option='manhattan'):
    global old_means, r_split, g_split, b_split, old_means_r, old_means_g, old_means_b
    max_r, max_g, max_b, min_r, min_g, min_b = find_min_max(filename=filename)
    r_split = 3
    g_split = 3
    b_split = 3
    initialize_means(K, 'cube', min_r, max_r, min_g, max_g, min_b, max_b,  # might need to account for this
                                                             r_split, g_split, b_split)
    f, image_size = get_data_source('read', filename=filename)
    red = f.read(1)
    green = f.read(1)
    blue = f.read(1)
    iterations = 0
    if option == 'manhattan':
        while not all(stability_list):  # this is the loop that will compute the means
            print(iterations)
            for i in range(image_size):
                closest_index = closest_mean_index(red, green, blue, 'root_sum_squares')
                closest_index2 = closest_mean_index(red, green, blue, 'tree')
                if closest_index != closest_index2:
                    print("Means RSS: {0}, Means Tree: {1}, RGB: {2}".format(means[closest_index], means[closest_index2],
                                                                                   [int.from_bytes(red, 'little'),
                                                                                    int.from_bytes(green, 'little'),
                                                                                    int.from_bytes(blue, 'little')]))
                pixel_accumulators[closest_index][0] += int.from_bytes(blue, 'little')
                pixel_accumulators[closest_index][1] += int.from_bytes(green, 'little')
                pixel_accumulators[closest_index][2] += int.from_bytes(red, 'little')
                pixel_counters[closest_index] += 1
                red = f.read(1)
                green = f.read(1)
                blue = f.read(1)

            print(pixel_counters)
            f.seek(0)  # resetting file pointer
            red = f.read(1)
            green = f.read(1)
            blue = f.read(1)

            for i in range(K):
                if pixel_counters[i] != 0:
                    means[i] = [accums // pixel_counters[i] for accums in pixel_accumulators[i]]
                pixel_accumulators[i] = [0, 0, 0]
                pixel_counters[i] = 0  # clearing accumulators and counters after computing each cluster mean
                stability_list[i] = (abs(means[i][0] - old_means[i][0]) < threshold) and \
                                    (abs(means[i][1] - old_means[i][1]) < threshold) and \
                                    (abs(means[i][2] - old_means[i][2]) < threshold)
            # stability_list[i] = all([(abs(new - old) < 6) for new, old in zip(means[i], old_means[i])])  # correct
            print(means)
            # print(old_means)
            # print(stability_list)
            print()
            old_means = means.copy()  # old means is not receiving the old value of the mean
            update_tree()
            iterations += 1
    elif option == 'tree':
        while not all(stability_list_r) and not all(stability_list_g) and not all(stability_list_b):  # this is the loop that will compute the means
            print(iterations)
            for i in range(image_size):
                closest_index_r, closest_index_g, closest_index_b = closest_mean_index(red, green, blue, option)
                pixel_accumulators_r[closest_index_r] += int.from_bytes(red, 'little')
                pixel_accumulators_g[closest_index_g] += int.from_bytes(green, 'little')
                pixel_accumulators_b[closest_index_b] += int.from_bytes(blue, 'little')
                pixel_counters_r[closest_index_r] += 1
                pixel_counters_g[closest_index_g] += 1
                pixel_counters_b[closest_index_b] += 1
                red = f.read(1)
                green = f.read(1)
                blue = f.read(1)
            print("Pixel Counters:")
            print(pixel_counters_r)
            print(pixel_counters_g)
            print(pixel_counters_b)
            f.seek(0)  # resetting file pointer
            red = f.read(1)
            green = f.read(1)
            blue = f.read(1)

            for i in range(r_split):  # make this as r_split, g_split, b_split instead of K
                if pixel_counters_r[i] != 0:
                    means_r[i] = pixel_accumulators_r[i] // pixel_counters_r[i]
                pixel_accumulators_r[i] = 0
                pixel_counters_r[i] = 0  # clearing accumulators and counters after computing each cluster mean
                stability_list_r[i] = (abs(means_r[i] - old_means_r[i]) < threshold)
            for i in range(g_split):  # make this as r_split, g_split, b_split instead of K
                if pixel_counters_g[i] != 0:
                    means_g[i] = pixel_accumulators_g[i] // pixel_counters_g[i]
                pixel_accumulators_g[i] = 0
                pixel_counters_g[i] = 0  # clearing accumulators and counters after computing each cluster mean
                stability_list_g[i] = (abs(means_g[i] - old_means_g[i]) < threshold)
            for i in range(b_split):  # make this as r_split, g_split, b_split instead of K
                if pixel_counters_b[i] != 0:
                    means_b[i] = pixel_accumulators_b[i] // pixel_counters_b[i]
                pixel_accumulators_b[i] = 0
                pixel_counters_b[i] = 0  # clearing accumulators and counters after computing each cluster mean
                stability_list_b[i] = (abs(means_b[i] - old_means_b[i]) < threshold)
                # stability_list[i] = all([(abs(new - old) < 6) for new, old in zip(means[i], old_means[i])])  # correct
            old_means_r = means_r.copy()
            old_means_g = means_g.copy()
            old_means_b = means_b.copy()
            update_tree()
            iterations += 1
            print(means_r)
            print(means_g)
            print(means_b)

def grow_tree(dim_means):
    tree = ComparatorTree(dim_means)
    # print(tree.to_string())
    return tree


def update_tree():
    global means, red_tree, green_tree, blue_tree, means_r, means_g, means_b
    # for i in means:
    #     means_r.append(i[2])
    #     means_g.append(i[1])
    #     means_b.append(i[0])
    means_r = list(set(means_r))  # make sure that these are sorted through the debugger
    means_g = list(set(means_g))
    means_b = list(set(means_b))
    means_r.sort(), means_g.sort(), means_b.sort()
    red_tree = grow_tree(means_r)
    green_tree = grow_tree(means_g)
    blue_tree = grow_tree(means_b)


def initialize_means(K=16, option='diagonal', min_r=0, max_r=255, min_g=0, max_g=255, min_b=0, max_b=255, r_split=2,
                     g_split=2, b_split=2):
    global red_tree, green_tree, blue_tree, means_r, means_g, means_b
    if option == 'diagonal':
        for i in range(K):  # initializing everything based on K
            old_means.append([i / K * 255, i / K * 255, i / K * 255])
            means.append([i / K * 255, i / K * 255, i / K * 255])
            pixel_accumulators.append([0, 0, 0])
            pixel_counters.append(0)
            stability_list.append(False)
    elif option == 'cube':
        for i in range(r_split):
            old_means_r.append(int(i / r_split * 255))
            means_r.append(int(i / r_split * 255))
            pixel_accumulators_r.append(0)
            pixel_counters_r.append(0)
            stability_list_r.append(False)
        for i in range(g_split):
            old_means_g.append(int(i / g_split * 255))
            means_g.append(int(i / g_split * 255))
            pixel_accumulators_g.append(0)
            pixel_counters_g.append(0)
            stability_list_g.append(False)
        for i in range(b_split):
            old_means_b.append(int(i / b_split * 255))
            means_b.append(int(i / b_split * 255))
            pixel_accumulators_b.append(0)
            pixel_counters_b.append(0)
            stability_list_b.append(False)
        r_range = max_r - min_r  # consider adding margins to max and min values
        g_range = max_g - min_g
        b_range = max_b - min_b
        r_segment = r_range // r_split  # do we assume split values to be even so
        g_segment = g_range // g_split  # that we can avoid division? (by shifting)
        b_segment = b_range // b_split
        r_split_values = [min_r]
        g_split_values = [min_g]
        b_split_values = [min_b]

        for i in range(r_split):  # finding the split values in each dimension
            r_split_values.append(r_split_values[-1] + r_segment)
        for i in range(g_split):
            g_split_values.append(g_split_values[-1] + g_segment)
        for i in range(b_split):
            b_split_values.append(b_split_values[-1] + b_segment)

        midpoints_r, midpoints_g, midpoints_b = [], [], []
        for i in range(r_split):
            midpoints_r.append((r_split_values[i + 1] + r_split_values[i]) // 2)
        for i in range(g_split):
            midpoints_g.append((g_split_values[i + 1] + g_split_values[i]) // 2)
        for i in range(b_split):
            midpoints_b.append((b_split_values[i + 1] + b_split_values[i]) // 2)
        # for i in range(r_split):
        #     for j in range(g_split):
        #         for k in range(b_split):
        #             means.append([midpoints_b[k],
        #                           midpoints_g[j],
        #                           midpoints_r[i]])
        #             old_means.append([midpoints_b[k], midpoints_g[j], midpoints_r[i]])
        #             pixel_accumulators.append([0, 0, 0])
        #             pixel_counters.append(0)
        #             stability_list.append(False)

        red_tree = grow_tree(midpoints_r)
        green_tree = grow_tree(midpoints_g)
        blue_tree = grow_tree(midpoints_b)
        means_r = midpoints_r
        means_g = midpoints_g
        means_b = midpoints_b
        print("Initialization:")
        print(means_r)
        print(means_g)
        print(means_b)
        # allow number of segments to be inputs from the user
        # so far we are restricting ourselves to 3D data


def find_min_max(filename='testImage.rgb'):
    f = open(filename, "rb")
    red = f.read(1)
    green = f.read(1)
    blue = f.read(1)
    max_r, max_g, max_b = (0).to_bytes(1, 'little'), (0).to_bytes(1, 'little'), (0).to_bytes(1, 'little')
    min_r, min_g, min_b = (255).to_bytes(1, 'little'), (255).to_bytes(1, 'little'), (255).to_bytes(1, 'little')
    while red:
        if red > max_r:
            max_r = red
        if green > max_g:
            max_g = green
        if blue > max_b:
            max_b = blue
        if red < min_r:
            min_r = red
        if green < min_g:
            min_g = green
        if blue < min_b:
            min_b = blue
        red = f.read(1)
        green = f.read(1)
        blue = f.read(1)
    return int.from_bytes(max_r, 'little'), int.from_bytes(max_g, 'little'), int.from_bytes(max_b, 'little'), \
           int.from_bytes(min_r, 'little'), int.from_bytes(min_g, 'little'), int.from_bytes(min_b, 'little')


def distance(x, r, g, b, option='manhattan'):
    global red_tree, green_tree, blue_tree
    r = int.from_bytes(r, 'little')
    g = int.from_bytes(g, 'little')
    b = int.from_bytes(b, 'little')
    if option == 'manhattan':
        return abs(x[2] - r) + abs(x[1] - g) + \
               abs(x[0] - b)
    elif option == 'sum_squares':
        return pow(abs(x[2] - r), 2) + pow(abs(x[1] - g), 2) + \
               pow(abs(x[0] - b), 2)
    elif option == 'root_sum_squares':
        return pow(pow(abs(x[2] - r), 2) + pow(abs(x[1] - g), 2) +
                   pow(abs(x[0] - b), 2), 0.5)
    elif option == 'tree':
        red_mean = red_tree.traverse(red_tree.root, r)
        green_mean = green_tree.traverse(green_tree.root, g)
        blue_mean = blue_tree.traverse(blue_tree.root, b)
        return [blue_mean, green_mean, red_mean]


def closest_mean_index(r, g, b, option='manhattan'):
    global means
    if option == 'tree':  # Problem found here: Resultant mean might not be in the list after first iteration
        closest_idx_r = means_r.index(distance(None, r, g, b, option)[2])  # we do not use means array for tree option
        closest_idx_g = means_g.index(distance(None, r, g, b, option)[1])  # we do not use means array for tree option
        closest_idx_b = means_b.index(distance(None, r, g, b, option)[0])  # we do not use means array for tree option
        return closest_idx_r, closest_idx_g, closest_idx_b
    else:
        mmin = 1000
        closest_idx = 0
        for x in range(len(means)):
            if mmin > distance(means[x], r, g, b, option):
                mmin = distance(means[x], r, g, b, option)
                closest_idx = x
        return closest_idx


def write_segmented_image(in_file='testImage.rgb', outfile='testImageOut.rgb'):
    for i in means_r:
        for j in means_g:
            for k in means_b:
                means.append([k, j, i])
    print("Final Means: ")
    print(means)
    f = open(in_file, "rb")
    o = open(outfile, "wb")
    red = f.read(1)
    green = f.read(1)
    blue = f.read(1)
    while red:
        mean_out = closest_mean(red, green, blue, 'root_sum_squares')
        o.write(mean_out[2].to_bytes(1, 'little'))
        o.write(mean_out[1].to_bytes(1, 'little'))
        o.write(mean_out[0].to_bytes(1, 'little'))
        red = f.read(1)
        green = f.read(1)
        blue = f.read(1)


def closest_mean(r, g, b, option='manhattan'):
    global means
    mmin = 1000
    closest = 0
    for x in range(len(means)):
        if mmin > distance(means[x], r, g, b, option):
            mmin = distance(means[x], r, g, b, option)
            closest = means[x]
    return closest


k_means(K, threshold, filename, 'tree')
write_segmented_image(filename, 'testImageOut.rgb')
