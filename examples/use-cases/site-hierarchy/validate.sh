#!/bin/bash

# Validation script to check if all sites from the YAML are covered

echo "=== Site Hierarchy Validation ==="
echo

echo "Expected from YAML file:"
echo "Areas (7): USA, SAN JOSE, SAN-FRANCISCO, New York, BERKELEY, RTP, BayAreaGuest"
echo "Buildings (9): BLD23, BLD20, BLD_GB, BLDNYC, BLD_SF, BLD_SF1, BLDBERK, BLD10, BLD11"
echo "Floors (19 total): Multiple floors across buildings"
echo

echo "Checking Terraform files..."

# Count resources in main.tf
AREAS=$(grep -c "resource \"catalystcenter_area\"" main.tf)
BUILDINGS=$(grep -c "resource \"catalystcenter_building\"" main.tf)  
FLOORS=$(grep -c "resource \"catalystcenter_floor\"" main.tf)

echo "Resources found in main.tf:"
echo "- Areas: $AREAS"
echo "- Buildings: $BUILDINGS"
echo "- Floors: $FLOORS"
echo

# Check specific area names
echo "Area validation:"
for area in "USA" "SAN JOSE" "SAN-FRANCISCO" "New York" "BERKELEY" "RTP" "BayAreaGuest"; do
    if grep -q "name.*=.*\"$area\"" main.tf; then
        echo "✓ Area: $area"
    else
        echo "✗ Missing area: $area"
    fi
done

echo
echo "Building validation:"
for building in "BLD23" "BLD20" "BLD_GB" "BLDNYC" "BLD_SF" "BLD_SF1" "BLDBERK" "BLD10" "BLD11"; do
    if grep -q "name.*=.*\"$building\"" main.tf; then
        echo "✓ Building: $building"
    else
        echo "✗ Missing building: $building"
    fi
done

echo
echo "Files created:"
ls -la *.tf *.md *.example 2>/dev/null
echo

echo "Validation complete!"