#!/bin/bash

#error message sent to builderror
builderror="Build/error_log"
exec 2>$builderror

#	params num less than 1
# if [[ $# -lt 1 ]]; then #
# 	exit -1
# fi

if [[ $1 = '-f' ]]; then
	conf=$2
# 	app_version_string=$3
# 	app_version=$3
# 	if [[ $# -eq 4 ]]; then
# 		app_version=$4
# 	fi
# else
# 	app_version_string=$1
# 	app_version=$1
# 	if [[ $# -eq 2 ]]; then
# 		app_version=$2
# 	fi
fi

# if [[ -z $app_version_string || $app_version_string =~ \d+(\.\d+)* ]]; then
# 	echo -e "\033[0;31mapp short version is wrong:$app_version_string\033[0m"
# 	exit -1
# fi
# if [[ -z !$app_version || $app_version =~ \d+(\.\d+)* ]]; then
# 	echo -e "\033[0;31mapp version is wrong:${app_version}\033[0m"
# 	exit -1
# fi

if [[ $conf ]]; then
	list=($conf)
else
	list=`ls configs/*.conf`
fi

function build(){

	echo ">>>>>>>>>>>>>>>>>>>>>>>>>"

	if [[ !(-s $1) ]]; then
		echo "file dont exist:$1" 1>&2
		return
	fi

	echo "clean variables"
	# app_id=''
	app_version=‘’
	app_version_string=‘’
	app_name=''
	app_bundle_id=''
	app_product_name=''
	app_scheme=''
	app_icon_path=''
	umeng_key=''
	apple_id=''
	provisioning_profile_uuid=''
	config_name=''
	code_push_key=''
	team_id=''

	. ./$1
	app_icon_path="configs/icons/${config_name}/"
	app_image_path="configs/launchImages/${config_name}/"

	if [[ -z $app_version_string || $app_version_string =~ \d+(\.\d+)* ]]; then
		echo -e "\033[0;31mapp short version is wrong:$app_version_string\033[0m"
		exit -1
	fi
	if [[ -z !$app_version || $app_version =~ \d+(\.\d+)* ]]; then
		echo -e "\033[0;31mapp version is wrong:${app_version}\033[0m"
		exit -1
	fi

	info_file='hatsune/Info.plist'
#	constant_file='${YOUR_PROJECT_FOLDER}/MBConstants_mb.m'
	project_file='hatsune.xcodeproj/project.pbxproj'
	appDelegate_file='hatsune/AppDelegate.m'
	# google_file='${YOUR_PROJECT_FOLDER}/GoogleService-Info.plist'
	echo "using conf:$1"
	echo "backup files:"
	echo "> ${info_file}.bp"
#	echo "> ${constant_file}.bp"
	echo "> ${project_file}.bp"
	echo "> ${appDelegate_file}.bp"
	cp $info_file ${info_file}.bp
#	cp $constant_file ${constant_file}.bp
	cp $project_file ${project_file}.bp
	cp $appDelegate_file ${appDelegate_file}.bp

	# copy config file
	# rm -rf ../app/config/*.png
	\cp -R ../multiChannel/$config_name/* ../app/config/

	if [[ $app_icon_path ]]; then
		echo "copy icons from:${app_icon_path}"
		cp -R ${app_icon_path} hatsune/Images.xcassets/AppIcon.appiconset
		cp -R ${app_image_path} hatsune/Images.xcassets/LaunchImage.launchimage
	fi

	echo "create the app on iTC and Dev portal"
	fastlane produce --username ${apple_id} --app_identifier ${app_bundle_id} --app_name ${app_name} --language "Simplified Chinese"

	echo "create push the Certs"
	fastlane pem --username ${apple_id} --app_identifier ${app_bundle_id} --output_path ./configs/pushCerts/ --p12_password "111111"
	fastlane pem --username ${apple_id} --app_identifier ${app_bundle_id} --output_path ./configs/pushCerts/ --p12_password "111111" --development

	echo "sync match"
	# fastlane match --git_branch ${apple_id} -y appstore -a ${app_bundle_id} -u ${apple_id} -r "http://192.168.0.124/mike/certificates.git" --force_for_new_devices
	fastlane match --git_branch ${apple_id} -y appstore -a ${app_bundle_id} -u ${apple_id} -r "http://192.168.0.124/mike/certificates.git" --force_for_new_devices

	echo "enter the profile uuid:"
	read provisioning_profile_uuid
	echo "enter the team id:"
	read team_id

	echo ">> start building"

	echo ">> editing file:${appDelegate_file}"
	if [[ $umeng_key ]]; then
		echo "changing umeng key to:${umeng_key}"
		sed -i '' "s/UMENG_KEY/${umeng_key}/" $appDelegate_file #to be confirmed
	fi
	# if [[ $ga_key ]]; then
	# 	echo "changing ga key to: ${ga_key}"
	# 	sed -i '' "s/${YOUR_GA_KEY}/${ga_key}/" $appDelegate_file
		# echo ">> editing file:${google_file}"
		# sed -i '' "s/${YOUR_GA_KEY}/${ga_key}/"  $google_file
	# fi
	# sed -i '' "s/${YOUR_BUNDLE_ID}/${app_bundle_id}/"  $google_file

	echo ">> editing file:${info_file}"
	echo "changing app id to:${app_id}"
	# /usr/libexec/PlistBuddy -c "Set :AppStoreID ${app_id}" $info_file
	echo "set app version string:${app_version_string}"
	/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString ${app_version_string}" $info_file
	echo "set app version:${app_version}"
	/usr/libexec/PlistBuddy -c "Set :CFBundleVersion ${app_version}" $info_file
	echo "changing app name to:$app_product_name"
	/usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName ${app_product_name}" $info_file
	if [[ $app_scheme ]]; then
		echo "changing app scheme to:${app_scheme}"
		/usr/libexec/PlistBuddy -c "Set :CFBundleURLTypes:0:CFBundleURLSchemes:0 ${app_scheme}" $info_file
		/usr/libexec/PlistBuddy -c "Set :CFBundleURLTypes:0:CFBundleURLName ${app_bundle_id}" $info_file
	fi
	if [[ $code_push_key ]]; then
		echo "changing code push deployment key:${code_push_key}"
		/usr/libexec/PlistBuddy -c "Set :CodePushDeploymentKey ${code_push_key}" $info_file
	fi
	# if [[ $weibo_key ]]; then
	# 	echo "changing weibo scheme to:wb${weibo_key}"
	# 	/usr/libexec/PlistBuddy -c "Set :CFBundleURLTypes:2:CFBundleURLSchemes:0 wb${weibo_key}" $info_file
	# fi
	# if [[ $qq_id ]]; then
	# 	echo "changing qq scheme to:tencent${qq_id}"
	# 	/usr/libexec/PlistBuddy -c "Set :CFBundleURLTypes:3:CFBundleURLSchemes:0 tencent${qq_id}" $info_file
	# fi

#	if [[ $app_scheme ]]; then
#		echo "changing alipay scheme to:${app_scheme}"
#		sed -i '' "s/${YOUR_APP_SCHEME}/${app_scheme}/" $constant_file
#	fi
#	if [[ $qq_id ]]; then
#		echo "changing qq id to:${qq_id}"
#		sed -i '' "s/${YOUR_QQ_ID}/${qq_id}/" $constant_file
#	fi
#	if [[ $weibo_key ]]; then
#		echo "changing weibo key to:${weibo_key}"
#		sed -i '' "s/${YOUR_WEIBO_KEY}/${weibo_key}/" $constant_file
#	fi
#	if [[ $weibo_secret ]]; then
#		echo "changing weibo secret to:${weibo_secret}"
#		sed -i '' "s/${YOUR_WEIWEB_SECRET}/${weibo_secret}/" $constant_file
#	fi
#	echo "changing app name to:${app_name}"
#	sed -i '' "s/${YOUR_APP_NAME}/${app_name}/" $constant_file



	echo "> editing project file"
	echo "changing target name to: ${app_product_name}"
	sed -i '' "s/PRODUCT_NAME = .*\";$/PRODUCT_NAME = \"${app_product_name}\";/" $project_file
	echo "changing bundle id to: ${app_bundle_id}"
	sed -i '' "s/PRODUCT_BUNDLE_IDENTIFIER = .*;/PRODUCT_BUNDLE_IDENTIFIER = ${app_bundle_id};/" $project_file
	echo "changing CODE_SIGN_IDENTITY to: auto"
	sed -i '' "s/CODE_SIGN_IDENTITY = .*\"/CODE_SIGN_IDENTITY = \"iPhone Distribution\"/" $project_file
	sed -i '' "s/CODE_SIGN_IDENTITY\[sdk=iphoneos\*\].*;/CODE_SIGN_IDENTITY[sdk=iphoneos*]\" = \"iPhone Distribution\";/" $project_file
	echo "changing provisioning profile to:${provisioning_profile_uuid}"
	sed -i '' "s/PROVISIONING_PROFILE = .*\"/PROVISIONING_PROFILE = \"${provisioning_profile_uuid}\"/" $project_file
	echo "changing development team to:${team_id}"
	sed -i '' "/ECD6R8BSQA/!s/DEVELOPMENT_TEAM = .*/DEVELOPMENT_TEAM = ${team_id};/" $project_file
	sed -i '' "/ECD6R8BSQA/!s/DevelopmentTeam = .*/DevelopmentTeam = ${team_id};/" $project_file

	ipa_path='Build/'
	ipa_name=${app_product_name}_${app_version_string}
	echo ">> run gym"
	fastlane gym --scheme ${app_scheme} --clean true --configuration "Release" --output_directory ${ipa_path} --output_name $ipa_name --include_symbols
	# fastlane gym --scheme ${app_scheme} --clean true --configuration "Ad-hoc" --output_directory ${ipa_path} --use_legacy_build_api true --output_name $ipa_name --include_symbols true

	echo ">> done build $1"
	echo ">> create Deliverfile"
	echo "submission_information({
	add_id_info_uses_idfa:true,
	add_id_info_serves_ads:true,
	add_id_info_limits_tracking:true,
	export_compliance_uses_encryption:false,
	export_compliance_encryption_updated:false})" > Deliverfile
	echo ">> deliver ipa"

	fastlane deliver -u ${apple_id} -a ${app_bundle_id} -i ${ipa_path}${ipa_name}.ipa -z ${app_version_string} --force --skip_screenshots --skip_metadata --support_url "http://cp99884.com/"


	echo ">> restore files"
	echo ">> build finish app:${app_product_name}"
	cp ${info_file}.bp $info_file
#	cp ${constant_file}.bp $constant_file
	cp ${project_file}.bp $project_file
	cp ${appDelegate_file}.bp $appDelegate_file
	rm ${info_file}.bp
#	rm ${constant_file}.bp
	rm ${project_file}.bp
	rm ${appDelegate_file}.bp
	rm Deliverfile
	# git checkout ${YOUR_PROJECT_FOLDER}/Assets.xcassets/AppIcon.appiconset/*
	# git checkout $google_file
}
echo ">> app version string:$app_version_string"
echo ">> app version:$app_version"
for i in $list; do
	build $i
done
# print error message
err=$(<${builderror})
if [[ $err ]]; then
	echo -e "\033[0;31m\c"
	echo "Build Error Message:"
	echo "----------------------------"
	printf "$err\n"
	echo "----------------------------"
	echo -e "\033[0m\c"
fi
rm $builderror
echo -e ">>:\033[0;32;1mAll Build Done\033[0m"
echo "conf list:${list}"
