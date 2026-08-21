import asyncio

from src.agents.incident_investigator import build_investigator


async def main():
    agent = build_investigator()

    result = await agent.ainvoke(
        {
            "messages": [
                {
                    "role": "user",
                    "content": """
Investigate the pods in the favorite-go-main namespace.

Check their current health and look for evidence
of operational problems.
""",
                }
            ]
        }
    )

    print(result["messages"][-1].content)


if __name__ == "__main__":
    asyncio.run(main())