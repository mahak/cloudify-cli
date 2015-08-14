#!/bin/bash -e

AWS_ACCESS_KEY_ID=$1
AWS_ACCESS_KEY=$2

VERSION="3.3.0/m4-TEST/"
AWS_S3_BUCKET='gigaspaces-repository-eu/org/cloudify3/$VERSION'
CORE_TAG_NAME="master"
PLUGINS_TAG_NAME="master"

pip install wheel==0.24.0
pip install s3cmd==1.5.2

pip wheel --wheel-dir packaging/source/wheels https://github.com/cloudify-cosmo/cloudify-cli/archive/$CORE_TAG_NAME.zip#egg=cloudify-cli \
https://github.com/cloudify-cosmo/cloudify-rest-client/archive/$CORE_TAG_NAME.zip#egg=cloudify-rest-client \
https://github.com/cloudify-cosmo/cloudify-dsl-parser/archive/$CORE_TAG_NAME.zip#egg=cloudify-dsl-parser \
https://github.com/cloudify-cosmo/cloudify-plugins-common/archive/$CORE_TAG_NAME.zip#egg=cloudify-plugins-common \
https://github.com/cloudify-cosmo/cloudify-script-plugin/archive/$PLUGINS_TAG_NAME.zip#egg=cloudify-script-plugin


mkdir -p packaging/source/{pip,python,virtualenv}
pushd packaging/source/pip
curl -O https://dl.dropboxusercontent.com/u/407576/cfy-win-cli-package-resources/pip/get-pip.py
curl -O https://dl.dropboxusercontent.com/u/407576/cfy-win-cli-package-resources/pip/pip-6.1.1-py2.py3-none-any.whl
curl -O https://dl.dropboxusercontent.com/u/407576/cfy-win-cli-package-resources/pip/setuptools-15.2-py2.py3-none-any.whl
popd
pushd packaging/source/python
curl -O https://dl.dropboxusercontent.com/u/407576/cfy-win-cli-package-resources/python/python.msi
popd
pushd packaging/source/virtualenv
curl -O https://dl.dropboxusercontent.com/u/407576/cfy-win-cli-package-resources/virtualenv/virtualenv-12.1.1-py2.py3-none-any.whl
popd


iscc packaging/create_install_wizard.iss

if [ ! -z ${AWS_ACCESS_KEY} ]; then
    cd /home/Administrator/packaging/output/
    # no preserve is set to false only because preserving file attributes is not yet supported on Windows.
    python c:/Python27/Scripts/s3cmd put --force --acl-public --access_key=${AWS_ACCESS_KEY_ID} --secret_key=${AWS_ACCESS_KEY} \
        --no-preserve --progress --human-readable-sizes --check-md5 *.exe s3://${AWS_S3_BUCKET}/2.2.0/
fi
