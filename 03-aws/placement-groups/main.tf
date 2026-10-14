# 03-aws/placement-groups: the rack layer and the building layer.
# A partition placement group splits instances across racks inside one AZ
# (closest cousin to Azure fault domains). A spread placement group puts one
# critical instance per AZ on distinct hardware. Subnets are pinned by AZ ID.
# Docs: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/placement-strategies.html

locals {
  tags = {
    project = "blast-radius-kit"
  }
}

data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_vpc" "this" {
  cidr_block = "10.42.0.0/16"
  tags       = merge(local.tags, { Name = "${var.prefix}-vpc" })
}

# availability_zone_id (not availability_zone) pins each subnet to the same
# physical zone no matter which account runs this.
resource "aws_subnet" "this" {
  count                = length(var.az_ids)
  vpc_id               = aws_vpc.this.id
  availability_zone_id = var.az_ids[count.index]
  cidr_block           = cidrsubnet(aws_vpc.this.cidr_block, 8, count.index + 1)
  tags                 = merge(local.tags, { Name = "${var.prefix}-${var.az_ids[count.index]}" })
}

# Rack layer --------------------------------------------------------------

resource "aws_placement_group" "partition" {
  name            = "${var.prefix}-partition"
  strategy        = "partition"
  partition_count = var.partition_count
  tags            = merge(local.tags, { layer = "rack" })
}

resource "aws_instance" "partition" {
  count                      = var.partition_count * var.instances_per_partition
  ami                        = data.aws_ssm_parameter.al2023.value
  instance_type              = var.instance_size
  subnet_id                  = aws_subnet.this[0].id
  placement_group            = aws_placement_group.partition.id
  placement_partition_number = (count.index % var.partition_count) + 1

  tags = merge(local.tags, {
    Name      = "${var.prefix}-part${(count.index % var.partition_count) + 1}-${count.index}"
    layer     = "rack"
    partition = tostring((count.index % var.partition_count) + 1)
  })
}

# Building layer ----------------------------------------------------------

resource "aws_placement_group" "spread" {
  name         = "${var.prefix}-spread"
  strategy     = "spread"
  spread_level = "rack"
  tags         = merge(local.tags, { layer = "building" })
}

resource "aws_instance" "spread" {
  count           = length(var.az_ids)
  ami             = data.aws_ssm_parameter.al2023.value
  instance_type   = var.instance_size
  subnet_id       = aws_subnet.this[count.index].id
  placement_group = aws_placement_group.spread.id

  tags = merge(local.tags, {
    Name  = "${var.prefix}-spread-${var.az_ids[count.index]}"
    layer = "building"
  })
}
