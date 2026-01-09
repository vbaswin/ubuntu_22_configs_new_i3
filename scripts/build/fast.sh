#!/bin/zsh

# --- CONFIGURATION ---
BUILD_DIR="build"
# Set this to Release or RelWithDebInfo for actual work
BUILD_TYPE="RelWithDebInfo" 
LOG_FILE="/tmp/cmake_build_log.txt"

# --- 1. TOOL DETECTION (Fixed) ---
# We use 'command -v' which works everywhere and doesn't crash Zsh

# Detect Threads
if command -v nproc >/dev/null; then
    THREADS=$(nproc)
else
    THREADS=4
fi

# Detect Ninja
GEN_ARGS=""
if command -v ninja >/dev/null; then
    GEN_ARGS="-GNinja"
fi

# Detect Ccache
CCACHE_ARGS=""
if command -v ccache >/dev/null; then
    CCACHE_ARGS="-DCMAKE_CXX_COMPILER_LAUNCHER=ccache -DCMAKE_C_COMPILER_LAUNCHER=ccache"
fi

# Detect Linker
LINKER_ARGS=""
if command -v mold >/dev/null; then
    LINKER_ARGS="-DCMAKE_EXE_LINKER_FLAGS=-fuse-ld=mold -DCMAKE_SHARED_LINKER_FLAGS=-fuse-ld=mold"
elif command -v ld.lld >/dev/null; then
    LINKER_ARGS="-DCMAKE_EXE_LINKER_FLAGS=-fuse-ld=lld -DCMAKE_SHARED_LINKER_FLAGS=-fuse-ld=lld"
fi

# --- 2. CONFIGURE (Smart) ---
# Only configure if CMakeCache is missing or if we specifically ask (optional)
if [[ ! -f "$BUILD_DIR/CMakeCache.txt" ]]; then
    echo "⚙️  Configuring project ($BUILD_TYPE)..."
    cmake -B "$BUILD_DIR" -S . $GEN_ARGS \
        -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
        -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
        $CCACHE_ARGS $LINKER_ARGS > "$LOG_FILE" 2>&1
    
    if [[ $? -ne 0 ]]; then
        echo "❌ Configuration Failed!"
        cat "$LOG_FILE"
        exit 1
    fi
fi

# --- 3. BUILD ---
echo "🔨 Building..."
# Capture output to log, show only on error
cmake --build "$BUILD_DIR" --parallel "$THREADS" > "$LOG_FILE" 2>&1

if [[ $? -ne 0 ]]; then
    echo "❌ Build Failed. Errors below:"
    echo "---------------------------------------------------"
    cat "$LOG_FILE"
    echo "---------------------------------------------------"
    exit 1
fi

# --- AUTO-LINK COMPILE COMMANDS ---
# Ensure the root compile_commands.json always points to the build one
if [[ -f "$BUILD_DIR/compile_commands.json" ]]; then
    # -s creates symlink, -f forces overwrite if it exists
    ln -sf "$BUILD_DIR/compile_commands.json" compile_commands.json
fi

# --- 4. RUN (Smarter Search) ---
# Find executable files, but explicitly EXCLUDE:
# 1. CMakeFiles directory (where that CompilerABI file lives)
# 2. Shared libraries (.so) or static libs (.a)
# 3. Shell scripts (.sh)
PROJECT_EXE=$(find "$BUILD_DIR" -type f -executable \
    -not -path "*/CMakeFiles/*" \
    -not -name "*.so*" \
    -not -name "*.a" \
    -not -name "*.sh" \
    -not -name "*.bin" \
    | head -n 1)

if [[ -n "$PROJECT_EXE" ]]; then
    echo "✅ Starting $(basename "$PROJECT_EXE")..."
    echo "---------------------------------------------------"
    "$PROJECT_EXE" "$@"
else
    echo "⚠️  Build success, but no runnable executable found."
    echo "   (Ignored CMakeFiles and libraries)"
    exit 1
fi
