import cv2
import numpy as np
import matplotlib.pyplot as plt
execfile("sample_image.py")

#img = cv2.imread("image/1_edge.png")
#img = cv2.imread("image/1_edge.png")
img = gen_sample_image()


def image_to_pixel_list(img):
    dim_x = img.shape[0]
    dim_y = img.shape[1]
    pixel_list = [[i, j] for i in range(dim_x) for j in range(dim_y)]
    return pixel_list

def isWhite(rgb):
    if sum(rgb)==255*3:
        return True
    return False

def isWhity(rgb):
    #i_hsi = sum(rgb)/3
    i_hsi = sum(rgb)/3.0
    s_hsi = 1 - min(rgb)/i_hsi
    return (s_hsi<0.08)*(i_hsi>180)

def extract_pixel(img, predicate):
    pixel_list_extracted = []
    for pixel in image_to_pixel_list(img):
        rgb = img[pixel[0]][pixel[1]]
        if predicate(rgb):
            pixel_list_extracted.append(pixel)
    return pixel_list_extracted

def fill(img, predicate):
    img_filled = np.copy(img)
    for pixel in image_to_pixel_list(img):
        rgb = img[pixel[0]][pixel[1]]
        if predicate(rgb):
            img_filled[pixel[0]][pixel[1]] = np.array([255, 255, 255])
        else:
            img_filled[pixel[0]][pixel[1]] = np.array([0, 0, 0])
    return img_filled


def group_connected_pixel(img):
    dimx = img.shape[0]
    dimy = img.shape[1]
    mat_isVisited = np.zeros((dimx, dimy), dtype=bool)
    group_pixel = []
    for pixel in image_to_pixel_list(img):
        nx = pixel[0]
        ny = pixel[1]
        if not mat_isVisited[nx][ny]:
            mat_isVisited[nx][ny] = True
            if isWhite(img[nx][ny]):
                pixel_connected_list = explore_connection(pixel, img, mat_isVisited)
                group_pixel.append(pixel_connected_list)
    return group_pixel

def explore_connection(pixel_start, img, mat_isVisited):
    dimx = img.shape[0]
    dimy = img.shape[1]

    def isInside(pixel):
        if pixel[0] < 0:
            return False
        if pixel[0] > dimx-1:
            return False
        if pixel[1] < 0:
            return False
        if pixel[1] > dimy-1:
            return False
        return True

    pixel_connected_list = []

    def recursion(pixel):
        mat_isVisited[pixel[0]][pixel[1]] = True
        pixel_connected_list.append(pixel)
        def isExtendable(pixel):
            # order is important
            if not isInside(pixel):
                return False
            if mat_isVisited[pixel[0]][pixel[1]]:
                return False
            if not isWhite(img[pixel[0]][pixel[1]]):
                return False
            return True

        pixel_candidate_list = [[pixel[0]+i, pixel[1]+j] for i in [-1, 0, 1] for j in [-1, 0, 1]]
        for pixel in pixel_candidate_list:
            if isExtendable(pixel):
                recursion(pixel)
    recursion(pixel_start)
    return pixel_connected_list

lstlst = group_connected_pixel(img)



