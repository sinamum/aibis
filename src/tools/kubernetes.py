from __future__ import annotations

from kubernetes import client, config
from kubernetes.config.config_exception import ConfigException
from kubernetes.client.exceptions import ApiException
from langchain_core.tools import tool


def load_kubernetes_config() -> None:
    try:
        config.load_incluster_config()
    except ConfigException:
        config.load_kube_config()


load_kubernetes_config()

core_api = client.CoreV1Api()
apps_api = client.AppsV1Api()

@tool
def get_pod(namespace: str, name: str) -> dict:
    """Get the current state of a Kubernetes Pod."""

    try:
        pod = core_api.read_namespaced_pod(
            namespace=namespace,
            name=name,
        )
    except ApiException as exc:
        if exc.status == 404:
            return {
                "error": "pod_not_found",
                "namespace": namespace,
                "name": name,
                "message": (
                    "The Pod does not exist. "
                    "Use list_pods to discover the current Pod name."
                ),
            }

        return {
            "error": "kubernetes_api_error",
            "status": exc.status,
            "reason": exc.reason,
        }

    containers = []

    for status in pod.status.container_statuses or []:
        containers.append(
            {
                "name": status.name,
                "ready": status.ready,
                "restart_count": status.restart_count,
                "state": _container_state(status),
            }
        )

    return {
        "name": pod.metadata.name,
        "namespace": pod.metadata.namespace,
        "phase": pod.status.phase,
        "pod_ip": pod.status.pod_ip,
        "node": pod.spec.node_name,
        "containers": containers,
    }


def _container_state(status) -> dict:
    state = status.state

    if state.running:
        return {
            "status": "running",
            "started_at": str(state.running.started_at),
        }

    if state.waiting:
        return {
            "status": "waiting",
            "reason": state.waiting.reason,
            "message": state.waiting.message,
        }

    if state.terminated:
        return {
            "status": "terminated",
            "reason": state.terminated.reason,
            "exit_code": state.terminated.exit_code,
            "finished_at": str(state.terminated.finished_at),
        }

    return {"status": "unknown"}

@tool
def get_pod_logs(
    namespace: str,
    name: str,
    container: str | None = None,
    previous: bool = False,
    tail_lines: int = 100,
) -> str:
    """Get recent logs from a Kubernetes Pod."""

    return core_api.read_namespaced_pod_log(
        namespace=namespace,
        name=name,
        container=container,
        previous=previous,
        tail_lines=tail_lines,
        timestamps=True,
    )

@tool
def get_namespace_events(
    namespace: str,
    involved_object_name: str | None = None,
) -> list[dict]:
    """Get recent Kubernetes events from a namespace."""

    field_selector = None

    if involved_object_name:
        field_selector = (
            f"involvedObject.name={involved_object_name}"
        )

    response = core_api.list_namespaced_event(
        namespace=namespace,
        field_selector=field_selector,
    )

    return [
        {
            "type": event.type,
            "reason": event.reason,
            "message": event.message,
            "object": event.involved_object.name,
            "kind": event.involved_object.kind,
            "count": event.count,
            "last_seen": str(
                event.last_timestamp
                or event.event_time
                or event.metadata.creation_timestamp
            ),
        }
        for event in response.items
    ]

@tool
def list_pods(
    namespace: str,
    label_selector: str | None = None,
) -> list[dict]:
    """List Pods in a Kubernetes namespace.

    Optionally filter the Pods using a Kubernetes label selector.
    """

    response = core_api.list_namespaced_pod(
        namespace=namespace,
        label_selector=label_selector,
    )

    return [
        {
            "name": pod.metadata.name,
            "namespace": pod.metadata.namespace,
            "phase": pod.status.phase,
            "pod_ip": pod.status.pod_ip,
            "node": pod.spec.node_name,
            "labels": pod.metadata.labels,
            "restart_count": sum(
                status.restart_count
                for status in (pod.status.container_statuses or [])
            ),
        }
        for pod in response.items
    ]