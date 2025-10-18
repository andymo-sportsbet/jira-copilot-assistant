#!/usr/bin/env python3
"""Test MCP server with a real ticket"""
import asyncio
import json
import os
import sys
from pathlib import Path
from mcp import ClientSession, StdioServerParameters
from mcp.client.stdio import stdio_client


async def test_real_ticket():
    """Test grooming RVV-1171 with auto template"""
    
    repo_root = Path(__file__).resolve().parents[1]
    wrapper_py = str(repo_root / 'mcp-server' / 'jira_bash_wrapper.py')
    python_exec = os.environ.get('MCP_SERVER_PYTHON', sys.executable)

    server_params = StdioServerParameters(
        command=python_exec,
        args=[wrapper_py],
        env=None
    )
    
    print("🔌 Connecting to MCP server...")
    
    async with stdio_client(server_params) as (read, write):
        async with ClientSession(read, write) as session:
            await session.initialize()
            print("✅ Connected!")
            
            # Test auto-template selection for RVV-1171
            print("\n🧪 Testing groom_ticket with RVV-1171 (auto template)...")
            result = await session.call_tool(
                "groom_ticket",
                arguments={
                    "ticket_key": "RVV-1171",
                    "auto_template": True,
                    "dry_run": True  # Don't actually update the ticket
                }
            )
            
            print("\n✅ Result:")
            for content in result.content:
                if hasattr(content, 'text'):
                    response = json.loads(content.text)
                    print(f"  Success: {response.get('success')}")
                    print(f"  Template detected: {response.get('template_info', {}).get('detected_template')}")
                    print(f"  Reason: {response.get('template_info', {}).get('reason')}")
                    if response.get('output'):
                        print(f"\n  Output:\n{response['output'][:300]}...")

if __name__ == "__main__":
    asyncio.run(test_real_ticket())
