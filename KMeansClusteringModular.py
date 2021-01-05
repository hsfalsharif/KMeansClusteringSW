import os
import random

K = 16
old_means = []
means = []
pixel_accumulators = []
pixel_counters = []
threshold = 6
stability_list = []


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


def k_means(K=16, threshold=6):
    global old_means
    initialize_means(K, 'diagonal')
    f, image_size = get_data_source('read', 'testImage.rgb')
    red = f.read(1)
    green = f.read(1)
    blue = f.read(1)

    while not all(stability_list):  # this is the loop that will compute the means
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
                means[i] = [int(accums / pixel_counters[i]) for accums in pixel_accumulators[i]]
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


def initialize_means(K=16, option='diagonal'):
    if option == 'diagonal':
        for i in range(K):  # initializing everything based on K
            old_means.append([i * 16, i * 16, i * 16])
            means.append([i * 16, i * 16, i * 16])
            pixel_accumulators.append([0, 0, 0])
            pixel_counters.append(0)
            stability_list.append(False)
    elif option == 'cube':
        #  TODO: Add cube configuration
        print("Placeholder")


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


k_means(16, 6)
write_segmented_image('testImage.rgb', 'testImageOut.rgb')
