#!/bin/bash -e

function install_requirements() {
    pip install wheel==0.24.0
}

function download_wheels() {
    GITHUB_USERNAME=$1
    GITHUB_PASSWORD=$2

    mkdir -p packaging/source/wheels
    curl -LO https://pypi.python.org/packages/2.7/l/lxml/lxml-3.5.0.win32-py2.7.exe
    wheel convert lxml-3.5.0.win32-py2.7.exe --dest-dir packaging/source/wheels

    PATCH_URL="https://raw.githubusercontent.com/cloudify-cosmo/cloudify-cli/3.4.0.2/packaging/omnibus/config/patches/cloudify-cli/cloudify_cli.patch"
    curl -sLO https://github.com/cloudify-cosmo/cloudify-cli/archive/3.4.0.2.zip
    unzip -q -o 3.4.0.2.zip
    [[ -f 3.4.0.2.zip ]] && rm -f 3.4.0.2.zip
    curl -sL "${PATCH_URL}" -o cloudify-cli-3.4.0.2/cloudify_cli.patch
    patch -p1 -d cloudify-cli-3.4.0.2 < cloudify-cli-3.4.0.2/cloudify_cli.patch
    rm -f cloudify-cli-3.4.0.2/cloudify_cli.patch
    zip -q -r cloudify-cli-3.4.0.2.zip cloudify-cli-3.4.0.2
    [[ $? -eq 0 ]] && rm -rf cloudify-cli-3.4.0.2

    pip wheel --wheel-dir packaging/source/wheels --find-links packaging/source/wheels C:/Cygwin/home/Administrator/cloudify-cli-3.4.0.2.zip \
    https://github.com/cloudify-cosmo/cloudify-rest-client/archive/${CORE_TAG_NAME}.zip#egg=cloudify-rest-client \
    https://github.com/cloudify-cosmo/cloudify-dsl-parser/archive/3.4.0.2.zip#egg=cloudify-dsl-parser \
    https://github.com/cloudify-cosmo/cloudify-plugins-common/archive/${CORE_TAG_NAME}.zip#egg=cloudify-plugins-common \
    https://github.com/cloudify-cosmo/cloudify-script-plugin/archive/1.4.zip#egg=cloudify-script-plugin \
    https://github.com/cloudify-cosmo/cloudify-fabric-plugin/archive/1.4.1.zip#egg=cloudify-fabric-plugin \
    https://github.com/cloudify-cosmo/cloudify-openstack-plugin/archive/1.4.zip#egg=cloudify-openstack-plugin \
    https://github.com/cloudify-cosmo/cloudify-aws-plugin/archive/1.4.zip#egg=cloudify-aws-plugin \
    https://github.com/cloudify-cosmo/tosca-vcloud-plugin/archive/1.3.1.zip#egg=cloudify-vcloud-plugin \
    https://github.com/cloudify-cosmo/cloudify-vsphere-plugin/archive/2.0.zip#egg=cloudify-vsphere-plugin \
    https://$GITHUB_USERNAME:$GITHUB_PASSWORD@github.com/cloudify-cosmo/cloudify-softlayer-plugin/archive/1.3.1.zip#egg=cloudify-softlayer-plugin
}

