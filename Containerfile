ARG SOURCE_IMAGE="silverblue"
ARG SOURCE_SUFFIX="-main"
ARG SOURCE_TAG="40"
FROM ghcr.io/ublue-os/${SOURCE_IMAGE}${SOURCE_SUFFIX}:${SOURCE_TAG}
FROM ghcr.io/ublue-os/fsync-kernel:6.9.7

COPY --from=ghcr.io/ublue-os/akmods-nvidia:fsync-40 /rpms /tmp/akmods-rpms
COPY --from=fsync-kernel:6.9.7 /tmp/rpms /tmp/fsync-rpms
RUN rpm-ostree cliwrap install-to-root / && \
#    rpm-ostree override replace \
#        --experimental \
#            /tmp/fsync-rpms/kernel-6.9.7-201.fsync.fc40.x86_64.rpm \
#            /tmp/fsync-rpms/kernel-core-6.9.7-201.fsync.fc40.x86_64.rpm \
#            /tmp/fsync-rpms/kernel-headers-6.9.7-201.fsync.fc40.x86_64.rpm \
#            /tmp/fsync-rpms/kernel-modules-6.9.7-201.fsync.fc40.x86_64.rpm \
#            /tmp/fsync-rpms/kernel-uki-virt-6.9.7-201.fsync.fc40.x86_64.rpm && \
    rpm-ostree override replace --experimental --from=fsync-kernel kernel kernel-headers kernel-core kernel-modules kernel-modules-core kernel-modules-extra kernel-uki-virt kernel-devel-matched && \
    ostree container commit

COPY build.sh /tmp/build.sh

RUN rpm-ostree cliwrap install-to-root / && \
    mkdir -p /var/lib/alternatives && \
#    curl -Lo /etc/yum.repos.d/copr_fsync.repo https://copr.fedorainfracloud.org/coprs/sentry/kernel-fsync/repo/fedora-${SOURCE_TAG}/sentry-kernel-fsync-fedora-${SOURCE_TAG}.repo && \
#    rpm-ostree override replace --experimental --from repo='copr:copr.fedorainfracloud.org:sentry:kernel-fsync' kernel kernel-headers kernel-core kernel-modules kernel-modules-core kernel-modules-extra kernel-uki-virt kernel-devel-matched && \
#    rpm-ostree override replace --experimental '/tmp/fsync-rpms/kernel-6.9.7-201.fsync.fc40.x86_64.rpm' '/tmp/fsync-rpms/kernel-core-6.9.7-201.fsync.fc40.x86_64.rpm' '/tmp/fsync-rpms/kernel-headers-6.9.7-201.fsync.fc40.x86_64.rpm' '/tmp/fsync-rpms/kernel-modules-6.9.7-201.fsync.fc40.x86_64.rpm /tmp/fsync-rpms/kernel-uki-virt-6.9.7-201.fsync.fc40.x86_64.rpm' && \
    curl -Lo /tmp/nvidia-install.sh https://raw.githubusercontent.com/ublue-os/hwe/main/nvidia-install.sh && \
    chmod +x /tmp/nvidia-install.sh && \
    FEDORA_MAJOR_VERSION=40 IMAGE_NAME="main" RPMFUSION_MIRROR="" /tmp/nvidia-install.sh && \
    /tmp/build.sh && \
    ostree container commit

    rpm-ostree override replace \
        --experimental \
            /tmp/fsync-rpms/kernel-6*.rpm \
            /tmp/fsync-rpms/kernel-core-*.rpm \
            /tmp/fsync-rpms/kernel-modules-*.rpm \
            /tmp/fsync-rpms/kernel-uki-virt-*.rpm \
