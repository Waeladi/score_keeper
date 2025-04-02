# Cursor MCP Server

A custom Model Control Protocol (MCP) server for Cursor IDE. This repository allows you to configure and use custom AI models with Cursor across all your GitHub repositories.

## What is MCP?

Model Control Protocol (MCP) is how Cursor interfaces with AI models. This custom MCP server allows you to:

1. Use custom AI models with Cursor
2. Control model parameters and settings
3. Apply the same configuration across all your repositories
4. Secure your AI interactions through GitHub authentication

## Setup Instructions

### 1. Server Setup

1. Clone this repository to your local machine:
   ```bash
   git clone https://github.com/Waeladi/cursor-mcp-server.git
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Configure your environment variables by creating a `.env` file:
   ```
   PORT=3000
   GITHUB_CLIENT_ID=your_github_client_id
   GITHUB_CLIENT_SECRET=your_github_client_secret
   ```

4. Start the server (for testing locally):
   ```bash
   npm start
   ```

### 2. GitHub Integration

1. Create a GitHub OAuth App:
   - Go to GitHub Settings > Developer Settings > OAuth Apps
   - Create a new OAuth App with:
     - Application name: Cursor MCP
     - Homepage URL: https://cursor.sh
     - Authorization callback URL: http://localhost:3000/auth/github/callback

2. Deploy the server (options):
   - GitHub Pages
   - Vercel
   - Netlify
   - Your own server

### 3. Cursor Configuration

1. In Cursor, open Settings (Cmd/Ctrl + ,)
2. Add custom MCP configuration to settings.json:
   ```json
   {
     "ai.customEndpoint": "https://github.com/Waeladi/cursor-mcp-server/mcp-server",
     "ai.provider": "custom",
     "ai.customHeaders": {
       "Authorization": "Bearer ${process.env.GITHUB_TOKEN}"
     }
   }
   ```

3. In your repository, add a `.cursor/mcp.json` file:
   ```json
   {
     "mcpServers": [
       {
         "name": "Waeladi MCP",
         "url": "https://github.com/Waeladi/cursor-mcp-server",
         "authType": "github"
       }
     ]
   }
   ```

## Available Models

This MCP server configuration includes:

| Model ID | Provider | Context Length | Description |
|----------|----------|---------------|------------|
| claude-3-opus | Anthropic | 100,000 | Claude 3 Opus - high performance model |
| claude-3-sonnet | Anthropic | 80,000 | Claude 3 Sonnet - balanced model |
| gpt-4o | OpenAI | 128,000 | GPT-4o - OpenAI's most capable model |

## Usage in Projects

To use this MCP server in any of your repositories:

1. Add a `.cursor/mcp.json` file to the repository
2. Cursor will automatically use your MCP configuration

## Advanced Configuration

For advanced use cases, you can:

1. Add model-specific settings to `mcp-server/models/` directory
2. Customize authentication in `server.js`
3. Add repository-specific configurations

## License

MIT


