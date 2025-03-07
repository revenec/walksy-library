#!/bin/sh

packageName=
type=
scratchOrgAlias=
originOrg=
version=
installKey="1234Adm1n!?"

set -e 

usage()
{
    echo "usage: create-2gen-package [[[-pn packageName ] [-t packagetype] [-a scratchOrgalias] [-o originOrg] [-v version]]"
}

while [ "$1" != "" ]; do
    case $1 in
        -pn | --packagename )   shift
                                packageName=$1
                                ;;
        -t | --type )           shift
                                type=$1
                                ;;
        -a | --alias )          shift
                                scratchOrgAlias=$1
                                ;;
        -o | --origin )         shift
                                originOrg=$1
                                ;;
        -v | --version )        shift
                                version=$1
                                ;;
        -k | --key )            shift
                                installKey=$1
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

if ["$originOrg" == "" ]; then
	echo "There is not org defined from where to pull the metadata to package, aborting"
	exit 1
fi

if ["$packageName" == "" ]; then
	echo "Package name was not provided, aborting"
	exit 1
fi

if ["$type" == "" ]; then
	echo "Package type name was not provided, aborting"
	exit 1
fi

if [ "$scratchOrgAlias" == "" ]; then
    echo "Scratch org alias was not provided, aborting"
    exit 1
fi

echo "Creating package $packageName of type $type in scratch org $scratchOrgAlias"
# Retrieve all the metadata from the org 
sf project retrieve start --source-dir force-app --target-org $originOrg

# Create the scratch org where installing the package
echo "Creating scratch org"
sf org create scratch --definition-file config/project-scratch-def.json --alias $scratchOrgAlias  --set-default --target-dev-hub miquel@walksy.com

# Create the package
if ["$version" != ""] ; then
    echo "Creating a version"
    sf package version create --package $packageName --code-coverage --installation-key $installKey --wait 10
else
    echo "Creating the package"
    sf package create --name $packageName --path force-app --package-type $type
fi
# Install package in the scratch org and run test units
echo sf package install --package $packageName --target-org $scratchOrgAlias --installation-key $installKey --wait 10 --publish-wait 10 --json

#Create a csv file with data coverage
sf data query --query 'SELECT ApexTestClass.Name, TestMethodName, ApexClassOrTrigger.Name, NumLinesUncovered, NumLinesCovered, Coverage FROM ApexCodeCoverage' -u $scratchOrgAlias -t -r csv > testcoverage.csv

#upload the file to salesforce
sf data create file --file ./testcoverage.csv

#Send file using apex code
sf apex run --file ./sendEmailWithCoverage.apex