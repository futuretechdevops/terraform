provider "aws" {
  region = "ap-south-1"
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  key_name      = "futuretechdevops15"

  tags = {
    Name = "provisioner-example"
  }

  # File provisioner - copy local file to remote
  provisioner "file" {
    source      = "app.py"
    destination = "/tmp/app.py"
    
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("~/.ssh/id_rsa")
      host        = self.public_ip
    }
  }

  # Remote-exec provisioner - run commands on remote
  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y python3",
      "sudo mv /tmp/app.py /home/ec2-user/",
      "sudo chmod +x /home/ec2-user/app.py",
      "nohup python3 /home/ec2-user/app.py &"
    ]
    
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("~/.ssh/id_rsa")
      host        = self.public_ip
    }
  }

  # Local-exec provisioner - run commands locally
  provisioner "local-exec" {
    command = "echo 'Instance ${self.id} created at ${self.public_ip}' >> deployment.log"
  }
}