function download_resources() {

    GITHUB_USERNAME=$1
    GITHUB_PASSWORD=$2
    TELCO_MODE=$3
    
    mkdir -p packaging/source/{python,blueprints,types,scripts,plugins}
    pushd packaging/source/python
        curl -L http://gigaspaces-repository-eu.s3.amazonaws.com/org/cloudify3/components/Python279_x32.tar.gz -o /tmp/Python279_x32.tar.gz
        tar -zxvf /tmp/Python279_x32.tar.gz --strip-components=1
    popd
    pushd packaging/source/blueprints
        echo "TELCO_MODE=$TELCO_MODE"
        if [ "$TELCO_MODE" == "true" ]; then
            curl -L https://github.com/cloudify-cosmo/cloudify-manager-blueprints/archive/3.4.0.2-telco.tar.gz -o /tmp/cloudify-manager-blueprints.tar.gz
        else
            curl -L https://github.com/cloudify-cosmo/cloudify-manager-blueprints/archive/3.4.0.2.tar.gz -o /tmp/cloudify-manager-blueprints.tar.gz
        fi
        tar -zxvf /tmp/cloudify-manager-blueprints.tar.gz --strip-components=1
    popd

    # Downloading types.yaml
    pushd packaging/source/types
        curl -LO http://getcloudify.org.s3.amazonaws.com/spec/cloudify/${CORE_TAG_NAME}/types.yaml
    popd

    # Downloading Scripts
    pushd packaging/source/scripts
        curl -LO https://raw.githubusercontent.com/cloudify-cosmo/cloudify-manager/${CORE_TAG_NAME}/resources/rest-service/cloudify/fs/mkfs.sh
        curl -LO https://raw.githubusercontent.com/cloudify-cosmo/cloudify-manager/${CORE_TAG_NAME}/resources/rest-service/cloudify/fs/fdisk.sh
        curl -LO https://raw.githubusercontent.com/cloudify-cosmo/cloudify-manager/${CORE_TAG_NAME}/resources/rest-service/cloudify/fs/mount.sh
        curl -LO https://raw.githubusercontent.com/cloudify-cosmo/cloudify-manager/${CORE_TAG_NAME}/resources/rest-service/cloudify/fs/unmount.sh
        curl -LO https://raw.githubusercontent.com/cloudify-cosmo/cloudify-manager/${CORE_TAG_NAME}/resources/rest-service/cloudify/policies/host_failure.clj
        curl -LO https://raw.githubusercontent.com/cloudify-cosmo/cloudify-manager/${CORE_TAG_NAME}/resources/rest-service/cloudify/policies/threshold.clj
        curl -LO https://raw.githubusercontent.com/cloudify-cosmo/cloudify-manager/${CORE_TAG_NAME}/resources/rest-service/cloudify/policies/ewma_stabilized.clj
        curl -LO https://raw.githubusercontent.com/cloudify-cosmo/cloudify-manager/${CORE_TAG_NAME}/resources/rest-service/cloudify/triggers/execute_workflow.clj
    popd

    # Downloading plugin yamls
    pushd packaging/source/plugins
        mkdir -p {fabric-plugin,script-plugin,diamond-plugin,openstack-plugin,aws-plugin,tosca-vcloud-plugin,vsphere-plugin,softlayer-plugin}

        curl -L https://raw.githubusercontent.com/cloudify-cosmo/cloudify-fabric-plugin/1.4.1/plugin.yaml -o fabric-plugin/plugin.yaml
        curl -L https://raw.githubusercontent.com/cloudify-cosmo/cloudify-script-plugin/1.4/plugin.yaml -o script-plugin/plugin.yaml
        curl -L https://raw.githubusercontent.com/cloudify-cosmo/cloudify-diamond-plugin/1.3.3/plugin.yaml -o diamond-plugin/plugin.yaml
        curl -L https://raw.githubusercontent.com/cloudify-cosmo/cloudify-openstack-plugin/1.4/plugin.yaml -o openstack-plugin/plugin.yaml
        curl -L https://raw.githubusercontent.com/cloudify-cosmo/cloudify-aws-plugin/1.4/plugin.yaml -o aws-plugin/plugin.yaml
        curl -L https://raw.githubusercontent.com/cloudify-cosmo/tosca-vcloud-plugin/1.3.1/plugin.yaml -o tosca-vcloud-plugin/plugin.yaml
        curl -L https://$GITHUB_USERNAME:$GITHUB_PASSWORD@raw.githubusercontent.com/cloudify-cosmo/cloudify-softlayer-plugin/1.3.1/plugin.yaml -o softlayer-plugin/plugin.yaml

        # Downloading commercial plugin yamls
        curl -L https://raw.githubusercontent.com/cloudify-cosmo/cloudify-vsphere-plugin/2.0/plugin.yaml -o vsphere-plugin/plugin.yaml
    popd
}

function update_remote_to_local_links() {
    sed -i -e 's/https:\/\/raw\.githubusercontent\.com\/cloudify-cosmo\/cloudify-manager\/.*\/resources\/rest-service\/cloudify\/.*\//file:\/cfy\/cloudify\/scripts\//g' packaging/source/types/types.yaml
}

# VERSION/PRERELEASE/BUILD/CORE_TAG_NAME/PLUGINS_TAG_NAME must be exported as they are being read as an env var by the install wizard

CORE_TAG_NAME="3.4"
curl https://raw.githubusercontent.com/cloudify-cosmo/cloudify-packager/3.4.0.2/common/provision.sh -o ./common-provision.sh &&
source common-provision.sh

GITHUB_USERNAME=$1
GITHUB_PASSWORD=$2
AWS_ACCESS_KEY_ID=$3
AWS_ACCESS_KEY=$4
TELCO_MODE=$5

if [ "$TELCO_MODE" == "true" ];then
    export PREFIX_NAME="cloudify-telecom"
else
	export PREFIX_NAME="cloudify"
fi

install_requirements &&
download_wheels $GITHUB_USERNAME $GITHUB_PASSWORD &&
download_resources $GITHUB_USERNAME $GITHUB_PASSWORD &&
update_remote_to_local_links &&
iscc packaging/create_install_wizard.iss &&
cd /home/Administrator/packaging/output/ && create_md5 "exe"  &&
[ -z ${AWS_ACCESS_KEY} ] || upload_to_s3 "exe" && upload_to_s3 "md5"
