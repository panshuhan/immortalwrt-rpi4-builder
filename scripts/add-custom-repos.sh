#!/bin/bash
set -e

# add-custom-repos.sh
# Add custom repositories to ImageBuilder and update package index

echo "========================================="
echo "Adding Custom Repositories"
echo "========================================="
echo ""

if [ ! -d "imagebuilder" ]; then
    echo "ERROR: ImageBuilder directory not found"
    echo "Please run prepare-imagebuilder.sh first"
    exit 1
fi

if [ ! -f "config/custom-repositories.conf" ]; then
    echo "ERROR: config/custom-repositories.conf not found"
    exit 1
fi

echo "Step 1: Backing up original repositories.conf..."
cp imagebuilder/repositories.conf imagebuilder/repositories.conf.bak
echo "Backup created: imagebuilder/repositories.conf.bak"

echo ""
echo "Step 2: Appending custom repositories..."
echo "Custom repos file: config/custom-repositories.conf"

# Append custom repositories
cat config/custom-repositories.conf >> imagebuilder/repositories.conf

echo ""
echo "Step 3: Verifying repositories.conf..."
echo "--- repositories.conf content (last 10 lines) ---"
tail -10 imagebuilder/repositories.conf
echo "--- end of repositories.conf ---"
echo ""

# Verify kenzok8 repos were added
if ! grep -q "kenzok8" imagebuilder/repositories.conf; then
    echo "ERROR: kenzok8 repositories not found in repositories.conf"
    exit 1
fi

echo "Custom repositories added successfully"

echo ""
echo "Step 4: Updating package index..."
cd imagebuilder

# Update package index
make package_index || {
    echo "ERROR: Failed to update package index"
    echo "This might be a network issue. Check repository URLs."
    exit 1
}

cd ..

echo ""
echo "Step 5: Verifying package availability..."
cd imagebuilder

# Check if some key packages are available
for pkg in luci-app-passwall luci-app-openclash luci-app-ssr-plus; do
    if make package_whatdepends PACKAGE="$pkg" 2>/dev/null | grep -q "$pkg"; then
        echo "✓ Package available: $pkg"
    else
        echo "⚠ Package not found: $pkg (might need manual verification)"
    fi
done

cd ..

echo ""
echo "========================================="
echo "Custom repositories configured!"
echo "========================================="
echo "Ready to build firmware with custom packages"
echo ""
