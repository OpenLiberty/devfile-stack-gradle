#!/bin/bash

buildStackImage() {

    echo "> Building Gradle Stack Image";
    
    stackImage=$(cat generated/devfile.yaml | grep "openliberty/application-stack-gradle:")
    stackImageVersion=$(echo ${stackImage##*:})
    echo "Using \"openliberty/application-stack-gradle:$stackImageVersion\" as tag name"
    docker build -t openliberty/application-stack-gradle:$stackImageVersion --build-arg stacklabel=$SHA -f generated/stackimage-Dockerfile stackimage
}

buildStack() {

    echo "> Building Gradle Stack";
    
    ./build.sh
    ls -al generated
}

# Execute the specified action.
if [ $# -ge 1 ]; then
    COMMAND=$1
    shift
fi
case "${COMMAND}" in
    buildStackImage)
        buildStackImage
    ;;
    buildStack)
        buildStack
    ;;
    *)
    echo "Invalid command. Allowed values: buildStackImage."
    exit 1
    ;;
esac