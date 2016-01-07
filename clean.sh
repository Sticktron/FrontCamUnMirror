#!/bin/bash
make clean

echo "removing Packages"
echo "removing .theos"

rm -rf Packages
rm -rf .theos
rm -rf Settings/.theos

echo "done."
