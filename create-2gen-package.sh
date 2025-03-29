#!/bin/sh

packageName=
destinationOrg=
version=
installKey="1234Adm1n!?"
branch=

set -e 

usage()
{
    echo "create-2gen-package [[-pn packageName ] [-d destinationOrg] [-v version] [-b branch]]"
}

while [ "$1" != "" ]; do
    case $1 in
        -pn | --packagename )   shift
                                packageName=$1
                                ;;
        -d | --destination )    shift
                                destinationOrg=$1
                                ;;
        -b | --branch )         shift
                                branch=$1
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

if [ -z  "$packageName" ]; then
	echo "<---> Package name was not provided, aborting <--->"
	exit 1
fi


if [ -z "$destinationOrg" ]; then
    echo "<---> Scratch org alias was not provided, aborting <--->"
    exit 1
fi

if [ -z "$branch" ]; then
    echo "<---> Need to add a branch name to create the package <--->"
    exit 1
fi

echo "<---> Creating package $packageName in scratch org $destinationOrg (version $version) <--->"

# Create the scratch org where installing the package
echo "<---> Creating scratch org <--->"
#sf org create scratch -f config/project-scratch-def.json -d -y 7 -a $destinationOrg -c -w 30

# Create the package
if [ -z "$version" ]; 
then
    echo "<---> Creating the package <--->"
    sf package create --name $packageName --path force-app --package-type Unlocked
fi

# create a version (need to create a version to be able to install the package)
echo "<---> Creating a version <--->"
sf package version create --package $packageName --branch $branch --code-coverage --installation-key $installKey --wait 10

# Install the package
echo "<---> Installing package <--->"
sf package install --package $version --target-org $destinationOrg --installation-key $installKey --wait 10 --publish-wait 10

# Run test units
if ["$version" == ""]; 
then
    echo "<---> Running test units <--->"
    sf apex run test --synchronous
fi
#Create a csv file with data coverage
echo "<---> Get Test Results <--->"
sf data query --query 'SELECT ApexTestClass.Name, TestMethodName, ApexClassOrTrigger.Name, NumLinesUncovered, NumLinesCovered, Coverage FROM ApexCodeCoverage' -u $destinationOrg -t -r csv > testcoverage.csv

#upload the file to salesforce
echo "<---> Upload test results to Salesforce <--->"
sf data create file --file ./testcoverage.csv

#Send file using apex code
echo "<---> Package creation, installation, test running and email sending completed successfully <--->"
sf apex run --file ./sendEmailWithCoverage.apex