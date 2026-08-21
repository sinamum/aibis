![logo](.github/assets/aibis-logo.png)

This project has the purpose to help developers understand root cause of unexpectated behaviours in your kubernetes cluster, sending notification in slack channel. Still work in progress.


```
kubectl -n argocd get secret \                         
  argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" \
  | base64 -d
```

```
Collector = detects

Agent = investigates

Tools = observe

RAG = provides knowledge

LLM = reasons

Report = communicates conclusion
```


MCP is not what makes the system agentic. The agent loop exists independently. MCP standardizes how external tools are discovered and invoked. For the first AIBIS version, I implemented Kubernetes tools directly so I could understand the tool-calling lifecycle. MCP can later become the transport and interoperability layer.