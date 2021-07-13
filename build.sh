#!/bin/bash

####
# For more documentation, see:
#  https://github.com/OpenLiberty/application-stack/wiki/Open-Liberty-Application-Stack-Customization
####

#
# Base image used to build stack image
#
BASE_OS_IMAGE="${BASE_OS_IMAGE:-adoptopenjdk/openjdk11-openj9:ubi}"

#
# Version of Open Liberty runtime to use within both inner and outer loops
#
OL_RUNTIME_VERSION="${OL_RUNTIME_VERSION:-21.0.0.3}"

#
# The Open Liberty base image used in the final stage of the outer loop Dockerfile used to build your application image from
#
OL_UBI_IMAGE="${OL_UBI_IMAGE:-openliberty/open-liberty:21.0.0.3-full-java11-openj9-ubi}"

#
# The name and tag of the gradle stack image you will build.  This will used to create your inner loop development containers, and also as the base image for the first stage of your outer loop image build.
#
STACK_IMAGE="${STACK_IMAGE:-openliberty/application-stack-gradle:0.1}"

#
# URL at which your gradle outer loop Dockerfile is hosted
#
DEVFILE_DOCKERFILE_LOC="${DEVFILE_DOCKERFILE_LOC:-https://github.com/OpenLiberty/application-stack-gradle/releases/download/outer-loop-gradle-0.0.1/Dockerfile}"

#
# URL at which your outer loop deploy YAML template is hosted
#
DEVFILE_DEPLOY_YAML_LOC="${DEVFILE_DEPLOY_YAML_LOC:-https://github.com/OpenLiberty/application-stack-gradle/releases/download/outer-loop-0.0.1/app-deploy.yaml}"

#
# The previous major microprofile spec API version supported by the stack.
#
ECLIPSE_MP_API_PREV_VERSION="${ECLIPSE_MP_API_PREV_VERSION:-3.3}"

#
# The previous OpenLiberty major microprofile feature version supported by the stack.
#
OL_MP_FEATURE_PREV_VERSION="${OL_MP_FEATURE_PREV_VERSION:-3.3}"


# Generates application stack artifacts.
generate() {
    # Base customization.
    mkdir -p generated
    sed -e "s!{{.OL_RUNTIME_VERSION}}!$OL_RUNTIME_VERSION!; s!{{.STACK_IMAGE}}!$STACK_IMAGE!; s!{{.DEVFILE_DOCKERFILE_LOC}}!$DEVFILE_DOCKERFILE_LOC!; s!{{.DEVFILE_DEPLOY_YAML_LOC}}!$DEVFILE_DEPLOY_YAML_LOC!" templates/devfile.yaml > generated/devfile.yaml
    sed -e "s!{{.BASE_OS_IMAGE}}!$BASE_OS_IMAGE!; s!{{.OL_RUNTIME_VERSION}}!$OL_RUNTIME_VERSION!; s!{{.ECLIPSE_MP_API_PREV_VERSION}}!$ECLIPSE_MP_API_PREV_VERSION!; s!{{.OL_MP_FEATURE_PREV_VERSION}}!$OL_MP_FEATURE_PREV_VERSION!" templates/stackimage/Dockerfile > generated/stackimage-Dockerfile

    # Outer loop customization of Dockerfile
    sed -e "s!{{.STACK_IMAGE}}!$STACK_IMAGE!; s!{{.OL_UBI_IMAGE}}!$OL_UBI_IMAGE!; s!{{.OL_RUNTIME_VERSION}}!$OL_RUNTIME_VERSION!" templates/outer-loop/Dockerfile > generated/Dockerfile
}

# Execute the specified action. The generate action is the default if none is specified.
ACTION="generate"
if [ $# -ge 1 ]; then
    ACTION=$1
    shift
fi
case "${ACTION}" in
    generate)
        generate
    ;;
    *)
    echo "Invalid input action. Allowed action values: generate. Default: generate."
    exit 1
    ;;
esac
