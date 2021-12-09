import torch
import coremltools as ct
import numpy as np
import os
import sys

from PIL import Image
from scipy.spatial import distance

def crop_and_resize(image_name, new_size):
    img = Image.open(image_name)
    w, h = img.size
    
    if w < h:
        s = w
    else:
        s = h

    left = (w - s) / 2
    right = left + s
    top = (h - s) / 2
    bottom = top + s

    img = img.crop((left, top, right, bottom))
    img = img.resize((new_size, new_size))

    return img


if len(sys.argv) < 3:
    print(f'USAGE: {sys.argv[0]} <image size> <image>')
    sys.exit(-1)

SIZE=int(sys.argv[1])
IMG=sys.argv[2]

img = crop_and_resize(IMG, SIZE)

# load the AnimeGAN v2 model using the pretrained Face Portrait v2 weights
pt_model = torch.hub.load("bryandlee/animegan2-pytorch:main", "generator", 
                           pretrained="face_paint_512_v2")
pt_model.eval()

# load the Core ML version of the AnimeGAN v2 model
cml_model = ct.models.MLModel(f"AnimeGANv2_{SIZE}.mlmodel")

# load a helper function for the PyTorch model
face2paint = torch.hub.load("bryandlee/animegan2-pytorch:main", "face2paint", size=SIZE) 

# run inference on the models
out_pt = face2paint(pt_model, img, side_by_side=False)
out_cml = cml_model.predict({'input': img})['output']

base, ext = os.path.splitext(IMG)
out_pt.save(f'{base}_pt.png')
out_cml.save(f'{base}_cml.png')

# convert the output to numpy arrays removing any alpha channel, if present
out_pt = np.array(out_pt)[:, :, :3]
out_cml = np.array(out_cml)[:, :, :3]

# flatten the arrays
out_pt = out_pt.flatten()
out_cml = out_cml.flatten()

# calculate the cosine similarity
cosine_similarity = 1.0 - distance.cosine(out_pt, out_cml)
print(f'Similarity: {cosine_similarity * 100:.2f}%')
