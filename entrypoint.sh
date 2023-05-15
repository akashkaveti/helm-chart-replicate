#!/bin/bash
set -e

if [ -z "$GHCR_URL" ]; then
  echo "GHCR url is required but not defined."
  exit 1
fi

if [ -z "$GHCR_ACCESS_TOKEN" ]; then
  echo "Credentials are required, but none defined."
  exit 1
fi

if [ "$GHCR_ACCESS_TOKEN" ]; then
  echo "Access token is defined, using bearer auth."
  GHCR_ACCESS_TOKEN="--access-token ${GHCR_ACCESS_TOKEN}"
fi

if [ "$GHCR_USERNAME" ]; then
  echo "Username is defined, using as parameter."
  GHCR_USERNAME="--username ${GHCR_USERNAME}"
fi

if [ -z "$HELM_CHART_REPO_NAME" ]; then
  echo "Helm chart repo name is required but not defined."
  exit 1
fi

if [ -z "$HELM_CHART_REPO_URL" ]; then
  echo "Helm chart repo URL is required but not defined."
  exit 1
fi

if [ -z "$CHART_VERSION"]; then
  echo "Helm chart version is required but not defined."
  exit 1
fi

helm repo add "${HELM_CHART_REPO_NAME}" "${HELM_CHART_REPO_URL}"
helm pull "${HELM_CHART_REPO_NAME}"/"${HELM_CHART_REPO_NAME}" --version "${CHART_VERSION}"

REGISTRY=$(echo "${GHCR_URL}" | awk -F[/:] '{print $4}') # Get registry host from url
echo "${GHCR_ACCESS_TOKEN}" | helm registry login -u ${GHCR_USERNAME} --password-stdin ${REGISTRY} # Authenticate registry
PKG_NAME=$(ls | grep tgz)
echo "${PKG_NAME}"
echo "Pushing chart ${PKG_NAME} to '${GHCR_URL}'"
helm push "${PKG_NAME}" "${GHCR_URL}"
echo "Successfully pushed chart ${PKG_NAME} to '${GHCR_URL}'"
exit 0