#!/bin/bash

set -eux

release=

if [ $# -gt 0 ]; then
    release=$1
fi


if [ "$release" = rawhide ]; then
    cid=$(curl -sSf https://kojipkgs.fedoraproject.org/compose/rawhide/latest-Fedora-Rawhide/COMPOSE_ID \
        | grep '^Fedora-Rawhide-[0-9a-z.]\+$')
    version=${cid#Fedora-Rawhide-}
    img_url=https://kojipkgs.fedoraproject.org/compose/rawhide/latest-Fedora-Rawhide/compose/Cloud/x86_64/images/Fedora-Cloud-Base-Generic-Rawhide-"$version".x86_64.qcow2
    img=Fedora-Cloud-Base-Generic-Rawhide-"$version".x86_64.qcow2
else
    latest=$(curl -sSf https://kojipkgs.fedoraproject.org/compose/cloud/ \
	| awk -F'"' ' /latest-Fedora-Cloud-'"$release"'/ {
	    s=$(NF-1);
	    sub("/", "", s); print s;
	}' \
	| sort -V \
	| tail -n 1 \
	| grep '^latest[a-zA-Z0-9-]\+$')


    cid=$(curl -sSf https://kojipkgs.fedoraproject.org/compose/cloud/"$latest"/COMPOSE_ID \
	  | grep '^Fedora-Cloud[0-9.-]\+$' )
    version=${cid#Fedora-Cloud-}
    img_url=https://kojipkgs.fedoraproject.org/compose/cloud/"$latest"/compose/Cloud/x86_64/images/Fedora-Cloud-Base-Generic-"$version".x86_64.qcow2
    img=Fedora-Cloud-Base-Generic-"$version".x86_64.qcow2
fi


if curl -sSf -o "$img" "$img_url" ; then
    # i.e. Fedora 41 scheme
    :
else
    # i.e. Fedora 40 scheme
    img_url=https://kojipkgs.fedoraproject.org/compose/cloud/"$latest"/compose/Cloud/x86_64/images/Fedora-Cloud-Base-Generic.x86_64-"$version".qcow2
    curl -sSf -o "$img" "$img_url"
fi

ln -sf "$img" f"$release"-latest.x86_64.qcow2
