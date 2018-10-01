#! /bin/sh

# Refer to http://unity.grimdork.net/ to see what form the URLs should take

BASE_URL=https://netstorage.unity3d.com/unity
HASH=ae1180820377
VERSION=2018.2.8f1

getFileName() {
    echo "${UNITY_DOWNLOAD_CACHE}/`basename "$1"`"
}

download() {
    file=$1
    url="$BASE_URL/$HASH/$file"
    filePath=$(getFileName $file)
    fileName=`basename "$file"`

    if [ ! -e $filePath ] ; then
        echo "Downloading $filePath from $url: "
        curl --retry 5 -o "$filePath" "$url"
    else
        echo "$fileName exists in cache. Skipping download."
    fi
}

install() {
    package=$1
    filePath=$(getFileName $package)

    download "$package"

    echo "Installing $filePath"
    sudo installer -dumplog -package "$filePath" -target /

}

install "MacEditorInstaller/Unity-$VERSION.pkg"
install "MacEditorTargetInstaller/UnitySetup-iOS-Support-for-Editor-$VERSION.pkg"
