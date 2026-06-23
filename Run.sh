# Update Homebrew package lists
brew update

# Install all three tools at once
brew install jq opa hashicorp/tap/terraform
# 1. Update your system and install jq
sudo apt-get update
sudo apt-get install -y jq

# 2. Download and install OPA 
sudo curl -L -o /usr/local/bin/opa https://openpolicyagent.org
sudo chmod +x /usr/local/bin/opa

# 3. Add the official HashiCorp GPG key and repository for Terraform
sudo apt-get install -y gnupg software-properties-common
wget -O- https://hashicorp.com | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/永久/sources.list.d/hashicorp.list

# 4. Update and install Terraform
sudo apt-get update && sudo apt-get install terraform
jq --version
opa version
terraform -version


