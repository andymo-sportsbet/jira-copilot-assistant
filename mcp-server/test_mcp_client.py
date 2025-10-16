#!/usr/bin/env python3
"""Test client for MCP server"""
import asyncio
import json
from mcp import ClientSession, StdioServerParameters
from mcp.client.stdio import stdio_client

async def test_mcp_server():
    """Test the MCP server by connecting and calling tools"""
    
    server_params = StdioServerParameters(
        command="/Users/andym/projects/my-project/jira-copilot-assistant/mcp-server/venv/bin/python",
        args=["/Users/andym/projects/my-project/jira-copilot-assistant/mcp-server/jira_bash_wrapper.py"],
        env=None
    )
    
    print("🔌 Connecting to MCP server...")
    
    async with stdio_client(server_params) as (read, write):
        async with ClientSession(read, write) as session:
            # Initialize
            await session.initialize()
            print("✅ Connected and initialized!")
            
            # List available tools
            print("\n📋 Listing available tools...")
            tools = await session.list_tools()
            print(f"✅ Found {len(tools.tools)} tools:")
            for tool in tools.tools:
                print(f"  - {tool.name}: {tool.description[:60]}...")
            
            # List available resources (prompt templates)
            print("\n📄 Listing available resources...")
            resources = await session.list_resources()
            print(f"✅ Found {len(resources.resources)} resources:")
            for resource in resources.resources:
                print(f"  - {resource.uri}")
            
            # Test tool: get help for a script
            print("\n🧪 Testing tool: groom_ticket with help...")
            result = await session.call_tool(
                "groom_ticket",
                arguments={"ticket_key": "HELP"}
            )
            print("✅ Tool response:")
            for content in result.content:
                if hasattr(content, 'text'):
                    print(content.text[:200] + "..." if len(content.text) > 200 else content.text)
            
            print("\n✅ MCP Server is working correctly!")

if __name__ == "__main__":
    asyncio.run(test_mcp_server())
