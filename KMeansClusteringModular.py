import os
import random

K = 32
old_means = []
means = []
pixel_accumulators = []
pixel_counters = []
threshold = 1
stability_list = []
filename = 'testImage.rgb'


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


def k_means(K=16, threshold=6, filename='testImage.rgb'):
    global old_means
    max_r, max_g, max_b, min_r, min_g, min_b = find_min_max(filename=filename)
    initialize_means(K, 'cube', min_r, max_r, min_g, max_g, min_b, max_b, r_split=2, g_split=4, b_split=4)
    f, image_size = get_data_source('read', filename=filename)
    red = f.read(1)
    green = f.read(1)
    blue = f.read(1)
    iterations = 0
    while not all(stability_list):  # this is the loop that will compute the means
        print(iterations)
        for i in range(image_size):
            closest_index = closest_mean_index(red, green, blue)
            pixel_accumulators[closest_index][0] += int.from_bytes(blue, 'little')
            pixel_accumulators[closest_index][1] += int.from_bytes(green, 'little')
            pixel_accumulators[closest_index][2] += int.from_bytes(red, 'little')
            pixel_counters[closest_index] += 1
            red = f.read(1)
            green = f.read(1)
            blue = f.read(1)

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
        iterations += 1


def initialize_means(K=16, option='diagonal', min_r=0, max_r=255, min_g=0, max_g=255, min_b=0, max_b=255, r_split=2,
                     g_split=2, b_split=2):
    if option == 'diagonal':
        for i in range(K):  # initializing everything based on K
            old_means.append([i / K * 255, i / K * 255, i / K * 255])
            means.append([i / K * 255, i / K * 255, i / K * 255])
            pixel_accumulators.append([0, 0, 0])
            pixel_counters.append(0)
            stability_list.append(False)
    elif option == 'cube':
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
        for i in range(r_split):
            for j in range(g_split):
                for k in range(b_split):
                    means.append([midpoints_b[k],
                                  midpoints_g[j],
                                  midpoints_r[i]])
                    old_means.append([midpoints_b[k], midpoints_g[j], midpoints_r[i]])
                    pixel_accumulators.append([0, 0, 0])
                    pixel_counters.append(0)
                    stability_list.append(False)
        print(means)
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
    if option == 'manhattan':
        return abs(x[2] - int.from_bytes(r, 'little')) + abs(x[1] - int.from_bytes(g, 'little')) + \
               abs(x[0] - int.from_bytes(b, 'little'))
    elif option == 'sum_squares':
        return pow(abs(x[2] - int.from_bytes(r, 'little')), 2) + pow(abs(x[1] - int.from_bytes(g, 'little')), 2) + \
               pow(abs(x[0] - int.from_bytes(b, 'little')), 2)
    elif option == 'root_sum_squares':
        return pow(pow(abs(x[2] - int.from_bytes(r, 'little')), 2) + pow(abs(x[1] - int.from_bytes(g, 'little')), 2) +
                   pow(abs(x[0] - int.from_bytes(b, 'little')), 2), 0.5)


def closest_mean_index(r, g, b):
    global means
    mmin = 1000
    closest_idx = 0
    for x in range(len(means)):
        if mmin > distance(means[x], r, g, b):
            mmin = distance(means[x], r, g, b)
            closest_idx = x
    return closest_idx


def write_segmented_image(in_file='testImage.rgb', outfile='testImageOut.rgb'):
    f = open(in_file, "rb")
    o = open(outfile, "wb")
    red = f.read(1)
    green = f.read(1)
    blue = f.read(1)
    while red:
        mean_out = closest_mean(red, green, blue)
        o.write(mean_out[2].to_bytes(1, 'little'))
        o.write(mean_out[1].to_bytes(1, 'little'))
        o.write(mean_out[0].to_bytes(1, 'little'))
        red = f.read(1)
        green = f.read(1)
        blue = f.read(1)


def closest_mean(r, g, b):
    global means
    mmin = 1000
    closest = 0
    for x in range(len(means)):
        if mmin > distance(means[x], r, g, b):
            mmin = distance(means[x], r, g, b)
            closest = means[x]
    return closest


k_means(K, threshold, filename)
write_segmented_image('testImage.rgb', 'testImageOut.rgb')
