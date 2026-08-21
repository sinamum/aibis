from langchain.agents import create_agent
from langchain_openai import ChatOpenAI

from src.config import get_openai_api_key

from src.tools.kubernetes import (
    get_namespace_events,
    get_pod,
    get_pod_logs,
    list_pods,
)


SYSTEM_PROMPT = """
You are AIBIS, an AI-Based Incident System specialized in Kubernetes environments.

Your job is to investigate operational incidents using
the available read-only tools.

Rules:

- Never modify Kubernetes resources.
- Gather evidence before drawing conclusions.
- Do not call the same tool with identical arguments twice.
- Clearly separate facts from hypotheses.
- If evidence is insufficient, say so.
- Prefer the smallest number of tool calls needed to reach
  a supported conclusion.

Return:

1. Summary
2. Evidence
3. Probable root cause
4. Recommended actions
"""


def build_investigator():
    model = ChatOpenAI(
        model="gpt-5-mini",
        openai_api_key=get_openai_api_key()
    )

    return create_agent(
        model=model,
        tools=[
            get_pod,
            get_pod_logs,
            get_namespace_events,
            list_pods,
        ],
        system_prompt=SYSTEM_PROMPT,
    )