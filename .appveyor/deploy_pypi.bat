@echo off
:: Deploy compiled wheels and source archives to PYPI
:: TWINE_USERNAME and TWINE_PASSWORD should set as global variables

REM pushd %APPVEYOR_BUILD_FOLDER%\bin\build\Open-FVS\python
pushd %APPVEYOR_BUILD_FOLDER%\python

if "%APPVEYOR_REPO_BRANCH%" == "dev" (
    echo On dev branch, deploy to PYPI test.
    set TWINE_REPOSITORY_URL=https://testpypi.python.org/pypi
    goto upload
)

if "%APPVEYOR_REPO_BRANCH%" == "master" (
    if "%APPVEYOR_REPO_TAG%" == "true" (
        echo Tagged commit on master, deploying to pypi.
        set TWINE_REPOSITORY_URL=https://pypi.python.org/pypi
        goto upload
    )
)

echo Not a tag on master, nor dev, skipping pypi deploy.
goto exit

:upload
echo Call twine to upload packages.
call twine upload --skip-existing dist/*
echo Done.

:exit
popd
