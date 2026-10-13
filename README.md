# Terraform EC2 Web Server

A small practice project. Terraform creates one web server on AWS that shows a simple page. I built it from a blank folder to get comfortable with the Terraform basics after finishing my bigger project, [cloud-web-app-terraform](https://github.com/malishahid557/cloud-web-app-terraform).

## What it creates

- One EC2 server (t3.micro, Ubuntu 22.04) in us-east-1, in the default VPC
- A security group: HTTP open to everyone, SSH only from my IP, all outbound traffic allowed
- A startup script (`user_data`) that installs nginx and writes the page
- An output that prints the server's public IP

The Ubuntu image comes from a `data "aws_ami"` lookup, so I don't hardcode an AMI ID. My IP is in a variable, and `terraform.tfvars` is gitignored.

## How to run it

1. Copy `terraform.tfvars.example` to `terraform.tfvars` and put in your own IP (like `1.2.3.4/32`).
2. Run `terraform init`, then `terraform plan`, then `terraform apply`.
3. Open `http://<server_ip>` in a browser. Give it a minute or two, because nginx is still installing at first.
4. Run `terraform destroy` when you're done so it doesn't cost money.

## Things that went wrong

- I typed `required_provider` instead of `required_providers`. Terraform's error message suggested the right name.
- I wrote `vpc_security_group_id` instead of `vpc_security_group_ids`. Same kind of mistake, same kind of fix.
- At one point I pasted a whole copy of the server block inside my startup script, and `plan` failed with an unbalanced parentheses error.
- `terraform init` timed out because my Ubuntu VM's DNS was still pointing at an old network. Setting a working DNS server fixed it.
- The page didn't load at first because my browser used `https://` and only port 80 was open. Using `http://` fixed it.

## What I learned

- `user_data` only runs on the server's first boot, so the script has to be right before `apply`.
- Terraform builds resources in the right order because they reference each other.
- A timeout usually means a firewall is dropping the traffic, not that the server is broken.

## Next steps

Add my own VPC with public and private subnets, then a load balancer.
