# Setting up your environment

Per the talk, I gave, the easiest way for iOS/Mac developers to set up their environment is to use [Conda](https://docs.conda.io/en/latest/). While there are multiple ways to install Conda, the easies way on a Mac is to use [Homebrew](https://brew.sh) - so make sure you have that installed first.

## Installing Conda

First you want to install Miniforge. Miniforge is a minimal installer for Conda.

```
brew install miniforge
```

After that you need to run:

```
conda init <your shell>
```

for instance, using the default **zsh** on macOS Monterey:

```
conda init zsh
```

Once this finishs, you need to restart your shell or the Terminal app to ensure your path is appropriately set.

## Conda environment setup

For the conversion scripts to properly work, you'll want to create a new Conda environment and install certain packages.

```
conda create --name coreml python=3.9
conda activate coreml
conda install pytorch torchvision
pip install coremltools
```

These commands will:
1. Create a new conda environment named **coreml** and install Python 3.9.X (3.9.7 at the time of this writing)
2. Activates the new **coreml** environment
3. Install the _PyTorch_ and _TorchVision_ packages
4. Install the _Core ML Tools_ package

> **NOTE:** On the [PyTorch Getting Started](https://pytorch.org/get-started/locally/) page, they say the command should be `conda install pytorch torchvision -c pytorch`. However, when I did this, it installed an **extremely** old version of _TorchVision_.

