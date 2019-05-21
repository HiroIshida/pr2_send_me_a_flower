import numpy as np

def bool2image(mat_bool):
    nx = mat_bool.shape[0]
    ny = mat_bool.shape[1]
    mat_img = np.empty((nx, ny, 3), dtype=np.uint8)
    b = np.array([0, 0, 0], dtype=np.uint8)
    w = np.array([255, 255, 255], dtype=np.uint8)
    for i in range(nx):
        for j in range(ny):
            if mat_bool[i][j]:
                mat_img[i][j] = np.array([255, 255, 255], dtype=np.uint8)
            else:
                mat_img[i][j] = np.array([0, 0, 0], dtype=np.uint8)
    return mat_img

def gen_sample_image():
    t = True
    f = False
    bool_mat = np.array([
        [t, f, f, f, f, f],
        [t, f, t, f, f, f],
        [f, f ,f, t, t, f],
        [f, f, f, f, t, f],
        [f, t, t, f, f, f],
        [f, t, t, f, f, f],
        [f, f, f, f, f, f]
        ], dtype=np.uint8)
    img = bool2image(bool_mat)
    return img

#img = gen_sample_image()
#plt.imshow(img)



    
    

