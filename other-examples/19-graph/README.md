# Terraform Graph

Visualize resource dependencies and execution order.

## Graph Commands

### Generate Graph
```bash
# Basic dependency graph
terraform graph

# Plan-time graph (includes planned changes)
terraform graph -type=plan

# Apply-time graph
terraform graph -type=apply

# Validate-time graph
terraform graph -type=validate
```

### Create Visual Graph
```bash
# Generate PNG image (requires Graphviz)
terraform graph | dot -Tpng > graph.png

# Generate SVG
terraform graph | dot -Tsvg > graph.svg

# Generate PDF
terraform graph | dot -Tpdf > graph.pdf
```

## Graph Types

- **Configuration Graph**: Resource relationships from configuration
- **Plan Graph**: Includes planned changes and their dependencies
- **Apply Graph**: Shows actual execution order during apply

## Dependencies

### Implicit Dependencies
- Resource references create automatic dependencies
- `aws_instance.web.id` creates dependency on `aws_instance.web`

### Explicit Dependencies
- `depends_on` meta-argument
- Forces dependency when implicit isn't sufficient

## Use Cases

- **Troubleshooting**: Understand why resources fail
- **Documentation**: Visual representation of infrastructure
- **Optimization**: Identify parallel execution opportunities
- **Debugging**: Find circular dependencies

## Installing Graphviz

```bash
# Ubuntu/Debian
sudo apt-get install graphviz

# CentOS/RHEL
sudo yum install graphviz

# macOS
brew install graphviz
```
