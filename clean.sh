#!/bin/bash
make clean

echo "deleting packages"
rm -rf packages

echo "deleting obj"
rm -rf obj

echo "deleting .theos"
rm -rf .theos
rm -rf Settings/.theos

echo "done."
