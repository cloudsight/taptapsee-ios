#!/bin/bash

base='en'

for lang
do
	echo "Localizing to $lang from $base"

	base_proj=${PWD}/TapTapSee/$base.lproj
	target_proj=${PWD}/TapTapSee/$lang.lproj

	./validate_strings.rb ${base_proj} || exit 1

	plutil ${target_proj}/CameraViewController.strings && \
	ibtool --import-strings-file ${target_proj}/CameraViewController.strings \
					--write ${target_proj}/CameraViewController.xib \
					${base_proj}/CameraViewController.xib

  plutil ${target_proj}/AboutViewController.strings && \
	ibtool --import-strings-file ${target_proj}/AboutViewController.strings \
					--write ${target_proj}/AboutViewController.xib \
					${base_proj}/AboutViewController.xib

	plutil ${target_proj}/PurchaseViewController.strings && \
	ibtool --import-strings-file ${target_proj}/PurchaseViewController.strings \
					--write ${target_proj}/PurchaseViewController.xib \
					${base_proj}/PurchaseViewController.xib

	plutil ${target_proj}/DemoSplashViewController.strings && \
	ibtool --import-strings-file ${target_proj}/DemoSplashViewController.strings \
					--write ${target_proj}/DemoSplashViewController.xib \
					${base_proj}/DemoSplashViewController.xib
done
