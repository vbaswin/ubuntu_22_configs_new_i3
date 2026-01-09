#!/bin/bash

# --- CONFIGURATION ---
BUILD_DIR="build"
BUILD_TYPE="RelWithDebInfo" # Options: Debug, Release, RelWithDebInfo
TARGET_NAME=""              # Optional: Name of your specific binary (e.g., "my_app")

# Parse arguments: ./fast.sh [-c|--clean] [-r|--reconfigure]
FORCE_CLEAN=0
FORCE_CONFIG=0

for arg in "$@"; do
    case $arg in
        -c|--clean) FORCE_CLEAN=1 ;;
        -r|--reconfigure) FORCE_CONFIG=1 ;;
    esac
done

# --- 1. PRE-CHECKS ---
if [[ $FORCE_CLEAN -eq 1 ]]; then
    echo "🧹 Cleaning build directory..."
    rm -rf "$BUILD_DIR"
fi

# Detect Threads
THREADS=$(nproc 2>/dev/null || echo 4)

# Detect Modern Tools
GEN_ARGS=""
[[ -x "$(command -v ninja)" ]] && GEN_ARGS="-GNinja"

CCACHE_ARGS=""
[[ -x "$(command -v ccache)" ]] && CCACHE_ARGS="-DCMAKE_CXX_COMPILER_LAUNCHER=ccache -DCMAKE_C_COMPILER_LAUNCHER=ccache"

LINKER_ARGS=""
if [[ -x "$(command -v mold)" ]]; then
    LINKER_ARGS="-DCMAKE_EXE_LINKER_FLAGS=-fuse-ld=mold -DCMAKE_SHARED_LINKER_FLAGS=-fuse-ld=mold"
elif [[ -x "$(command -v ld.lld)" ]]; then
    LINKER_ARGS="-DCMAKE_EXE_LINKER_FLAGS=-fuse-ld=lld -DCMAKE_SHARED_LINKER_FLAGS=-fuse-ld=lld"
fi

# --- 2. CONFIGURE (Smart) ---
# Re-configure if cache is missing OR if requested
if [[ ! -f "$BUILD_DIR/CMakeCache.txt" ]] || [[ $FORCE_CONFIG -eq 1 ]]; then
    echo "⚙️  Configuring project ($BUILD_TYPE)..."
    cmake -B "$BUILD_DIR" -S . $GEN_ARGS \
        -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
        -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
        $CCACHE_ARGS $LINKER_ARGS
    
    if [[ $? -ne 0 ]]; then echo "❌ Configuration Failed!"; exit 1; fi
    
    # --- AUTO-LINK FOR LAZYVIM ---
    echo "🔗 Linking compile_commands.json for LazyVim..."
    ln -sf "$BUILD_DIR/compile_commands.json" compile_commands.json
fi

# --- 3. BUILD ---
echo "🔨 Building..."
# We DO NOT hide output. We want to see warnings and progress.
cmake --build "$BUILD_DIR" --parallel "$THREADS"

if [[ $? -ne 0 ]]; then exit 1; fi

# --- 4. RUN (Precise) ---
# If you set TARGET_NAME above, use it. Otherwise, search intelligently.
if [[ -n "$TARGET_NAME" ]]; then
    PROJECT_EXE="$BUILD_DIR/$TARGET_NAME"
else
    # Find the most recently modified executable (likely the one you just built)
    PROJECT_EXE=$(find "$BUILD_DIR" -type f -executable \
        -not -path "*/CMakeFiles/*" \
        -not -name "*.so*" \
        -not -name "*.a" \
        -not -name "*.sh" \
        -printf "%T@ %p\n" | sort -n | tail -1 | cut -f2- -d" ")
fi

if [[ -n "$PROJECT_EXE" && -x "$PROJECT_EXE" ]]; then
    echo "✅ Starting $(basename "$PROJECT_EXE")..."
    echo "---------------------------------------------------"
    "$PROJECT_EXE"
else
    echo "⚠️  Build success, but no runnable executable found."
fi
