# zig-tensorflow

Zig binding for the [Tensorflow C API](https://www.tensorflow.org/install/lang_c)

---

The goal of the repo is to simply generate the Zig bindings for C API using zig [translate-c](https://codeberg.org/ziglang/translate-c)
and link all the necessary libs for CUDA/cuDNN

This repo will be the base for other wrappers that I want to write in Zig for Tensorflow.

> [!WARNING]
> This repo specifically targets the build of Tensorflow with GPU support
> CPU only build might be added in the future.

#### References

 - [libtensorflow](https://www.tensorflow.org/install/lang_c)
 - [NVIDIA CUDA dist](https://developer.download.nvidia.com/compute/cuda/redist)
 - [NVIDIA cuDNN dist](https://developer.download.nvidia.com/compute/cuda/redist/)
 - [Build Dep Table](https://www.tensorflow.org/install/source#gpu)
