# zig-tensorflow

Zig binding for the [Tensorflow C API](https://www.tensorflow.org/install/lang_c)

---

The goal of the repo is to simply generate the Zig bindings for C API using zig [translate-c](https://codeberg.org/ziglang/translate-c)

This repo will be the base for other wrappers that I want to write in Zig for Tensorflow.
The reason for this repo being a separated from the downstream wrapper is that if I want
to I can easily add convenience functions here. (aka. easier to organize)

#### References

 - [libtensorflow](https://www.tensorflow.org/install/lang_c)
 - [Adwaith-Rajesh/libtensorflow](https://github.com/Adwaith-Rajesh/libtensorflow)
 - [Build Dep Table](https://www.tensorflow.org/install/source#gpu)


### Build Options
   - `tf-path` (`-Dtf-path`) Path to custom installation of tensorflow
