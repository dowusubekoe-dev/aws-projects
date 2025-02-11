import os

def create_terraform_structure():
    # Define the base directory
    base_dir = "terraform"
    
    # Define modules and their files
    modules = ["networking", "security", "iam", "ecs"]
    module_files = ["main.tf", "variables.tf", "outputs.tf"]
    
    # Create base directory
    os.makedirs(base_dir, exist_ok=True)
    
    # Create root files
    root_files = ["main.tf", "variables.tf", "outputs.tf"]
    for file in root_files:
        open(os.path.join(base_dir, file), 'a').close()
    
    # Create modules directory and module files
    modules_dir = os.path.join(base_dir, "modules")
    os.makedirs(modules_dir, exist_ok=True)
    
    for module in modules:
        module_dir = os.path.join(modules_dir, module)
        os.makedirs(module_dir, exist_ok=True)
        
        for file in module_files:
            open(os.path.join(module_dir, file), 'a').close()

if __name__ == "__main__":
    create_terraform_structure()
    print("Terraform directory structure created successfully!")