#!/bin/bash
set -e

# --- CONFIGURATION ---
BUILD_DIR="build"
THREADS=$(nproc)
BUILD_TYPE="RelWithDebInfo"

# --- TOOL DETECTION ---
GEN="-GNinja"
[ ! -x "$(command -v ninja)" ] && GEN=""

CCACHE_ARGS=""
[ -x "$(command -v ccache)" ] && CCACHE_ARGS="-DCMAKE_CXX_COMPILER_LAUNCHER=ccache -DCMAKE_C_COMPILER_LAUNCHER=ccache"

LINKER_ARGS=""
if [ -x "$(command -v mold)" ]; then
    LINKER_ARGS="-DCMAKE_EXE_LINKER_FLAGS=-fuse-ld=mold -DCMAKE_SHARED_LINKER_FLAGS=-fuse-ld=mold"
elif [ -x "$(command -v ld.lld)" ]; then
    LINKER_ARGS="-DCMAKE_EXE_LINKER_FLAGS=-fuse-ld=lld -DCMAKE_SHARED_LINKER_FLAGS=-fuse-ld=lld"
fi

# --- CONFIGURE & BUILD ---
# Redirecting stdout to /dev/null so only errors show
if [ ! -f "$BUILD_DIR/build.ninja" ] && [ ! -f "$BUILD_DIR/Makefile" ]; then
    cmake -B "$BUILD_DIR" -S . $GEN -DCMAKE_BUILD_TYPE=$BUILD_TYPE -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_UNITY_BUILD=ON $CCACHE_ARGS $LINKER_ARGS >/dev/null
fi

cmake --build "$BUILD_DIR" --parallel "$THREADS" >/dev/null

# --- RUN APP ---
# Find the executable (assumes it's in the top level of build dir)
# If your app has a specific name, replace "${PROJECT_EXE}" with it.
PROJECT_EXE=$(find "$BUILD_DIR" -maxdepth 1 -executable -type f -not -name "*.so*" | head -n 1)

if [ -f "$PROJECT_EXE" ]; then
    echo "✅ Build Complete. Starting $(basename "$PROJECT_EXE")..."
    ./"$PROJECT_EXE"
else
    echo "❌ Build finished but no executable found in $BUILD_DIR"
    exit 1
fi
