#!/bin/bash
# Deploy compiled wheels and source archives to PYPI
# TWINE_USERNAME and TWINE_PASSWORD should set as global variables

# python setup.py artifacts are moved relative to the build dir.
pushd ${TRAVIS_BUILD_DIR}/bin/build/Open-FVS/python

if [ $TRAVIS_BRANCH = 'dev' ]; then
  echo "On dev branch, upload to testpypi."
  TWINE_REPOSITORY_URL=https://testpypi.python.org

elif [ $TRAVIS_BRANCH = 'master' ] && [ -z ${TRAVIS_TAG+x}]; then
  echo "On master branch with tag, upload to pypi."
  TWINE_REPOSITORY_URL=https://pypi.python.org

else
  popd
  exit 0
fi

echo $TWINE_REPOSITORY_URL

twine upload dist/*.gz --skip-existing

## PYPI doesn't accept binary wheels for linux
#twine upload dist/*.whl --skip-existing

popd
exit 0