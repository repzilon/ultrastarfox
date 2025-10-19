#! /bin/sh

ndd_prevhash=
sha256sum BIN/*.EXE BIN/*.exe TOOLS/*.EXE TOOLS/*.exe TOOLS/binaries/msdos/*.EXE TOOLS/binaries/msdos/*.exe | sort -u | while read ndd_hash ndd_path; do
	if [ "X$ndd_hash" = "X$ndd_prevhash" ]; then
		if [ "X$1" = "X--pretend" ]; then
			printf "%s\tis a duplicate\n" "$ndd_path"
		elif which trash > /dev/null; then
			trash "$ndd_path"
		else
			rm "$ndd_path"
		fi
	fi
	ndd_prevhash=$ndd_hash
done
