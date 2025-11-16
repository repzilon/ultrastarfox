#! /bin/sh

for d in $(ls -d */); do
	if [ "X$d" != "Xsf_decrunch/" ]; then
		#cp sf_decrunch/sf_decrunch.vcproj "${d}${d%/}.vcproj"
		#echo "s|Name=\"sf_decrunch\"|Name=\"${d%/}\"|"
		sed -e "s|Name=\"sf_decrunch\"|Name=\"${d%/}\"|" sf_decrunch/sf_decrunch.vcproj > "${d}${d%/}.vcproj"
	fi
done
