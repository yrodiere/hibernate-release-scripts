#!/usr/bin/env bash

SCRIPTS_DIR="$(readlink -f ${BASH_SOURCE[0]} | xargs dirname)"

PROJECT=$1
NEW_VERSION=$2
# If set, Project version is inherited from parent (maven requires a different command)
VERSION_INHERITED=$3
WORKSPACE=${WORKSPACE:-'.'}

if [ -z "$PROJECT" ]; then
	echo "ERROR: Project not supplied"
	exit 1
fi
if [ -z "$NEW_VERSION" ]; then
	echo "ERROR: New version argument not supplied"
	exit 1
else
	echo "Setting version to '$NEW_VERSION'";
fi

pushd $WORKSPACE

source "$SCRIPTS_DIR/mvn-setup.sh"

if [ -f bom/pom.xml ]; then
	./mvnw -Prelocation clean versions:set -DnewVersion=$NEW_VERSION -DgenerateBackupPoms=false -f bom/pom.xml
elif [ -z "$VERSION_INHERITED" ]; then
	./mvnw -Prelocation clean versions:set -DnewVersion=$NEW_VERSION -DgenerateBackupPoms=false
else
    # Version inherited from parent
    ./mvnw -Prelocation versions:update-parent -DparentVersion="[1.0, $NEW_VERSION]" -DgenerateBackupPoms=false -DallowSnapshots=true
    ./mvnw -Prelocation -N versions:update-child-modules -DgenerateBackupPoms=false
fi

popd
