# **DDCS CitizenConnect: Automated Provisioning Pipeline**

**Note:** This repository contains the Infrastructure as Code (IaC) and Configuration as Code (CaC) assets demonstrated in the "From Service Request To Automated Provisioning" webinar.

## **📖 Overview**

This repository is maintained by the **Shared Services Cloud Operations (SSCO)** team at the **Department of Digital Citizen Services (DDCS)**. It houses the Terraform configurations and Ansible playbooks required to automatically provision and configure secure, ITSG-33/Protected B compliant environments for the **CitizenConnect Portal** (managed by the **AppMod** team).

This project demonstrates a mature "Better Together" automation architecture, eliminating manual "ClickOps" and reducing environment delivery times from 3 weeks to under 5 minutes.

## **🏗️ Architecture & Tech Stack**

* **Cloud Provider:** AWS (Landing Zone)  
* **Infrastructure:** EC2 instances running Red Hat Enterprise Linux (RHEL)  
* **Application Stack:** Java Enterprise Edition (Java EE) on JBoss EAP  
* **Orchestration:** Red Hat Ansible Automation Platform (AAP)  
* **Day 0 Provisioning:** HashiCorp Terraform  
* **ITSM / Self-Service:** ServiceNow  
* **State Management:** OpenShift Data Foundations (NooBaa) Object Bucket

## **🔄 The Pipeline Workflow (Current Automated State)**

This repository is designed to be executed headlessly via **Ansible Automation Platform (AAP)**, triggered by a REST API call from ServiceNow.

1. **ServiceNow Trigger:** An AppMod developer requests an environment via a ServiceNow catalog item, specifying the Cost Center and target environment.  
2. **Approval Gate:** The AppMod team lead approves the request in ServiceNow, triggering a REST API call to AAP.  
3. **Orchestration (AAP):** AAP launches the master workflow job template from this repository (DDCS\_CitizenConnect\_Deploy).  
4. **Day 0 (Terraform):** AAP utilizes the native Terraform module to execute a terraform apply. This provisions the AWS VPC, strict Security Groups, and RHEL EC2 instances, applying the selected Cost Center billing tags.  
5. **Day 2 (Ansible):** Once infrastructure is up, AAP dynamically inventories the new IPs and executes the configuration playbooks to:  
   * Apply federal OS hardening baselines (Protected B / ITSG-33).  
   * Install Java and JBoss EAP.  
   * Deploy the CitizenConnect.war artifact.  
6. **Ticket Resolution:** AAP makes a callback to the ServiceNow API to document the new AWS internal IPs, connection details, and audit logs, automatically closing the ticket.

## **🗂️ Repository Structure**

```
.
├── collections/
│   └── requirements.yml                  # Ansible Galaxy collection dependencies
├── docs/
│   └── setup-notes.md                    # Setup and configuration documentation
├── exec-environment/
│   ├── ansible_terraform/                # Execution environment with Terraform support
│   │   ├── bindep.txt                    # System-level dependencies
│   │   ├── execution-environment.yml     # EE definition with Terraform
│   │   └── requirements.yml              # Python dependencies
│   └── cloud_providers/                  # Cloud provider execution environment
│       ├── execution-environment.yml     # EE definition for cloud modules
│       └── requirements.yml              # Cloud provider dependencies
├── playbooks/
│   ├── aws_infra_provisioning.yml        # Main infrastructure provisioning workflow
│   ├── configure_vm_firewall.yml         # Firewall configuration
│   ├── install_haproxy.yml               # HAProxy load balancer installation
│   ├── install_jboss.yml                 # JBoss EAP & Java installation
│   ├── print_ticket_stats.yml            # ServiceNow ticket statistics
│   ├── save_workflow_stats.yml           # Workflow metadata and audit logs
│   ├── snow_set_ticket_info.yml          # ServiceNow integration callbacks
│   └── roles/                            # Reusable Ansible roles
│       ├── haproxy-config/               # HAProxy configuration role
│       ├── jboss-eap-config/             # JBoss EAP configuration role
│       └── sent_mail/                    # Email notification role
├── terraform/
│   └── aws/
│       ├── data-sources.tf               # AWS data source queries
│       ├── main.tf                       # Core AWS resource definitions (EC2, VPC)
│       ├── provider.tf                   # AWS provider configuration
│       ├── terraform.tfvars              # Variable values
│       ├── variables.tf                  # Input variables mapped from ServiceNow
│       └── versions.tf                   # Terraform and provider version constraints
├── .gitignore
├── NOTES.md                              # Development notes
└── README.md                             # This file
```

