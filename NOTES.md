### Conan Install
```shell
conan install . -of build-msvc --build=missing -s compiler=msvc -s compiler.version=193 -s compiler.runtime=dynamic

conan install . -of build-clang --build=missing -s compiler=clang -s compiler.version=20 -s build_type=Release

conan install . -of build-gcc --build=missing -s compiler=gcc -s compiler.version=15 -s compiler.libcxx=libstdc++ # still fails to build
```

### Configure
```shell
cmake --preset=clang-release
cmake --preset=clang-debug
cmake --preset=msvc
```

### Build
```shell
cmake --preset=clang-release
cmake --preset=clang-debug
cmake --preset=msvc-release
cmake --preset=msvc-debug
```