import { readFile } from 'fs/promises';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

export interface Rule {
  category: string;
  topic: string;
  title: string;
  description: string;
  priority: number;
  content: string;
}

export class ApiClient {
  private rulesPath: string;

  constructor(baseUrl?: string) {
    // Default to local rules directory (../../rules from this file)
    this.rulesPath = baseUrl || join(__dirname, '../../../rules');
  }

  private log(message: string) {
    const timestamp = new Date().toISOString();
    console.error(`${timestamp} [API Client] ${message}`);
  }

  /**
   * Fetch the main workflow guide (050-workflow.mdc)
   */
  async fetchMainGuide(): Promise<Rule> {
    this.log('Fetching main workflow guide...');
    const filePath = join(this.rulesPath, '050-workflow.mdc');
    const content = await readFile(filePath, 'utf-8');

    return {
      category: 'core',
      topic: 'workflow',
      title: 'Development Workflow - Plan/Implement/Review',
      description: 'Core workflow philosophy with Golden Rules for AI agents',
      priority: 50,
      content: content,
    };
  }

  /**
   * Fetch a specific rule by category and topic
   */
  async fetchRule(category: string, topic: string): Promise<Rule> {
    this.log(`Fetching rule: category="${category}", topic="${topic}"`);

    // Map category/topic to file names
    const fileMap: Record<string, Record<string, string>> = {
      core: {
        workflow: '050-workflow.mdc',
        'core-principles': '100-core.mdc',
        git: '110-git.mdc',
        utilities: '115-utilities.mdc',
      },
      languages: {
        python: '160-python.mdc',
        go: '180-go.mdc',
        rust: '185-rust.mdc',
        typescript: '165-typescript.mdc',
        javascript: '170-javascript.mdc',
        bash: '130-bash.mdc',
      },
      infrastructure: {
        terraform: '140-terraform.mdc',
        cloudformation: '150-cloudformation.mdc',
        docker: '155-docker.mdc',
        kubernetes: '260-kubernetes.mdc',
        ansible: '145-ansible.mdc',
        helm: '195-helm.mdc',
      },
      cloud: {
        aws: '280-aws.mdc',
        azure: '285-azure.mdc',
        gcp: '290-gcp.mdc',
        cloudflare: '250-cloudflare.mdc',
      },
      devops: {
        'github-actions': '120-gha.mdc',
        makefile: '190-makefile.mdc',
        cli: '200-cli.mdc',
      },
      patterns: {
        documentation: '220-documentation.mdc',
        'mcp-servers': '230-mcp-servers.mdc',
        configuration: '240-configuration.mdc',
        'open-source': '210-open-source.mdc',
        testing: '300-testing.mdc',
        security: '310-security.mdc',
        'api-design': '320-api-design.mdc',
        observability: '330-observability.mdc',
      },
      databases: {
        postgresql: '270-postgresql.mdc',
      },
      other: {
        'ai-ml': '295-ai-ml.mdc',
        markdown: '800-markdown.mdc',
      },
    };

    const fileName = fileMap[category]?.[topic];
    if (!fileName) {
      throw new Error(`Unknown rule: ${category}/${topic}`);
    }

    const filePath = join(this.rulesPath, fileName);
    const content = await readFile(filePath, 'utf-8');

    // Extract metadata from frontmatter if present
    const frontmatterMatch = content.match(/^---\n([\s\S]+?)\n---\n/);
    let title = `${category}: ${topic}`;
    let description = '';
    let priority = 0;

    if (frontmatterMatch) {
      const frontmatter = frontmatterMatch[1];
      const titleMatch = frontmatter.match(/title:\s*(.+)/);
      const descMatch = frontmatter.match(/description:\s*(.+)/);
      const priorityMatch = frontmatter.match(/priority:\s*(\d+)/);

      if (titleMatch) title = titleMatch[1];
      if (descMatch) description = descMatch[1];
      if (priorityMatch) priority = parseInt(priorityMatch[1], 10);
    }

    return {
      category,
      topic,
      title,
      description,
      priority,
      content,
    };
  }