## **⚙️ Configuration Variables & Metadata**

### **Cost Centers (Billing Tags)**

The pipeline dynamically tags AWS resources based on the cost center passed from the ServiceNow payload. Supported values:

* CC-APPMOD-840 \- Application Modernization (Default for Dev/Test)  
* CC-SHRINF-100 \- Shared IT Infrastructure (Central IT budget)  
* CC-CZNGRT-550 \- Citizen Grants Program (Production funding)

### **Terraform State Management**

*Tech Note:* To ensure a highly secure, localized source of truth, the backend state store for Terraform (backend.tf) is configured to use an S3-compatible object bucket created with **OpenShift Data Foundations (NooBaa)**. This bucket resides securely within the same OpenShift cluster hosting our AAP deployment.

## **🛑 Background: The Manual Bottleneck (Before)**

To understand the value of this repository, it is helpful to contrast it with the legacy infrastructure provisioning process. Previously, all infrastructure requests were handled manually to meet strict federal compliance standards (e.g., ITSG-33 / Protected B).

1. **The Request:** An **AppMod** developer filled out a ServiceNow form requesting a new web server for the CitizenConnect Portal. They manually typed their justification, required stack (JBoss EAP on AWS), compliance level, and Cost Center.  
2. **The Queue:** The ticket sat in the **SSCO** team's queue, waiting for triage.  
3. **Manual Provisioning ("ClickOps"):** An SSCO infrastructure operator eventually picked up the ticket. They logged into the AWS Console and manually clicked through menus to spin up a t3.large instance, copy/pasting IP ranges and trying to remember to manually apply the CC-APPMOD-840 billing tag.  
4. **Manual Configuration:** The operator SSHed into the new RHEL VM to manually install Java, configure JBoss EAP, and painfully apply complex federal OS hardening scripts.  
5. **The Handoff:** The operator manually typed the new AWS internal IP addresses, JBoss connection details, and secret locations into the ServiceNow ticket comments and closed it.

**The Pain Points Addressed:**

* **Time:** The legacy process took 2 to 3 weeks due to queue times, context switching, and manual handoffs.  
* **Human Error:** Forgetting billing tags broke chargeback reporting. Copy-pasting values frequently led to misconfigured security groups.  
* **Stagnant Standards:** When ITSG-33 compliance rules changed, operators relied on outdated Word document "Runbooks" or outdated memory, leading to immediate compliance audit failures.

## **🌟 Departmental Outcomes & Quality of Life**

By adopting the automated approach defined in this repository, the Department of Digital Citizen Services transformed its IT operations:

* **For the AppMod Team (Quality of Life):** \* **Instant Gratification:** Wait times dropped from 3 weeks to 5 minutes post-approval.  
  * **Focus:** Developers now spend their time coding new features for the CitizenConnect portal rather than chasing IT operators for ticket updates.  
* **For the SSCO Team (Quality of Life):**  
  * **Elevation of Role:** Ops teams transitioned away from monotonous "ClickOps" and copy-pasting. They act as Automation Engineers, focusing on writing clean code (Infrastructure as Code) instead of reading Word doc runbooks.  
  * **Zero Friction Updates:** Capturing "Lessons Learned" or updating federal compliance standards is now just a Git commit to this repository. Every deployment going forward automatically inherits the fix.  
* **For the Department (Organizational Outcomes):**  
  * **Rock-Solid Compliance:** Security is baked into the pipeline. Every server deployed is identical, auditable, and inherently compliant with federal standards.  
  * **Speed of Mission:** The agency rolls out new digital citizen services drastically faster, improving public sector efficiency.

### **🎯 A Pragmatic Step Toward Automation Maturity**

It is worth noting that in a perfectly mature, "ideal" DevOps state, there is enough inherent trust in the Infrastructure as Code (IaC), automated testing, and compliance checks that a manual approval step to start the workflow wouldn't be necessary at all.

However, in reality—especially within federal departments or highly regulated industries—removing human gates entirely on day one is often unrealistic and a non-starter for security and compliance teams. By intentionally keeping the manual "Approve" button in ServiceNow (Step 2 of the workflow), this architecture provides a crucial psychological and operational safety net while the organization builds trust in the new automated pipelines. This approach serves as a realistic first step in the right direction, bridging the gap between legacy IT workflows and a fully mature, zero-touch automation practice.