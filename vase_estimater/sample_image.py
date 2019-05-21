import numpy as np
def gen_sample_image():
    b = np.array([0, 0, 0], dtype=np.uint8)
    w = np.array([255, 255, 255], dtype=np.uint8)
    img = np.array([
        [w, b, b, b, b, b],
        [w, b, w, b, b, b],
        [b, b, b, w, w, b],
        [b, b, b, b, w, b],
        [b, w, w, b, b, b],
        [b, w, w, b, b, b],
        [b, b, b, b, b, b]
        ], dtype=np.uint8)
    return img
    #plt.imshow(img_)
