# Application Stack Gradle

Application stack built with gradle.

* [Build](#build)
* [Test](#test)

## Build

### Prereq
- Gradle 6.8.1 or later to build artiafcts.

### Procedure

1. Generate the needed artifacts with build.sh.

You can run build.sh with the target customization values as inputs or you can update the build.sh script itself if you intend run the script with no inputs.

**Examples:**

- Using customization arguments:

```
BASE_OS_IMAGE=adoptopenjdk/openjdk14-openj9:ubi \
OL_RUNTIME_VERSION=21.0.0.1 \
OL_UBI_IMAGE=openliberty/open-liberty:21.0.0.1-kernel-slim-java14-openj9-ubi \
STACK_IMAGE=<my-repo>/<image>:<tag> \
...
./build.sh
```

- Updating default values in build.sh:

```
vi build.sh
```
```
...
BASE_OS_IMAGE="${BASE_OS_IMAGE:-adoptopenjdk/openjdk14-openj9:ubi}"
OL_RUNTIME_VERSION="${OL_RUNTIME_VERSION:-20.0.0.11}"
OL_UBI_IMAGE="${OL_UBI_IMAGE:-openliberty/open-liberty:20.0.0.11-kernel-slim-java14-openj9-ubi}"
STACK_IMAGE="${STACK_IMAGE:-<my-repo>/<image>:<tag>}"
...
```
```
./build.sh
```

2. Copy the generated stack image Dockerfile to the stackimage directory.

```
cd stackimage
```

```
cp generated/stackimage-Dockerfile Dockerfile
```

3. Build the stack image

```
docker build -t <value of STACK_IMAGE in build.sh> .
```

4. Push the built image to an accessible repository.

```
docker push <value of STACK_IMAGE in build.sh>
```

5. [Test](#test) your build.

## Test

### Prereq
- ODO CLI 2.0.5 or later for testing.
- Kubernetes Cluster for testing. For the procedure that follows an OpenShift cluster is used.

### Procedure

1. Copy the generated devfile to your gradle application project root directory.

```
cd <path-to-gradle-project-root-dir>
```
```
cp <path-to>/generated/devfile.yaml <path-to-gradle-project-root-dir>/.
```

2. Create an ODO component..

```
odo create gradleStackTest
```

3. Push of the gradle application artifacts to the cluster.

```
odo push 
```

4. Validate that the application was deployed successfully using the generated route host to access your application.

```
oc get route -l app.kubernetes.io/instance=customizationsample
```
```
Sample output:

NAME                      HOST/PORT                                                     PATH   SERVICES              PORT   TERMINATION   WILDCARD
ep1-customizationsample   ep1-customizationsample-custom.apps.xxxxxxx.yy.zzz.aaa.com   /      customizationsample   9080                 None

```
5. Clean up.

```
odo delete
```