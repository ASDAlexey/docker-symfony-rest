#!/bin/bash
echo "\n\033[1;mAre you sure?\033[0m"
	select yn in "Yes" "No"; do
	case $yn in
		Yes ) break;;
		No ) exit 130;;
	esac
done

