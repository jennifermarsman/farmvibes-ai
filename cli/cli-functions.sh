#!/bin/bash
# Copyright (c) Microsoft Corporation.

## do_setup() profile
##
##   Performs the setup of a Farmvibes.ai cluster.
##
do_setup() {
  local profile_name
  for i in "$@"; do :; done
  profile_name="${i}"

  maybe_process_help "$@"

  check_path_sanity "${FARMVIBES_AI_CONFIG_DIR}" "${FARMVIBES_AI_STORAGE_PATH}"
  install_dependencies
  check_internal_commands

  ${MINIKUBE} profile list 2> /dev/null | grep -q "${FARMVIBES_AI_CLUSTER_NAME}" && \
    die "Not overwriting existing cluster ${FARMVIBES_AI_CLUSTER_NAME}." \
      "If you want to recreate it, please destroy it first."

  build_k8s_cluster "${profile_name}"
  update_images
  deploy_services
  wait_for_deployments
  echo -e "\nSuccess!\n"
  show_service_url
  persist_storage_path
}

## do_update_images()
##
##   Updates the images in the farmvibes.ai cluster.
##
do_update_images() {
  maybe_process_help "$@"

  check_internal_commands
  update_images
  restart_services
}

## do_start()
##
##   Starts the farmvibes.ai cluster.
##
do_start() {
  maybe_process_help "$@"

  check_internal_commands
  ${MINIKUBE} profile list 2> /dev/null | grep -q "${FARMVIBES_AI_CLUSTER_NAME}" || \
    die "No farmvibes.ai cluster found"

  is_cluster_running && return 0

  ${MINIKUBE} start --profile="${FARMVIBES_AI_CLUSTER_NAME}" \
    --disable-metrics \
    || die "Failed to start farmvibes.ai cluster"

  restart_services
  for deployment in "${FARMVIBES_AI_DEPLOYMENTS[@]}"
  do
    ${KUBECTL} get pods -l app="${deployment}" | grep -q 1/1 && ${KUBECTL} rollout restart deployment "$deployment"
    ${KUBECTL} rollout status deployment "$deployment"
  done

  show_service_url
}

## do_stop()
##
##   Stops the farmvibes.ai cluster.
##
do_stop() {
  maybe_process_help "$@"

  check_internal_commands
  ${MINIKUBE} profile list 2> /dev/null | grep -q "${FARMVIBES_AI_CLUSTER_NAME}" || \
    die "No farmvibes.ai cluster found"
  ${MINIKUBE} stop --profile="${FARMVIBES_AI_CLUSTER_NAME}" | grep -v minikube || \
    die "Failed to stop farmvibes.ai cluster"
}

## do_restart()
##
##   Restarts the farmvibes.ai cluster.
##
do_restart() {
  maybe_process_help "$@"

  check_internal_commands
  restart_services
  show_service_url
}

## do_status()
##
##   Prints the status of the farmvibes.ai cluster.
##
do_status() {
  maybe_process_help "$@"
  local running_re='[rR]unning'

  check_internal_commands
  status=$(get_cluster_status)
  echo "${status}"
  is_cluster_running && show_service_url
}

## do_destroy()
##
##   Destroys the farmvibes.ai cluster.
##
do_destroy() {
  maybe_process_help "$@"

  do_stop
  docker rm "${FARMVIBES_AI_CLUSTER_NAME}" &> /dev/null
  ${MINIKUBE} delete --profile="${FARMVIBES_AI_CLUSTER_NAME}" | grep -v minikube
  rm -f "${FARMVIBES_AI_CONFIG_DIR}/${FARMVIBES_AI_DATA_FILE_PATH}"
}

## do_add_secret()
##
##   Adds new secret to local secret store.
##
do_add_secret() {
  maybe_process_help "$@"
  local key="${1}"
  local value="${2}"

  if [ "${key}" = "" ]; then
    subcommand_help add-secret
    die "Error, add-secret requires a key"
  fi

  if [ "${value}" = "" ]; then
    subcommand_help add-secret
    die "Error, add-secret requires a secret value"
  fi

  check_internal_commands
  ${MINIKUBE} profile list 2> /dev/null | grep -q "${FARMVIBES_AI_CLUSTER_NAME}" || \
    die "No farmvibes.ai cluster found"
  ${KUBECTL} create secret generic "${key}" --from-literal="${key}=${value}"
}

## do_add_onnx()
##
##   Adds onnx model to cluster.
##
do_add_onnx() {
  maybe_process_help "$@"
  local file="${1}"

  if [ "${file}" = "" ]; then
    subcommand_help add-onnx
    die "Error, add-onnx requires a file"
  fi

  check_internal_commands
  ${MINIKUBE} profile list 2> /dev/null | grep -q "${TERRAVIBES_CLUSTER_NAME}" || \
    die "No terravibes cluster found"

  if [[ ! -d "${FARMVIBES_AI_ONNX_RESOURCES}" ]]; then
    mkdir "${FARMVIBES_AI_ONNX_RESOURCES}"
  fi
  cp ${file} "${FARMVIBES_AI_ONNX_RESOURCES}"
}

## do_delete_secret()
##
##   Remove secret from local secret store.
##
do_delete_secret() {
  maybe_process_help "$@"
  local key="${1}"

  if [ "${key}" = "" ]; then
    subcommand_help delete-secret
    die "Error, delete-secret requires a key"
  fi

  check_internal_commands
  ${MINIKUBE} profile list 2> /dev/null | grep -q "${FARMVIBES_AI_CLUSTER_NAME}" || \
    die "No farmvibes.ai cluster found"
  ${KUBECTL} delete secret "${key}"
}

## route_command()
##
##   Parses the command line options and routes the command to the appropriate
##   function.
##
route_command() {
  subcommand="$1"
  shift
  case $subcommand in
    setup)
      (do_setup "$@") || do_destroy
    ;;
    update-images)
      do_update_images "$@"
    ;;
    start)
      do_start "$@"
    ;;
    stop)
      do_stop "$@"
    ;;
    restart)
      do_restart "$@"
    ;;
    status)
      do_status "$@"
    ;;
    destroy)
      do_destroy "$@"
    ;;
    add-secret)
      do_add_secret "$@"
    ;;
    delete-secret)
      do_delete_secret "$@"
    ;;
    add-onnx)
      do_add_onnx "$@"
    ;;
    *)
      echo "Unsupported command $subcommand."
      usage
      exit 1
  esac
}
