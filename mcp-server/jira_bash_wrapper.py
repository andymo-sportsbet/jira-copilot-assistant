#!/usr/bin/env python3
"""
@jira groom RVV-1171 with auto templateJIRA MCP Server - Bash Wrapper Implementation

A thin wrapper around the production-tested bash scripts in ../scripts/
Exposes all JIRA functionality through MCP (Model Context Protocol).
"""

import asyncio
import json
import os
import re
import subprocess
from pathlib import Path
from typing import Any, Dict, Optional, List

from dotenv import load_dotenv
from mcp.server import Server, NotificationOptions, InitializationOptions
from mcp.server.stdio import stdio_server
from mcp import types


class JiraBashWrapper:
    """Wrapper for jira-copilot-assistant bash scripts"""
    
    def __init__(self):
        # Find script directory
        self.mcp_dir = os.path.dirname(os.path.abspath(__file__))
        self.project_dir = os.path.dirname(self.mcp_dir)
        self.scripts_dir = os.path.join(self.project_dir, 'scripts')
        
        # Verify scripts exist
        if not os.path.exists(self.scripts_dir):
            raise ValueError(f"Scripts directory not found: {self.scripts_dir}")
        
        # Prompts directory for type-specific templates
        self.prompts_dir = os.path.join(self.project_dir, '.prompts')
        
        self.server = Server("jira-mcp-server")
        self._setup_handlers()
    
    def _suggest_template_smart(self, summary: str, description: str = "") -> str:
        """
        Smart template suggestion based on ticket content
        Matches logic from get-description-template.sh
        
        Args:
            summary: Ticket summary
            description: Ticket description
            
        Returns:
            Template type: 'story', 'bug', 'spike', or 'tech-debt'
        """
        text = f"{summary} {description}".lower()
        
        # Tech debt indicators (check first - upgrade/migration are very specific)
        if re.search(r'(upgrade|migration|migrate|modernize|spring boot [0-9]|java [0-9]+|update.*version|dependency.*update)', text):
            return 'tech-debt'
        
        # Spike/Research indicators (check before bug - "investigate issue" might contain "issue")
        if re.search(r'(spike|research|investigate|exploration|evaluate|assess|poc|proof of concept|feasibility|study|compare|analysis)', text):
            return 'spike'
        
        # Bug indicators (be specific - avoid false positives)
        if re.search(r'(\bbug\b|defect|broken|\berror\b|\bfail|not working|\bcrash|exception|incorrect|\bfix\b.*\bissue)', text):
            return 'bug'
        
        # Story/Feature indicators
        if re.search(r'(\bfeature\b|enhancement|user story|capability|enable|allow|add support|new functionality|implement.*feature)', text):
            return 'story'
        
        # Tech debt indicators (broader - refactor, improve, etc.)
        if re.search(r'(refactor|technical debt|\bimprove|optimization|\bupdate\b|\bcleanup\b|\bdebt\b)', text):
            return 'tech-debt'
        
        # Default to tech-debt for generic tasks
        return 'tech-debt'
    
    def _get_prompt_template(self, ticket_key: str, issue_type: Optional[str] = None) -> Optional[str]:
        """
        Get the appropriate prompt template for a ticket
        
        Args:
            ticket_key: JIRA ticket key
            issue_type: Optional issue type override
            
        Returns:
            Path to prompt template file, or None if unable to determine
        """
        # Fetch ticket data if issue type not provided
        if not issue_type:
            result = self._run_script('get-description-template.sh', [ticket_key, '--print'])
            if result['success'] and result['output']:
                return result['output'].strip()
            return None
        
        # Map issue type to template
        issue_type_lower = issue_type.lower()
        
        template_map = {
            'story': 'generate-description-story.md',
            'new feature': 'generate-description-story.md',
            'feature': 'generate-description-story.md',
            'bug': 'generate-description-bug.md',
            'defect': 'generate-description-bug.md',
            'spike': 'generate-description-spike.md',
            'research': 'generate-description-spike.md',
            'investigation': 'generate-description-spike.md',
            'technical debt': 'generate-description-tech-debt.md',
            'improvement': 'generate-description-tech-debt.md',
            'tech debt': 'generate-description-tech-debt.md',
            'tech-debt': 'generate-description-tech-debt.md',
            'refactor': 'generate-description-tech-debt.md',
        }
        
        template_file = template_map.get(issue_type_lower, 'generate-description-default.md')
        return os.path.join(self.prompts_dir, template_file)
    
    def _run_script(self, script_name: str, args: List[str] = None, input_data: str = None) -> Dict:
        """
        Run a bash script and return result
        
        Args:
            script_name: Name of script (e.g., 'jira-groom.sh')
            args: List of command line arguments
            input_data: Optional stdin input
            
        Returns:
            Dict with success, output, error
        """
        script_path = os.path.join(self.scripts_dir, script_name)
        
        if not os.path.exists(script_path):
            return {
                "success": False,
                "error": f"Script not found: {script_name}"
            }
        
        # Build command
        cmd = [script_path] + (args or [])
        
        try:
            result = subprocess.run(
                cmd,
                cwd=self.project_dir,
                capture_output=True,
                text=True,
                input=input_data,
                timeout=60
            )
            
            return {
                "success": result.returncode == 0,
                "output": result.stdout,
                "error": result.stderr if result.returncode != 0 else None,
                "exit_code": result.returncode
            }
        
        except subprocess.TimeoutExpired:
            return {
                "success": False,
                "error": "Script execution timed out (60s)"
            }
        except Exception as e:
            return {
                "success": False,
                "error": f"Script execution failed: {str(e)}"
            }
    
    def _setup_handlers(self):
        """Setup MCP request handlers"""
        
        @self.server.list_tools()
        async def handle_list_tools() -> list[types.Tool]:
            """List available Jira tools"""
            return [
                types.Tool(
                    name="groom_ticket",
                    description="Groom a Jira ticket with AI-generated acceptance criteria and enhancements",
                    inputSchema={
                        "type": "object",
                        "properties": {
                            "ticket_key": {
                                "type": "string",
                                "description": "Jira ticket key (e.g., 'RVV-1234')",
                            },
                            "reference_file": {
                                "type": "string",
                                "description": "Path to spec file with technical details",
                            },
                            "confluence_url": {
                                "type": "string",
                                "description": "Confluence page URL to fetch and use as reference",
                            },
                            "ai_guide": {
                                "type": "string",
                                "description": "Path to AI-generated technical guide (JIRA ADF JSON format)",
                            },
                            "ai_description": {
                                "type": "string",
                                "description": "Path to AI-generated enhanced description (plain text)",
                            },
                            "auto_template": {
                                "type": "boolean",
                                "description": "Auto-select appropriate prompt template based on ticket type (story, bug, spike, tech-debt)",
                                "default": False
                            },
                            "estimate": {
                                "type": "boolean",
                                "description": "Enable AI-powered story point estimation",
                                "default": False
                            },
                            "auto_estimate": {
                                "type": "boolean",
                                "description": "Auto-accept AI estimation without confirmation",
                                "default": False
                            },
                            "team_scale": {
                                "type": "boolean",
                                "description": "Use team scale (0.5-5) instead of Fibonacci",
                                "default": True
                            },
                            "story_points": {
                                "type": "number",
                                "description": "Manually set story points (0.5, 1, 2, 3, 4, 5, 8, 13)",
                            }
                        },
                        "required": ["ticket_key"]
                    }
                ),
                types.Tool(
                    name="create_ticket",
                    description="Create a new Jira ticket",
                    inputSchema={
                        "type": "object",
                        "properties": {
                            "summary": {
                                "type": "string",
                                "description": "Ticket summary/title",
                            },
                            "description": {
                                "type": "string",
                                "description": "Ticket description (markdown supported)",
                            },
                            "features": {
                                "type": "string",
                                "description": "Comma-separated list of features/requirements",
                            },
                            "priority": {
                                "type": "string",
                                "description": "Priority: High, Medium, Low (default: Medium)",
                                "default": "Medium"
                            },
                            "issue_type": {
                                "type": "string",
                                "description": "Issue type: Story, Task, Bug, Epic",
                                "default": "Task"
                            },
                            "epic": {
                                "type": "string",
                                "description": "Epic ticket key to link to",
                            }
                        },
                        "required": ["summary"]
                    }
                ),
                types.Tool(
                    name="fetch_confluence_page",
                    description="Fetch Confluence page and convert to spec file",
                    inputSchema={
                        "type": "object",
                        "properties": {
                            "page_url": {
                                "type": "string",
                                "description": "Confluence page URL",
                            },
                            "page_id": {
                                "type": "string",
                                "description": "Confluence page ID (alternative to page_url)",
                            },
                            "output_file": {
                                "type": "string",
                                "description": "Path to save spec file (optional)",
                            }
                        }
                    }
                ),
                types.Tool(
                    name="find_related_tickets",
                    description="Find tickets related to a specific ticket",
                    inputSchema={
                        "type": "object",
                        "properties": {
                            "ticket_key": {
                                "type": "string",
                                "description": "Jira ticket key (e.g., 'RVV-1234')",
                            }
                        },
                        "required": ["ticket_key"]
                    }
                ),
                types.Tool(
                    name="close_ticket",
                    description="Close a Jira ticket with optional comment",
                    inputSchema={
                        "type": "object",
                        "properties": {
                            "ticket_key": {
                                "type": "string",
                                "description": "Jira ticket key (e.g., 'RVV-1234')",
                            },
                            "comment": {
                                "type": "string",
                                "description": "Optional comment when closing",
                            }
                        },
                        "required": ["ticket_key"]
                    }
                ),
                types.Tool(
                    name="sync_to_confluence",
                    description="Sync Jira ticket to Confluence page",
                    inputSchema={
                        "type": "object",
                        "properties": {
                            "ticket_key": {
                                "type": "string",
                                "description": "Jira ticket key (e.g., 'RVV-1234')",
                            },
                            "page_id": {
                                "type": "string",
                                "description": "Confluence page ID",
                            }
                        },
                        "required": ["ticket_key", "page_id"]
                    }
                ),
            ]
        
        @self.server.list_resources()
        async def handle_list_resources() -> list[types.Resource]:
            """List available prompt templates as resources"""
            resources = []
            
            if os.path.exists(self.prompts_dir):
                for filename in os.listdir(self.prompts_dir):
                    if filename.endswith('.md') and filename.startswith('generate-'):
                        uri = f"prompt://{filename}"
                        name = filename.replace('generate-description-', '').replace('.md', '').replace('-', ' ').title()
                        resources.append(types.Resource(
                            uri=uri,
                            name=f"Prompt Template: {name}",
                            description=f"AI prompt template for {name} ticket descriptions",
                            mimeType="text/markdown"
                        ))
            
            return resources
        
        @self.server.read_resource()
        async def handle_read_resource(uri: str) -> str:
            """Read a prompt template resource"""
            uri_str = str(uri)
            if not uri_str.startswith("prompt://"):
                raise ValueError(f"Unknown resource URI: {uri_str}")
            
            filename = uri_str.replace("prompt://", "")
            filepath = os.path.join(self.prompts_dir, filename)
            
            if not os.path.exists(filepath):
                raise ValueError(f"Prompt template not found: {filename}")
            
            with open(filepath, 'r') as f:
                return f.read()
        
        @self.server.call_tool()
        async def handle_call_tool(
            name: str, arguments: dict[str, Any]
        ) -> list[types.TextContent]:
            """Handle tool calls"""
            
            try:
                if name == "groom_ticket":
                    result = self.groom_ticket(**arguments)
                elif name == "create_ticket":
                    result = self.create_ticket(**arguments)
                elif name == "fetch_confluence_page":
                    result = self.fetch_confluence_page(**arguments)
                elif name == "find_related_tickets":
                    result = self.find_related_tickets(**arguments)
                elif name == "close_ticket":
                    result = self.close_ticket(**arguments)
                elif name == "sync_to_confluence":
                    result = self.sync_to_confluence(**arguments)
                else:
                    raise ValueError(f"Unknown tool: {name}")
                
                return [types.TextContent(type="text", text=json.dumps(result, indent=2))]
            
            except Exception as e:
                return [types.TextContent(type="text", text=json.dumps({
                    "success": False,
                    "error": str(e)
                }, indent=2))]
    
    def groom_ticket(self, ticket_key: str, reference_file: str = None, 
                    confluence_url: str = None, ai_guide: str = None,
                    ai_description: str = None, auto_template: bool = False,
                    estimate: bool = False, auto_estimate: bool = False, 
                    team_scale: bool = True, story_points: float = None) -> Dict:
        """
        Groom a Jira ticket using jira-groom.sh
        
        Handles:
        - Reference files (--reference-file)
        - Confluence integration (fetches page first)
        - AI guide (--ai-guide)
        - AI description (--ai-description)
        - Auto template selection (auto_template=True)
        - AI estimation (--estimate, --auto-estimate, --team-scale)
        - Manual story points (--points)
        """
        args = [ticket_key]
        
        # Auto-select template if requested
        template_info = None
        if auto_template:
            template_path = self._get_prompt_template(ticket_key)
            if template_path:
                template_info = {
                    "template_path": template_path,
                    "template_name": os.path.basename(template_path).replace('generate-description-', '').replace('.md', '')
                }
        
        # Handle Confluence URL - fetch first, then use as reference
        if confluence_url:
            # Fetch Confluence page to temp file
            import tempfile
            temp_file = tempfile.mktemp(suffix='.md', prefix='confluence_')
            
            fetch_result = self.fetch_confluence_page(confluence_url, temp_file)
            if not fetch_result['success']:
                return fetch_result
            
            reference_file = temp_file
        
        # Add reference file
        if reference_file:
            args.extend(['--reference-file', reference_file])
        
        # Add AI guide (JIRA ADF JSON format)
        if ai_guide:
            args.extend(['--ai-guide', ai_guide])
        
        # Add AI description (plain text)
        if ai_description:
            args.extend(['--ai-description', ai_description])
        
        # Add estimation options
        if story_points is not None:
            args.extend(['--points', str(story_points)])
        elif estimate:
            args.append('--estimate')
            if auto_estimate:
                args.append('--auto-estimate')
            if team_scale:
                args.append('--team-scale')
        
        # Run script
        result = self._run_script('jira-groom.sh', args)
        
        if result['success']:
            response = {
                "success": True,
                "ticket_key": ticket_key,
                "message": f"Successfully groomed {ticket_key}",
                "output": result['output']
            }
            
            # Add template info if auto-selected
            if template_info:
                response["template"] = template_info
                response["message"] += f" (using {template_info['template_name']} template)"
            
            return response
        else:
            return result
    
    def create_ticket(self, summary: str, description: str = None,
                     features: str = None, priority: str = "Medium",
                     issue_type: str = "Task", epic: str = None) -> Dict:
        """
        Create a new Jira ticket using jira-create.sh
        """
        args = ['--summary', summary]
        
        if description:
            args.extend(['--description', description])
        
        if features:
            args.extend(['--features', features])
        
        if priority:
            args.extend(['--priority', priority])
        
        if epic:
            args.extend(['--epic', epic])
        
        # Run script
        result = self._run_script('jira-create.sh', args)
        
        if result['success']:
            # Extract ticket key from output
            output = result['output']
            ticket_key = None
            for line in output.split('\n'):
                if 'Created ticket:' in line or 'RVV-' in line:
                    # Extract ticket key
                    import re
                    match = re.search(r'(RVV-\d+)', line)
                    if match:
                        ticket_key = match.group(1)
                        break
            
            return {
                "success": True,
                "ticket_key": ticket_key,
                "message": f"Created {ticket_key}: {summary}",
                "output": result['output']
            }
        else:
            return result
    
    def fetch_confluence_page(self, page_url: str = None, page_id: str = None, output_file: str = None) -> Dict:
        """
        Fetch Confluence page using confluence-to-spec.sh
        """
        args = []
        
        if page_url:
            args.extend(['--url', page_url])
        elif page_id:
            args.extend(['--page-id', page_id])
        else:
            return {
                "success": False,
                "error": "Either page_url or page_id is required"
            }
        
        if output_file:
            args.extend(['--output', output_file])
        
        result = self._run_script('confluence-to-spec.sh', args)
        
        if result['success']:
            return {
                "success": True,
                "page_url": page_url,
                "page_id": page_id,
                "output_file": output_file,
                "message": f"Fetched Confluence page" + (f" to {output_file}" if output_file else ""),
                "output": result['output']
            }
        else:
            return result
    
    def find_related_tickets(self, ticket_key: str) -> Dict:
        """
        Find related tickets using find-related-tickets.sh
        """
        result = self._run_script('find-related-tickets.sh', [ticket_key])
        
        if result['success']:
            return {
                "success": True,
                "ticket_key": ticket_key,
                "output": result['output']
            }
        else:
            return result
    
    def close_ticket(self, ticket_key: str, comment: str = None) -> Dict:
        """
        Close a ticket using jira-close.sh
        """
        args = [ticket_key]
        
        if comment:
            args.extend(['--comment', comment])
        
        result = self._run_script('jira-close.sh', args)
        
        if result['success']:
            return {
                "success": True,
                "ticket_key": ticket_key,
                "message": f"Closed {ticket_key}",
                "output": result['output']
            }
        else:
            return result
    
    def sync_to_confluence(self, ticket_key: str, page_id: str) -> Dict:
        """
        Sync ticket to Confluence using confluence-to-jira.sh
        """
        result = self._run_script('confluence-to-jira.sh', [ticket_key, page_id])
        
        if result['success']:
            return {
                "success": True,
                "ticket_key": ticket_key,
                "page_id": page_id,
                "message": f"Synced {ticket_key} to Confluence page {page_id}",
                "output": result['output']
            }
        else:
            return result
    
    async def run(self):
        """Run the MCP server"""
        async with stdio_server() as (read_stream, write_stream):
            await self.server.run(
                read_stream,
                write_stream,
                InitializationOptions(
                    server_name="jira-bash-wrapper",
                    server_version="2.0.0",
                    capabilities=self.server.get_capabilities(
                        notification_options=NotificationOptions(),
                        experimental_capabilities={},
                    )
                )
            )


async def main():
    """Main entry point"""
    wrapper = JiraBashWrapper()
    await wrapper.run()


if __name__ == "__main__":
    asyncio.run(main())
