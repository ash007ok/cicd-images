#!/bin/sh
REPOSITORY_URL=$1;

TAG="${REPOSITORY_URL}-next";
TAG_LATEST="${REPOSITORY_URL}-latest";

VERSIONS=$(docker run ${TAG});
VERSION_GIT=$(printf "${VERSIONS}" | grep git | cut -f 2 -d ':');
VERSION_DOCKER=$(printf "${VERSIONS}" | grep 'docker:' | cut -f 2 -d ':');
VERSION_DOCKER_COMPOSE=$(printf "${VERSIONS}" | grep docker-compose | cut -f 2 -d ':');
VERSION_OPENSSH=$(printf "${VERSIONS}" | grep openssh | cut -f 2 -d ':');
EXISTENCE_TAG="docker-${VERSION_DOCKER}_docker-compose-${VERSION_DOCKER_COMPOSE}_git-${VERSION_GIT}_openssh-${VERSION_OPENSSH}";
EXISTENCE_REPO_URL="${REPOSITORY_URL}-${EXISTENCE_TAG}";
DOCKER_VERSION_REPO_URL="${REPOSITORY_URL}-${VERSION_DOCKER}";

printf "Checking existence of [${EXISTENCE_REPO_URL}]...";
$(docker pull ${EXISTENCE_REPO_URL}) && EXISTS=$?;
if [ "${EXISTS}" = "0" ]; then
  printf "[${EXISTENCE_REPO_URL}] found. Skipping push.\n";
  echo exists;
else
  printf "[${EXISTENCE_REPO_URL}] not found. Pushing new image...\n";
  printf "Pushing [${TAG_LATEST}]... ";
  docker tag ${TAG} ${TAG_LATEST};
  docker push ${TAG_LATEST};
  printf "Pushing [${EXISTENCE_REPO_URL}]... ";
  docker tag ${TAG} ${EXISTENCE_REPO_URL};
  docker push ${EXISTENCE_REPO_URL};
  printf "Pushing [${DOCKER_VERSION_REPO_URL}]... ";
  docker tag ${TAG} ${DOCKER_VERSION_REPO_URL};
  docker push ${DOCKER_VERSION_REPO_URL};
fi;