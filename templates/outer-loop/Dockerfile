# Step 1: Build the user's application.
FROM {{.STACK_IMAGE}} as compile

# Make a well known place for shared library jars separate from the rest of the <server> contents (to help with caching).
RUN mkdir /work/configlibdir \
   && mkdir /work/config \
   &&  mkdir /work/shared

# Copy application source and build data.
COPY --chown=1001:0 ./. /work/outer-loop-app/tmp/
RUN cp -r /work/outer-loop-app/tmp/src /work/outer-loop-app/.; \
    cp /work/outer-loop-app/tmp/build.gradle  /work/outer-loop-app/.
RUN cp -r /work/outer-loop-app/tmp/*.gradle /work/outer-loop-app/tmp/gradle.* /work/outer-loop-app/tmp/gradle* /work/outer-loop-app/. 2>/dev/null | true; \
    rm -rf /work/outer-loop-app/tmp

# Build the application and create the Open Liberty installation.
# This step removes quick-start-security.xml since it's convenient for local dev mode but should not be in the production image.
RUN cd /work/outer-loop-app && \
    echo "QUICK START SECURITY IS NOT SECURE FOR PRODUCTION ENVIRONMENTS. IT IS BEING REMOVED" && \
    rm -f src/main/liberty/config/configDropins/defaults/quick-start-security.xml && \
    gradle -g /.gradle assemble libertyCreate -Dliberty.runtime.version={{.OL_RUNTIME_VERSION}}

# Process any resources or shared libraries - if they are present in the dependencies block for this project (there may be none potentially)
# test to see if each is present and move to a well known location for later processing in the next stage
RUN cd /work/outer-loop-app/build/wlp/usr/servers; \
    if [ -d ./*/lib ]; then mv ./*/lib /work/configlibdir; fi && \
    if [ ! -d /work/configlibdir/lib ]; then mkdir /work/configlibdir/lib; fi && \
    mv -f */* /work/config/ && \
    rm -rf /work/config/workarea && \
    chmod -R 770 /work/config/apps && \
    if [ -d ../shared ]; then mv ../shared/* /work/shared/; fi

# Step 2: Package Open Liberty image
FROM {{.OL_UBI_IMAGE}}

# 2a) Copy user defined shared resources.
COPY --from=compile --chown=1001:0 /work/shared /opt/ol/wlp/usr/shared/

# 2b) Copy user defined shared libraries.
COPY --from=compile --chown=1001:0 /work/configlibdir/ /config

# 2c) Copy user defined server config, bootstrap.properties, etc.
COPY --from=compile --chown=1001:0 /work/config/ /config/

# 2d) Add the microprofile health feature configuration if it is not already defined in the user's configuration.
#     This allows k8s to use the deployment's health probes.
#     To skip this step, use the ADD_MP_HEALTH argument when building the outer loop image. 
#     The allowed values are true/false.  The default value is true.
#     Example usage: docker build --build-arg ADD_MP_HEALTH=false ...
RUN mkdir -p /tmp/stack/config/configDropins/defaults
COPY --from=compile --chown=1001:0 /stack/ol/config/configDropins/defaults/ /tmp/stack/config/configDropins/defaults/

ARG ADD_MP_HEALTH=true
RUN if [ "$ADD_MP_HEALTH" = "true" ]; then \
        /opt/ol/wlp/bin/server start && \
        /opt/ol/wlp/bin/server stop && \
        if ! grep "CWWKF0012I" /logs/messages.log | grep -q 'mpHealth-[0-9]*.[0-9]*\|microProfile-[0-9]*.[0-9]*'; then \
            echo "Missing mpHealth feature - adding config snippet" && \
            cp /tmp/stack/config/configDropins/defaults/liberty-stack-mpHealth.xml /config/configDropins/overrides; \
        else \
            echo "Found mpHealth feature - not adding config snippet"; \
        fi && \
        rm -rf /liberty/output/.classCache && \
        rm -rf /output/* && \
        rm -rf /logs/*; \
    elif [ "$ADD_MP_HEALTH" != "false" ]; then \
        echo "Invalid ADD_MP_HEALTH value: $ADD_MP_HEALTH. Valid values are \"true\" | \"false\" "; \
    fi

RUN rm -rf /tmp/stack

# 2e) Copy the application binary.
COPY --from=compile --chown=1001:0 /work/outer-loop-app/build/libs/*.[ew]ar /config/apps

# 2f) Set the SCC environment variable.
#     To set the SCC environment variable value, use the ENABLE_OPENJ9_SCC argument when building the outer loop image.
#     The allowed values are true/false. The default value is true. 
#     Example usage: docker build --build-arg ENABLE_OPENJ9_SCC=false ...
ARG ENABLE_OPENJ9_SCC=true
RUN if [[ "$ENABLE_OPENJ9_SCC" != "true" && "$ENABLE_OPENJ9_SCC" != "false" ]]; then \
        echo "Invalid ENABLE_OPENJ9_SCC value: $ENABLE_OPENJ9_SCC. Valid values are \"true\" | \"false\"." && \
        exit 1; \
    fi

ENV OPENJ9_SCC=$ENABLE_OPENJ9_SCC

# 2g) Run configure.sh
RUN configure.sh && \
    chmod 664 /opt/ol/wlp/usr/servers/*/configDropins/defaults/keystore.xml