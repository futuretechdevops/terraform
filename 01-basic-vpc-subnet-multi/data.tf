# Get available availability zones
data "aws_availability_zones" "available" {
  state = "available"
}
