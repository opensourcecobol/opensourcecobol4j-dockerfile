# Docker Image Size Optimization Summary

## Problem
The original Docker images were unnecessarily large due to including all build dependencies, full JDK, and build artifacts in the final runtime image.

## Solution
Implemented multi-stage Docker builds with the following optimizations:

### 1. Multi-Stage Architecture
**Before (Single-stage):**
```
FROM almalinux:9
├── Install all build tools (gcc, make, bison, flex, etc.)
├── Install full JDK (java-11-openjdk-devel)
├── Download and compile software
└── Final image contains everything
```

**After (Multi-stage):**
```
# Build Stage
FROM almalinux:9 AS builder
├── Install build tools
├── Download and compile software
└── Stage files for copying

# Runtime Stage  
FROM almalinux:9
├── Install minimal runtime (headless JRE only)
├── Copy built files from builder
└── Minimal final image
```

### 2. Dependency Optimization
- **Build stage only**: gcc, make, bison, flex, automake, autoconf, diffutils, gettext, java-11-openjdk-devel
- **Runtime stage only**: java-11-openjdk-headless (much smaller than full JDK)

### 3. Cleanup Optimizations
- Combined RUN commands to reduce Docker layers
- Added `dnf clean all` to remove package manager caches
- Added `rm -rf /var/cache/dnf/*` for additional cache cleanup
- Source directories removed after compilation (`rm -rf /root/opensourcecobol4j-*`)

### 4. Efficient File Management
- Used `DESTDIR=/tmp/install` for staged installation
- Only necessary runtime files copied with `COPY --from=builder /tmp/install/usr/ /usr/`
- Build artifacts and intermediate files excluded from final image

## Expected Size Reduction: 60-80%

### Components Eliminated from Final Image:
- **Build tools**: ~200-300MB (gcc, make, bison, flex, automake, etc.)
- **Full JDK vs headless**: ~100-150MB (java-11-openjdk-devel → java-11-openjdk-headless)
- **Package caches**: ~50-100MB (dnf cache, /var/cache/dnf/*)
- **Source code & artifacts**: ~50-100MB (downloaded tarballs, build directories)

### Total Estimated Reduction: ~400-650MB

## Files Modified
- `Dockerfile` - Multi-stage build for opensourcecobol4j + Open COBOL ESQL 4J
- `utf8.Dockerfile` - Multi-stage build for opensourcecobol4j with UTF-8 support
- `OPTIMIZATION.md` - Documentation of optimization techniques

## Functionality Preserved
Both optimized images maintain full functionality:
- All required binaries and libraries included
- Sample programs included
- Environment variables and classpath correctly configured
- Same user experience and capabilities as original images