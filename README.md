# Anime-fy-Yourself
Code and documentation for my talk Anime-fy Yourself Using Core ML

## Convert from PyTorch to Core ML
To convert [@bryandlee]'s PyTorch implementation of [AnimeGANv2](https://github.com/bryandlee/animegan2-pytorch) to Core ML, run the following command:

```
python convert_to_nn.py 512
```

Running like this, the output image sizes will be 512 x 512px. If you want a different resolution, you can run the script with a different parameter. Currently only square image formats are supported.

This script will save a file called _AnimeGANv2_512.mlmodel_ in the same directory, from which it was run. This model can be imported into Xcode and used in the sample project.

## Comparing outputs

Additionally a script to compare the outputs of the PyTorch and Core ML models is available in the _python_ directory.

```
python compare 512 MyCoolImage.jpg
```

Running this will print the cosine similarity of the PyTorch and Core ML model outputs. To do so, it flattens the output image and treats them as large 1D vectors. This may or may not be useful.

It will also save the PyTorch and CoreML generated images under the following names (based on the name of the passed in file):

- MyCoolImage_pt.png
- MyCoolImage_cml.png

Here are some example images and their cosine similarities:

Original | PyTorch | Core ML | Cosine Similarity
-------- | ------- | ------- | -----------------
![Yono 1](samples/Yono1.jpg|width=256) | ![PyTorch Anime Yono 1](samples/Yono1_pt.png|width=256) | ![Core ML Anime Yono 1](samples/Yono1_cml.png|width=256) | 91.04% 
![Yono 2](samples/Yono2.jpg|width=256) | ![PyTorch Anime Yono 2](samples/Yono2_pt.png|width=256) | ![Core ML Anime Yono 2](samples/Yono2_cml.png|width=256) | 80.48%
