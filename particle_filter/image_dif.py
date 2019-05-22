import cv2
import math
import numpy as np
import matplotlib.pyplot as plt
inf = 10000000000000000

def bgr2hsi(bgr):
    b, g, r = bgr/255.0
    i = (r + g + b)/3.0
    s = 1.0 - min([b, g, r])/i
    h = math.acos(0.5*((r-g)+(r-b))/(math.sqrt((r-g)**2+(r-b)*(g-b))))
    if b<= g:
        h = h
    else:
        h = math.pi*2 - h
    hsi = np.array([h, s, i])
    return hsi

def image_to_pixel_list(img):
    dim_x = img.shape[0]
    dim_y = img.shape[1]
    pixel_list = [[i, j] for i in range(dim_x) for j in range(dim_y)]
    return pixel_list

def convert_bf(img, predicate):
    img_filled = np.copy(img)
    for pixel in image_to_pixel_list(img):
        rgb = img[pixel[0]][pixel[1]]
        if predicate(rgb):
            img_filled[pixel[0]][pixel[1]] = np.array([255, 255, 255])
        else:
            img_filled[pixel[0]][pixel[1]] = np.array([0, 0, 0])
    return img_filled

def gen_hsi_filter(h_bound, s_bound, i_bound):
    # ex: h_bound = [h_min, h_max]
    def hsi_filter(bgr):
        hsi = bgr2hsi(bgr)
        h = hsi[0]; s = hsi[1]; i = hsi[2]
        if h < h_bound[0] or h_bound[1] < h:
            return False
        if s < s_bound[0] or s_bound[1] < s:
            return False
        if i < i_bound[0] or i_bound[1] < i:
            return False
        return True
    return hsi_filter

def evaluatedif(img1, img2):
    img_dif = img1 - img2
    cost = 0
    for pixel in image_to_pixel_list(img_dif):
        rgb = img_dif[pixel[0]][pixel[1]]
        if sum(rgb)!=0:
            cost += 1
    return cost


img1 = cv2.imread("image/pre.png")
img2 = cv2.imread("image/post_with_move.png")
img1_ = convert_bf(img1, gen_hsi_filter([-inf, inf], [0.3, 1], [0.5, 0.8]))
img2_ = convert_bf(img2, gen_hsi_filter([-inf, inf], [0.3, 1], [0.5, 0.8]))
cost = evaluatedif(img1_, img2_)
#plt.imshow(img_dif)
#plt.show()

