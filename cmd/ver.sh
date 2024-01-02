#!/bin/bash

params2=${2:-"patch"}

# 使用 grep、awk、sed 提取版本号
version=$(grep "version" package.json | awk -F'"' '{print $4}')
name=$(grep "name" package.json | awk -F'"' '{print $4}')


# 移除预发布信息，如果有的话
version_without_prerelease=$(echo $version | cut -d '-' -f 1)

if [ $# -eq 0 ]; then
	new_version=$(awk 'BEGIN{FS=OFS="."} {$NF; print}' <<< $version_without_prerelease)
elif [ $1 = "RELEASE" ] || [ $1 = "SNAPSHOT" ]; then
	if [ $params2 = "major" ]; then
		new_version=$(awk 'BEGIN{FS=OFS="."} {++$1; print}' <<< $version_without_prerelease"-"$1)
	elif [ $params2 = "minor" ]; then
		new_version=$(awk 'BEGIN{FS=OFS="."} {++$2; print}' <<< $version_without_prerelease"-"$1)
	elif [ $params2 = "patch" ]; then
		new_version=$(awk 'BEGIN{FS=OFS="."} {++$3; print}' <<< $version_without_prerelease)
		new_version=$new_version"-"$1
	fi
else
    new_version=$(awk 'BEGIN{FS=OFS="."} {$NF; print}' <<< $version_without_prerelease"-"$1)
fi


# echo 当前版本号: $version
# echo 移除预发布信息的版本号: $version_without_prerelease
# echo 新版本号: $new_version


# 更新 package.json 中的版本号
# sed -i 's/"version": "'"$version"'"/"version": "'"$new_version"'"/' package.json

npm version $new_version --no-git-tag-version

npm publish 

if [ $1 = "RELEASE" ]; then
	git add package.json
	git commit -m "release: $name@$new_version"
	git tag $name@$new_version
	git push
else
	git checkout package.json
fi