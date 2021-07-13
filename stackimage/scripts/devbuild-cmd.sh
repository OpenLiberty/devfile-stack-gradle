#!/bin/sh

if [ -e /projects/.disable-bld-cmd ];
then
    echo "found the disable file" && echo "devBuild command will not run" && exit 0;
else
    if [ ! -e /projects/build.gradle ];
	then 
             echo
             echo "  ERROR: build.gradle not found. Non-viable or empty gradle project. Please add src code and re-push";
             echo
             exit 1
	else
         echo "will run the devBuild command" && mkdir -p /projects/build
         if [ ! -d /projects/build/wlp ]; then 
             echo "...moving liberty"; mv /opt/ol/wlp /projects/build; touch ./.liberty-mv;
         elif [[ -d /projects/build/wlp && ! -e /projects/.liberty-mv ]]; then
             echo "STACK WARNING - LIBERTY RUNTIME WAS LOADED FROM HOST";
         fi
	fi
    gradle -g /.gradle assemble -Dliberty.runtime.version=$1
    touch ./.disable-bld-cmd
fi
