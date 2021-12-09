import torch
import coremltools as ct
import coremltools.proto.FeatureTypes_pb2 as ft
import sys

from coremltools import utils
from coremltools.models.neural_network.builder import _get_nn_spec as get_nn
from coremltools.models.neural_network import quantization_utils

if len(sys.argv) < 2:
    print(f'USAGE: {sys.argv[0]} <image size>')
    sys.exit(-1)

SIZE=int(sys.argv[1])

# load the AnimeGAN v2 model using the pretrained Face Portrait v2 weights
model = torch.hub.load("bryandlee/animegan2-pytorch:main", "generator", 
                       pretrained="face_paint_512_v2")

# put the model into evaluation mode to optimize it for inference
model.eval()

# create a dummy input for the model trace
# dimensions are (batch size, channels (RGB), width, height)
dummy_in = torch.rand(1, 3, SIZE, SIZE)

# run the model's forward method and record the tensor operations
traced_model = torch.jit.trace(model, dummy_in)

# save the traced model (TorchScript) to a file
traced_model.save("animegan_v2.pt")

# define the CoreML inputs
input = ct.ImageType(name="input", shape=dummy_in.shape, scale=1./127.5, bias=[-1.0, -1.0, -1.0], color_layout='RGB', channel_first=True)

# convert the TorchScript to an MLModel
mlmodel = ct.convert("animegan_v2.pt", inputs=[input])

# convert model weights from fp32 -> fp16
mlmodel = quantization_utils.quantize_weights(mlmodel, nbits=16)

# 
# Model editing
# 

spec = mlmodel.get_spec()

# make the output an image type
output = spec.description.output[0]
output.type.imageType.colorSpace = ft.ImageFeatureType.RGB
output.type.imageType.width = SIZE
output.type.imageType.height = SIZE

# get the neural network
nn = get_nn(spec)

# add a new layer to the end of the neural network
unscaled_output_layer = nn.layers[-1]
scale_layer = nn.layers.add()

# set it's name
scale_layer.name = "scale_output"

# make the new layer a linear activation function, which scales the output from [-1, 1] to [0, 255]
# y = alpha * x + beta
scale_layer.activation.linear.alpha = 127.5
scale_layer.activation.linear.beta = 127.5

# connect the new layer to the output
scale_layer.output.append(unscaled_output_layer.output[0])

# connect the old last layer's output to the new scale layer's input
unscaled_output_layer.output[0] = "scale_layer_input"
scale_layer.input.append(unscaled_output_layer.output[0])

# rename the output
output.name = "output"
output_layer = nn.layers[-1]
output_layer.output[0] = output.name

# save the CoreML model
utils.save_spec(spec, f"AnimeGANv2_{SIZE}.mlmodel")
