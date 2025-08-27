#!/bin/bash
git clone --filter=blob:none --sparse https://github.com/edwingd18/CloudCOmputing.git tmp-cc
cd tmp-cc
git sparse-checkout set practica2/microwebAppBase
cp -a practica2/microwebAppBase ../microwebAppBase
cd ..
rm -rf tmp-cc
ls -la microwebAppBase | head