  /**
   * List all available rules
   */
  async listAvailableRules(): Promise<Rule[]> {
    this.log('Listing all available rules...');

    const rules: Rule[] = [
      // Core
      { category: 'core', topic: 'workflow', title: 'Development Workflow', description: 'Plan/Implement/Review approach with Golden Rules', priority: 50, content: '' },
      { category: 'core', topic: 'core-principles', title: 'Core Principles', description: 'SOLID, DRY, KISS, YAGNI, Fail Fast', priority: 100, content: '' },
      { category: 'core', topic: 'git', title: 'Git Standards', description: 'Conventional commits, branching, commit approval', priority: 110, content: '' },
      { category: 'core', topic: 'utilities', title: 'Utilities', description: 'Ripgrep, fzf, jq, yq, and other CLI tools', priority: 115, content: '' },

      // Languages
      { category: 'languages', topic: 'bash', title: 'Bash/Shell Scripting', description: 'POSIX compliance, ShellCheck, safety patterns', priority: 130, content: '' },
      { category: 'languages', topic: 'python', title: 'Python', description: 'Python 3.14+, type hints, AWS Lambda patterns', priority: 160, content: '' },
      { category: 'languages', topic: 'typescript', title: 'TypeScript', description: 'Strict mode, ESM, modern patterns', priority: 165, content: '' },
      { category: 'languages', topic: 'javascript', title: 'JavaScript', description: 'ES modules, async/await, Node.js patterns', priority: 170, content: '' },
      { category: 'languages', topic: 'go', title: 'Go', description: 'Idiomatic Go, error handling, concurrency', priority: 180, content: '' },
      { category: 'languages', topic: 'rust', title: 'Rust', description: 'Ownership, lifetimes, async, error handling', priority: 185, content: '' },

      // Infrastructure
      { category: 'infrastructure', topic: 'terraform', title: 'Terraform', description: 'Modules, state management, workspaces', priority: 140, content: '' },
      { category: 'infrastructure', topic: 'ansible', title: 'Ansible', description: 'Playbooks, roles, idempotency', priority: 145, content: '' },
      { category: 'infrastructure', topic: 'cloudformation', title: 'CloudFormation', description: 'Templates, stacks, nested stacks', priority: 150, content: '' },
      { category: 'infrastructure', topic: 'docker', title: 'Docker', description: 'Multi-stage builds, security, optimization', priority: 155, content: '' },
      { category: 'infrastructure', topic: 'helm', title: 'Helm', description: 'Charts, templating, releases', priority: 195, content: '' },
      { category: 'infrastructure', topic: 'kubernetes', title: 'Kubernetes', description: 'Manifests, operators, CRDs, security', priority: 260, content: '' },

      // Cloud
      { category: 'cloud', topic: 'cloudflare', title: 'Cloudflare', description: 'Workers, Rules Engine, DNS, security', priority: 250, content: '' },
      { category: 'cloud', topic: 'aws', title: 'AWS', description: 'EKS, VPC Lattice, Lambda, IAM', priority: 280, content: '' },
      { category: 'cloud', topic: 'azure', title: 'Azure', description: 'Bicep, Key Vault, App Service', priority: 285, content: '' },
      { category: 'cloud', topic: 'gcp', title: 'GCP', description: 'GKE, Cloud Run, Secret Manager', priority: 290, content: '' },

      // DevOps
      { category: 'devops', topic: 'github-actions', title: 'GitHub Actions', description: 'Workflows, OIDC, security', priority: 120, content: '' },
      { category: 'devops', topic: 'makefile', title: 'Makefile', description: 'Phony targets, recipes, conventions', priority: 190, content: '' },
      { category: 'devops', topic: 'cli', title: 'CLI Tools', description: 'argparse, typer, rich, user experience', priority: 200, content: '' },

      // Patterns
      { category: 'patterns', topic: 'open-source', title: 'Open Source', description: 'Contributing, licensing, community', priority: 210, content: '' },
      { category: 'patterns', topic: 'documentation', title: 'Documentation', description: 'MkDocs, Docusaurus, API docs', priority: 220, content: '' },
      { category: 'patterns', topic: 'mcp-servers', title: 'MCP Servers', description: 'Model Context Protocol patterns', priority: 230, content: '' },
      { category: 'patterns', topic: 'configuration', title: 'Configuration', description: 'Config management, secrets, environments', priority: 240, content: '' },
      { category: 'patterns', topic: 'testing', title: 'Testing', description: 'Unit, integration, E2E testing', priority: 300, content: '' },
      { category: 'patterns', topic: 'security', title: 'Security', description: 'OWASP, secrets, IAM, least privilege', priority: 310, content: '' },
      { category: 'patterns', topic: 'api-design', title: 'API Design', description: 'REST, GraphQL, gRPC patterns', priority: 320, content: '' },
      { category: 'patterns', topic: 'observability', title: 'Observability', description: 'Logging, metrics, tracing', priority: 330, content: '' },

      // Databases
      { category: 'databases', topic: 'postgresql', title: 'PostgreSQL', description: 'Performance, replication, security', priority: 270, content: '' },

      // Other
      { category: 'other', topic: 'ai-ml', title: 'AI/ML', description: 'Machine learning patterns and tools', priority: 295, content: '' },
      { category: 'other', topic: 'markdown', title: 'Markdown', description: 'GFM, Mermaid diagrams, documentation', priority: 800, content: '' },
    ];

    return rules;
  }
}
