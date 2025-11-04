# Terraform Functions

Built-in functions for transforming and combining values.

## Function Categories

### String Functions
- `lower()`, `upper()`, `title()`: Case conversion
- `join()`, `split()`: String manipulation
- `replace()`, `substr()`: String modification

### Collection Functions
- `length()`: Get collection size
- `element()`: Get element by index
- `concat()`: Combine lists
- `distinct()`: Remove duplicates
- `sort()`: Sort collections

### Numeric Functions
- `max()`, `min()`: Find extremes
- `ceil()`, `floor()`: Rounding
- `abs()`: Absolute value

### Type Conversion
- `tostring()`, `tonumber()`, `tobool()`
- `tolist()`, `tomap()`, `toset()`

### Date/Time Functions
- `timestamp()`: Current timestamp
- `timeadd()`: Add duration
- `formatdate()`: Format timestamp

### Encoding Functions
- `base64encode()`, `base64decode()`
- `jsonencode()`, `jsondecode()`
- `urlencode()`

### File Functions
- `file()`: Read file contents
- `fileexists()`: Check file existence
- `templatefile()`: Process template

### Network Functions
- `cidrsubnet()`: Calculate subnets
- `cidrhost()`: Calculate host addresses

## Usage

```bash
terraform console  # Test functions interactively
terraform plan
terraform apply
```
