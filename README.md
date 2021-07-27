# AKS-workshop

## Introduction
This repository contains scripts that will deploy an AKS cluster with associated components as found in the [AKS workshop](https://docs.microsoft.com/en-us/learn/modules/aks-workshop/) on Microsoft Learn

## Steps
1. Download code from this repository locally  
   ```
   git clone https://github.com/sajitsasi/aks-workshop.git
   ```
2. Download the latest source code from MS Learn  
   ```
   cd aks-workshop/src
   git clone https://github.com/MicrosoftDocs/mslearn-aks-workshop-ratings-api.git
   git clone https://github.com/MicrosoftDocs/mslearn-aks-workshop-ratings-web.git
   ```
3. Ensure your prerequisite packages are installed:
   * Bash shell in Linux/MacOS and WSL2 in Windows
   * [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-windows?tabs=azure-cli)
   * [Git](https://git-scm.com/downloads)
   * [Docker](https://docs.docker.com/engine/install/)
   * [kubectl](https://kubernetes.io/docs/tasks/tools/) - choose appropriate platform
   * [helm](https://helm.sh/docs/intro/install/)
   * [Visual Studio Code](https://code.visualstudio.com/Download) - this is optional



## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.microsoft.com.

When you submit a pull request, a CLA-bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., label, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.
